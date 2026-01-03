create or replace trigger ddl_on_package after ddl on database 
begin

  -- analyze package content v1
  if dictionary_obj_type = 'PACKAGE' and ora_sysevent = 'CREATE' then
    <<get_source_code_explicit>>
    declare
      n        binary_integer;
      sql_text ora_name_list_t;
      code     clob;
      ppsl     dbms_preprocessor.source_lines_t;
    begin
    l('DDL_ON_PACKAGE> DDL event trigger fired ('||ora_sysevent||' '||lower(dictionary_obj_type)||' '||dictionary_obj_owner||'.'||dictionary_obj_name||')');
      n:=ora_sql_txt(sql_text);
      for i in 1..n loop ppsl(i):=regexp_replace( srcstr=>sql_text(i), pattern=>'^\s*create(\s+or\s+replace)?(\s+NONEDITIONABLE|\s+EDITIONABLE)?', modifier=>'i'); end loop;
      ppsl:=dbms_preprocessor.get_post_processed_source(ppsl);
      for i in ppsl.first..ppsl.last loop code:=code||ppsl(i); end loop;
    worker.package_compiled(i_object_name => dictionary_obj_name, i_schema_name => dictionary_obj_owner, i_object_code => code);
    end get_source_code_explicit;
  end if;

  -- analyze package content v2
  if dictionary_obj_type = 'PACKAGE' and ora_sysevent = 'ALTER' then
    <<get_source_code_implicit>>
    declare
      code     clob;
    begin
    l('DDL_ON_PACKAGE> DDL event trigger fired ('||ora_sysevent||' '||lower(dictionary_obj_type)||' '||dictionary_obj_owner||'.'||dictionary_obj_name||')');
      code:=worker.object_code(i_schema_name => dictionary_obj_owner, i_package_name => dictionary_obj_name);
    worker.package_compiled(i_object_name => dictionary_obj_name, i_schema_name => dictionary_obj_owner, i_object_code => code);
    end get_source_code_implicit;
  end if;

  -- remove everything related to package
  if dictionary_obj_type = 'PACKAGE' and ora_sysevent  = 'DROP' then
    l('DDL_ON_PACKAGE> DDL event trigger fired ('||ora_sysevent||' '||lower(dictionary_obj_type)||' '||dictionary_obj_owner||'.'||dictionary_obj_name||')');
    worker.package_removed(i_object_name => dictionary_obj_name, i_schema_name => dictionary_obj_owner);
  end if;

  -- remove everything related to user
  if dictionary_obj_type = 'USER' and ora_sysevent = 'DROP' then
    l('DDL_ON_PACKAGE> DDL event trigger fired ('||ora_sysevent||' '||lower(dictionary_obj_type)||' '||dictionary_obj_name||')');
    worker.user_dropped(i_schema_name => dictionary_obj_name);
  end if;

exception when others then
  declare
    l_obj varchar2(32767 char);
  begin
    l_obj:=regexp_substr(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, ': at ("(.*)", line ([0-9]+))',1,1,null,1);
    l('DDL_ON_PACKAGE> DDL event trigger exception raised ('||case when l_obj is not null then 'in '||l_obj||' 'end
                                                            ||'with '||SQLERRM||')');
    exception when others then null;
  end;
end;
