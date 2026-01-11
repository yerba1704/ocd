create or replace package body worker as
----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------
  procedure sync_to_content_revision(i_schema_name in varchar2, i_package_name in varchar2) is
  begin
    insert into ocd.content_revision
      select schema_name,
             package_id,
             package_name,
             ltrim(component_name, '.') as component_name,
             rownum                     as component_sequence,
             ltrim(component_type, '.') as component_type,
             hierarchical_level,
             systimestamp      as created_at,
             comment_or_code   as original_comment_or_code,
             deprecated_fl     as original_deprecated_fl,
             deprecation_text  as original_deprecation_text,
             comment_or_code   as modified_comment_or_code,
             deprecated_fl     as modified_deprecated_fl,
             deprecation_text  as modified_deprecation_text,
             0                 as priority_fl,
             null              as modified_by,
             null              as modified_at
        from ocd.package_component
       where schema_name = i_schema_name
         and package_name = i_package_name;
    --TODO heavy logic with created at to preserve existing ui comments :)
    l('WORKER.SYNC_TO_CONTENT_REVISION> data synchronized successfully ('||i_schema_name||'.'||i_package_name||')');
  end sync_to_content_revision;  
----------------------------------------------------------------------------------------------------------------------------------------------------------------
  procedure to_package_subprogram(i_subprogram_name in varchar2, i_comment in clob, i_block_iteration in pls_integer,
                                  i_package_id in raw, i_order_sequence in integer, i_block_t in token_table)
  is
    l_subprogram_id ocd.package_subprogram.subprogram_id%type;
    l_comment clob:=i_comment;
    l_argument_c sys.ora_mining_varchar2_nt;
    l_example_c sys.ora_mining_varchar2_nt;
    n pls_integer:=1;
    x pls_integer:=0;
    l_arg_name ocd.subprogram_argument.argument_name%type;
    l_arg_comment ocd.subprogram_argument.argument_comment%type;
    l_arg_default ocd.subprogram_argument.argument_default%type;
    l_set_next_word_to_name_variable boolean:=false;
    l_switch_arg_default boolean:=false;
    l_default_with_brackets boolean:=false;
  begin
    -- extract or split subprogram comment from argument comments and example code
    inspect_subprogram_type_comment(io_comment => l_comment, o_argument_or_field_c => l_argument_c, o_example_c => l_example_c);
    insert into ocd.package_subprogram values (i_package_id, default, i_subprogram_name, refine_comment(l_comment),
      --deprecated_fl
      default,
      --deprecated_warning
      default,
      --order_sequence
      i_order_sequence )
    returning subprogram_id into l_subprogram_id;
    
    -- there are no arguments if last value is equal to name (procedure) or there is no return keyword (function) and no closing brackets (function)
    if ( upper(i_block_t(i_block_t.count).value) != i_subprogram_name ) or 
       ( upper(i_block_t(i_block_t.count-1).value) = 'RETURN' and upper(i_block_t(i_block_t.count-2).value) !=')' ) 
    then
      <<argument_extraction>>
      for j in i_block_iteration..i_block_t.count loop
        case lower(i_block_t(j).type||to_char(i_block_t(j).value))
          when '((' 
            then
              -- es kann sein das der default nen klammerausdruck hat, bspw. default v('abc') ACHTUGN!!!
              if l_switch_arg_default then
                l_default_with_brackets:=true;
              else
                l_set_next_word_to_name_variable:=true;
              end if;
          when ',,' 
            then
              -- was wenn bspw. default ausdruck komma hat, aslo etwa "nvl(1,2)", , kann nur in funktion und ist tokentyp , (sonst word), d.h. l_switch_arg_default würde nicht reichen bzw. funktionieren
              if not l_default_with_brackets then
                -- save collected data
                l_arg_comment:=case when l_argument_c.exists(n) then l_argument_c(n) end;
                insert into ocd.subprogram_argument values (l_subprogram_id, default, 
                  l_arg_name, refine_comment(l_arg_comment), l_arg_default,
                  n);
                l_set_next_word_to_name_variable:=true;
                l_switch_arg_default:=false;
                l_arg_default:=null;
                n:=n+1;
              else
                l_arg_default:=l_arg_default||i_block_t(j).value; --=> fix ","
              end if;
          when '))' 
            then
              if l_default_with_brackets then
                l_default_with_brackets:=false;
                l_arg_default:=l_arg_default||i_block_t(j).value; --=> fix ")"
              else
                -- save collected data
                l_arg_comment:=case when l_argument_c.exists(n) then l_argument_c(n) end;
                insert into ocd.subprogram_argument values (l_subprogram_id, default, 
                  l_arg_name, refine_comment(l_arg_comment), l_arg_default,
                  n);
                l_switch_arg_default:=false;
                l_arg_default:=null;
                n:=n+1;
              end if;
          when ':=:='
            then
              l_switch_arg_default:=true;
          when 'worddefault'
            then
              l_switch_arg_default:=true;
            else
              null;
        end case;
        
        if l_set_next_word_to_name_variable and i_block_t(j).type='word' then
          l_arg_name:=upper(i_block_t(j).value);
          l_set_next_word_to_name_variable:=false;
        end if;
        
        if l_switch_arg_default and i_block_t(j).type!='comment' 
          and i_block_t(j+1).type||to_char(i_block_t(j+1).value)!=',,' 
          and i_block_t(j+1).type||to_char(i_block_t(j+1).value)!='))'
          and i_block_t(j+1).type!='comment' -- sometimes is a comment after the defaultvalue
        then
          l_arg_default:=l_arg_default||i_block_t(j+1).value;
        end if;
      end loop argument_extraction;
    end if;
    
    <<subprogram_examples>>
    for i in 1..l_example_c.count loop
      insert into ocd.subprogram_example values (l_subprogram_id, default, 'EXAMPLE_'||i, l_example_c(i), i);
    end loop subprogram_examples;
    
    exception when others then raise;
  end to_package_subprogram;
----------------------------------------------------------------------------------------------------------------------------------------------------------------
  procedure to_package_type(i_type_name in varchar2, i_comment in clob, i_block_iteration in pls_integer,
                            i_package_id in raw, i_order_sequence in integer, i_block_t in token_table)
  is
    l_type_id ocd.package_type.type_id%type;
    l_comment clob:=i_comment;
    l_field_c sys.ora_mining_varchar2_nt;
    l_example_c sys.ora_mining_varchar2_nt;
    n pls_integer:=0;
    l_new_field boolean := false;
  begin
    -- extract or split type comment from field comments
    inspect_subprogram_type_comment(io_comment => l_comment, o_argument_or_field_c => l_field_c, o_example_c => l_example_c);
    insert into ocd.package_type values (i_package_id, default, i_type_name, refine_comment(l_comment),
      --deprecated_fl
      default,
      -- deprecated_warning
      default,
      --order_sequence
      i_order_sequence )
    returning type_id into l_type_id;
    
    -- only record types have fields
    if i_block_t.exists(i_block_iteration+3) and upper(i_block_t(i_block_iteration+3).value)='RECORD' then
      l_new_field := true;
      <<field_extraction>>
      for j in i_block_iteration+5..i_block_t.count loop
        -- first word must be field name
        if (i_block_t(j).type='word' and l_new_field) then
          -- get field comment from collection if exists
          l_comment:=case when l_field_c.exists(n+1) then l_field_c(n+1) end;
          insert into ocd.type_field values (l_type_id, default, upper(i_block_t(j).value), refine_comment(l_comment), n);
          n:=n+1;
          l_new_field := false;
        end if;
        -- abort or continue
        if i_block_t(j).type=',' then
          l_new_field := true;
        end if;
      end loop field_extraction;
    end if;
    
    exception when others then raise;
  end to_package_type;
----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------
  procedure package_compiled(i_schema_name in varchar2, i_object_name in varchar2, i_object_code in clob) is
  begin
    split_package(i_schema_name  => i_schema_name, i_package_name => i_object_name, i_package_code => i_object_code);
    l('WORKER.PACKAGE_COMPILED> data inserted successfully ('||i_schema_name||'.'||i_object_name||')');
  end package_compiled;
----------------------------------------------------------------------------------------------------------------------------------------------------------------
  procedure package_removed(i_schema_name in varchar2, i_object_name in varchar2) is
  begin
    delete from schema_package where schema_name=i_schema_name and package_name=i_object_name;
    l('WORKER.PACKAGE_REMOVED> data erased successfully ('||i_schema_name||'.'||i_object_name||')');
  end package_removed;
----------------------------------------------------------------------------------------------------------------------------------------------------------------
  procedure user_dropped(i_schema_name in varchar2) is
  begin
    delete from schema_package where schema_name=i_schema_name;
    l('WORKER.USER_DROPPED> data erased successfully ('||i_schema_name||')');
  end user_dropped;
----------------------------------------------------------------------------------------------------------------------------------------------------------------
  function object_code(i_schema_name in varchar2, i_package_name in varchar2) return clob is
    c_schema_name  constant dbms_id_128 not null:=i_schema_name;
    c_package_name constant dbms_id_128 not null:=i_package_name;
    c_stmt constant varchar2(4000 char):=q'[
    select text
      from sys.dba_source
     where type='PACKAGE'
      and owner= :0
      and name = :1
      and origin_con_id = (
      select min(origin_con_id)
        from sys.dba_source
       where type='PACKAGE'
         and owner= :2
         and name = :3
      )
      order by line
      ]';
    l_src_line dbms_preprocessor.source_lines_t;
    l_src_code clob;
  begin
    execute immediate c_stmt bulk collect into l_src_line using c_schema_name, c_package_name, c_schema_name, c_package_name;
    -- using the rights from OCD - not the role (catalog_role)
    -- e.g. in APEX_240200.WWV_FLOW_EXEC_API the type T_VALUE can not correct dissolve by DBMS_PREPROCESSOR (WWV_FLOW_DB_VERSION.C_HAS_LOCATOR)
    l_src_line:=dbms_preprocessor.get_post_processed_source(l_src_line);
    for i in l_src_line.first .. l_src_line.last loop l_src_code:=l_src_code||l_src_line(i); end loop;
    
    return l_src_code;
  end object_code;
----------------------------------------------------------------------------------------------------------------------------------------------------------------
  procedure split_package(
      i_schema_name  in varchar2,
      i_package_name in varchar2,
      i_package_code in clob)
  is
    l_token_t token_table;
    l_block_t token_table:=token_table();
    l_pkg_finished boolean:=false;
    l_comment clob;
    l_package_id schema_package.package_id%type;
    l_order_sequence pls_integer:=0;
    l_last_type dbms_id_30;
    l_last_name dbms_id_30;
  begin
    l('WORKER.SPLIT_PACKAGE> start analyzing source code ('||i_schema_name||'.'||i_package_name||')');
    l_token_t:=plsql_lexer.lex(p_source => i_package_code);
    l('WORKER.SPLIT_PACKAGE> token varray received');
    
    for i in 1..l_token_t.count loop
      if l_token_t(i).type='whitespace' then continue; end if;
      -- parent
      if not l_pkg_finished then
        if l_token_t(i).type='comment' and substr(l_token_t(i).value,1,2)!='/*' then
          -- similar code lines in 'split_declaration'
          l_comment:=l_comment||chr(10)||trim( substr(l_token_t(i).value,3) );
          l_comment:=replace(l_comment, chr(13)||chr(10), chr(10));
          l_comment:=replace(l_comment, chr(9), '  ');
        end if;
        if l_token_t(i).type='word' and lower(l_token_t(i).value) in ('is','as') then
          delete from ocd.schema_package where schema_name=i_schema_name and package_name=i_package_name;
          insert into ocd.schema_package (schema_name, package_name, package_comment) 
            values (i_schema_name, i_package_name, refine_comment(l_comment) )
            returning package_id into l_package_id;
          l_last_type:='PACKAGE';
          l_last_name:=i_package_name;
          l_pkg_finished:=true;
          continue;
        end if;
      end if;
      -- child
      if l_pkg_finished then
        if l_token_t(i).type!=';' then
          l_block_t.extend();
          l_block_t(l_block_t.count):=l_token_t(i);
        else
          l_order_sequence:=l_order_sequence+1;
          split_declaration(i_package_id => l_package_id, i_order_sequence => l_order_sequence, i_block_t => l_block_t,
                            io_last_type => l_last_type, io_last_name => l_last_name);
          l_block_t:=token_table();
        end if;
      end if;
    end loop;
    -- final step for further processsing in apex gui
    sync_to_content_revision(i_schema_name  => i_schema_name, i_package_name => i_package_name);
  end split_package;
---------------------------------------------------------------------------------------------------------------------------------------------------------------- 
  procedure split_declaration (
      i_package_id     in raw,
      i_order_sequence in integer,
      i_block_t        in token_table,
      io_last_type     in out nocopy varchar2,
      io_last_name     in out nocopy varchar2)
  is
    l_comment clob;
    l_dep_msg varchar2(4000 char);
    l_preserve_white_space boolean:=false;
  begin
    for j in 1..i_block_t.count loop
      -- fetch any line comments
      if i_block_t(j).type='comment' and substr(i_block_t(j).value,1,2)!='/*' then
          -- similar code lines in 'split_package'
          l_comment:=replace(l_comment, chr(13)||chr(10), chr(10));
          l_comment:=replace(l_comment, chr(9), '  ');
          if substr( trim( substr(i_block_t(j).value,3) ), 1,1)='^' then l_preserve_white_space:=true; end if;
          l_comment:=l_comment||chr(10)||case when l_preserve_white_space then       substr(i_block_t(j).value,3)
                                                                          else trim( substr(i_block_t(j).value,3) )
                                         end;
        continue;
      end if;
      -- handle package source items
      if i_block_t(j).type='word' then
        case upper(i_block_t(j).value) 
          when 'CONSTANT'   then  io_last_name:=upper(i_block_t(j-1).value);
                                  io_last_type:=upper(i_block_t(j).value);
                                  <<constant_handling>>
                                  declare
                                    l_constant_datatype ocd.package_constant.constant_datatype%type;
                                    l_constant_null_fl  ocd.package_constant.constant_null_fl%type:=1;
                                    l_constant_value    ocd.package_constant.constant_value%type;
                                    x pls_integer:=1;
                                    is_default boolean := false;
                                  begin
                                    loop
                                      exit when not i_block_t.exists(j+x);
                                        -- collect right side from :=/default
                                        if is_default then l_constant_value:=l_constant_value||i_block_t(j+x).value; end if;
                                        -- switch to default value
                                        if upper(i_block_t(j+x).value) = 'DEFAULT' or i_block_t(j+x).value = ':=' then is_default:=true; end if;
                                        -- not null constraint
                                        if upper(i_block_t(j+x).value) = 'NULL' and upper(i_block_t(j+x-1).value) = 'NOT' then l_constant_null_fl:=0; end if;
                                        -- collect left side from :=/default
                                        if not is_default then l_constant_datatype:=l_constant_datatype||i_block_t(j+x).value; end if;
                                      x:=x+1;
                                    end loop;
                                    -- datatype sanitization
                                    if upper(substr(l_constant_datatype,-7))='NOTNULL' then
                                      l_constant_datatype:=substr(l_constant_datatype,1,length(l_constant_datatype)-7);
                                    elsif upper(substr(l_constant_datatype,-4))='NULL' then
                                      l_constant_datatype:=substr(l_constant_datatype,1,length(l_constant_datatype)-4);
                                    end if;
                                    -- add space between number and char/byte if exists
                                    l_constant_datatype:=regexp_replace(l_constant_datatype,'((byte|char)\))$', ' \1');
                                    l_constant_datatype:=upper(l_constant_datatype);
                                    
                                    insert into ocd.package_constant values (i_package_id, default, io_last_name, refine_comment(l_comment),
                                                                             -- constant_datatype
                                                                             l_constant_datatype,
                                                                             -- constant_null_fl
                                                                             l_constant_null_fl,
                                                                             -- constant_value
                                                                             l_constant_value,
                                                                             --deprecated_fl
                                                                             default,
                                                                             -- deprecated_warning
                                                                             default,
                                                                             --order_sequence
                                                                             i_order_sequence );
                                    continue;
                                  end constant_handling;
                                  /*
                                  [j-1]     [j]
                                  c_example constant integer := 1704;

                                  https://docs.oracle.com/en/database/oracle/oracle-database/23/lnpls/constant-declaration.html
                                  */
          when 'EXCEPTION'  then  io_last_name:=upper(i_block_t(j-1).value);
                                  io_last_type:=upper(i_block_t(j).value);
                                  
                                  insert into ocd.package_exception values (i_package_id, default, io_last_name, refine_comment(l_comment),
                                                                            --deprecated_fl
                                                                            default,
                                                                            -- deprecated_warning
                                                                            default,
                                                                            --order_sequence
                                                                            i_order_sequence );
                                  continue;
                                  /*
                                  [j-1]     [j]
                                  e_example exception; 

                                  https://docs.oracle.com/en/database/oracle/oracle-database/23/lnpls/exception-declaration.html
                                  */
          when 'PROCEDURE'  then  io_last_name:=upper(i_block_t(j+1).value);
                                  io_last_type:='SUBPROGRAM';
                                  
                                  to_package_subprogram(i_subprogram_name => io_last_name, i_comment => l_comment, i_block_iteration => j,
                                                        i_package_id => i_package_id, i_order_sequence => i_order_sequence, i_block_t => i_block_t);
                                  continue;
                                  /*
                                  [j]       [j+1]
                                  procedure p_example;

                                  https://docs.oracle.com/en/database/oracle/oracle-database/23/lnpls/procedure-declaration-and-definition.html
                                  */
          when 'FUNCTION'   then  io_last_name:=upper(i_block_t(j+1).value);
                                  io_last_type:='SUBPROGRAM';
                                  
                                  to_package_subprogram(i_subprogram_name => io_last_name, i_comment => l_comment, i_block_iteration => j,
                                                        i_package_id => i_package_id, i_order_sequence => i_order_sequence, i_block_t => i_block_t);
                                  continue;
                                  /*
                                  [j]      [j+1]
                                  function f_square(i_value in number) return number;

                                  https://docs.oracle.com/en/database/oracle/oracle-database/23/lnpls/function-declaration-and-definition.html
                                  */
          when 'TYPE'       then  -- avoid ...%type syntax and type column names
                                  if not i_block_t.exists(j-1) or ( (i_block_t.exists(j-1) and i_block_t(j-1).type!='%') 
                                                                and (i_block_t.exists(j-1) and i_block_t(j-1).type!='.') ) then
                                    io_last_name:=upper(i_block_t(j+1).value);
                                    io_last_type:='TYPE';

                                    to_package_type(i_type_name => io_last_name, i_comment => l_comment, i_block_iteration => j,
                                                    i_package_id => i_package_id, i_order_sequence => i_order_sequence, i_block_t => i_block_t);
                                  continue;
                                  end if;
                                  /*
                                  [j]  [j+1]
                                  type t_number_va is varray(5) of number;

                                  https://docs.oracle.com/en/database/oracle/oracle-database/23/lnpls/collection-variable.html
                                  https://docs.oracle.com/en/database/oracle/oracle-database/23/lnpls/record-variable-declaration.html
                                  
                                  https://docs.oracle.com/en/database/oracle/oracle-database/23/lnpls/plsql-collections-and-records.html

                                  !! cursor type is not (yet) supported: https://asktom.oracle.com/ords/asktom.search?tag=sys-ref-cursor-and-ref-cursor
                                  */
          when 'PRAGMA'     then  if upper(i_block_t(j+1).value)='DEPRECATE' then
                                    l_dep_msg:=case when i_block_t(j+4).value=',' then trim(both '''' from i_block_t(j+5).value) end;
                                    -- current object_name match last_name
                                    if upper(i_block_t(j+3).value)=io_last_name then
                                      case io_last_type
                                        when 'CONSTANT' then 
                                          update ocd.package_constant
                                             set deprecated_fl=1, deprecation_text=l_dep_msg where package_id=i_package_id and constant_name=io_last_name;
                                        when 'EXCEPTION' then 
                                          update ocd.package_exception
                                             set deprecated_fl=1, deprecation_text=l_dep_msg where package_id=i_package_id and exception_name=io_last_name;
                                        when 'SUBPROGRAM' then 
                                          update ocd.package_subprogram
                                             set deprecated_fl=1, deprecation_text=l_dep_msg where package_id=i_package_id and subprogram_name=io_last_name;
                                        when 'TYPE' then 
                                          update ocd.package_type
                                             set deprecated_fl=1, deprecation_text=l_dep_msg where package_id=i_package_id and type_name=io_last_name;
                                        when 'PACKAGE' then 
                                          update ocd.schema_package
                                             set deprecated_fl=1, deprecation_text=l_dep_msg where package_id=i_package_id;
                                        else 
                                          null;
                                      end case;
                                    end if;
                                  end if;
                                  continue;
            else null;
        end case;
      end if;
    end loop;
  end split_declaration;
----------------------------------------------------------------------------------------------------------------------------------------------------------------
  function refine_comment(i_comment in clob) return varchar2 is
    l_comment varchar2(4000 char);
  begin
    -- strip to column length in table
    if length(i_comment)>4000 then
      l_comment:=substr(i_comment,1,4000);
    else 
      l_comment:=to_char(i_comment);
    end if;
    -- remove surrounding line breaks
    l_comment:=trim(both chr(10) from l_comment);
    -- paragraphs to unit separator
    l_comment:=regexp_replace( l_comment, chr(10)||'{2,}', chr(31) );
    -- concatenate line breaks
    l_comment:=       replace( l_comment, chr(10),         ' ');
    -- unit separator to paragraphs
    l_comment:=       replace( l_comment, chr(31),         chr(10)||chr(10) );
    
    return l_comment;
  end refine_comment;
----------------------------------------------------------------------------------------------------------------------------------------------------------------
  procedure inspect_subprogram_type_comment(
      io_comment         in out nocopy clob,
      o_argument_or_field_c out nocopy sys.ora_mining_varchar2_nt,
      o_example_c           out nocopy sys.ora_mining_varchar2_nt)
  is
    l_prev_pos integer := 1;
    l_pos integer;
    l_comment_block clob := io_comment;
    l_max_pos integer := length(l_comment_block) + 1;
    l_line varchar2(32767 char);
    l_argument_or_field_c sys.ora_mining_varchar2_nt:=sys.ora_mining_varchar2_nt();
    l_example_c sys.ora_mining_varchar2_nt:=sys.ora_mining_varchar2_nt();
    l_is_argument_or_field boolean := false;
    l_is_example boolean := false;
  begin
    io_comment:=null;
    -- loop only if there is something to loop
    if l_comment_block is not null then
      loop
        -- find position to split
        l_pos := instr(l_comment_block, chr(10), l_prev_pos);
        -- if no more to split, set pos = max_pos
        if l_pos = 0 then l_pos := l_max_pos; end if;
        -- fetch line
        l_line:=substr(l_comment_block, l_prev_pos, l_pos - l_prev_pos);
        -- distinguish between target collection
        if substr(l_line,1,1)='@' then
          l_is_argument_or_field:=true;
          l_is_example:=false;
          l_line:=ltrim(l_line,'@');
          l_argument_or_field_c .extend(1);
        elsif substr(ltrim(l_line),1,1)='^' then
          l_is_argument_or_field:=false;
          l_is_example:=true;
          l_line:=ltrim(ltrim(l_line),'^');
          l_example_c.extend(1);
        end if;
        -- assignment
        case 
          when l_is_example
            then l_example_c(l_example_c.count):=l_example_c(l_example_c.count)||chr(10)||rtrim(l_line);
          when l_is_argument_or_field
            then l_argument_or_field_c (l_argument_or_field_c .count):=l_argument_or_field_c (l_argument_or_field_c .count)||chr(10)||trim(l_line);
            else 
              io_comment:=io_comment||chr(10)||l_line;
        end case;
        -- exit loop
        exit when l_pos = l_max_pos;
        -- set previous position
        l_prev_pos := l_pos + 1;
      end loop;
      
      io_comment:=refine_comment( io_comment );
      -- remove leading line break and more...
      for i in 1..l_argument_or_field_c .count loop l_argument_or_field_c (i):=refine_comment( l_argument_or_field_c (i) ); end loop;
      o_argument_or_field_c:=l_argument_or_field_c ;
      
      for i in 1..l_example_c.count loop l_example_c(i):=ltrim( l_example_c(i), chr(10) ); end loop;
      
      o_example_c:=l_example_c;
    else
      -- empty but initialized collection
      o_example_c:=sys.ora_mining_varchar2_nt();
      o_argument_or_field_c:=sys.ora_mining_varchar2_nt();
    end if;
  end inspect_subprogram_type_comment;
----------------------------------------------------------------------------------------------------------------------------------------------------------------
  function schema_packages(
      i_schema_name in varchar2)
    return clob
  is
    c_schema_name constant dbms_id_128:=i_schema_name;
    c_stmt constant varchar2(4000 char):=q'[select dbms_xmlgen.convert(
          extract(
           xmltype('<?xml version="1.0"?><x>'||xmlagg(xmltype('<y>'||dbms_xmlgen.convert(object_name||',') || '</y>')).getclobval()||'</x>'),
           '/x/y/text()'
         ).getclobval(), 1) as object_name
    from dba_objects
   where object_type='PACKAGE'
     and owner=:0]';
    l_cur sys_refcursor;
    l_out clob;
  begin
    execute immediate c_stmt into l_out using c_schema_name;
    
    return l_out;
  end schema_packages;
----------------------------------------------------------------------------------------------------------------------------------------------------------------
end worker;
