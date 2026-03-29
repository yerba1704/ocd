--> wenn - wie in PKG_SAMPLE - procedure kein arg hat, wird die syntax auch nicht in den leftjoin gedöns zusammengebaut, ergo wird keine ausgegeben :(
set pagesize 0
clear screen
    with
      jsn_base as (
      select content_revision.*,
             case when priority_fl=1 then modified_comment_or_code else original_comment_or_code end component_desc,
             case when count(component_name) over (partition by package_id, component_name) > 1 then
              dense_rank() over (partition by package_id, component_name order by component_sequence)
             end as overload
        from content_revision
      ),-- subprogram syntax
      subprogram_base as(
      select  p.owner as sn, 
              p.object_name as pn,
              case when a.position=0 then 'function' end as t,
              lower(a.object_name) as n,
              p.overload as ol,
              lower(a.argument_name) as an,
              case when a.argument_name is not null then lower(a.in_out) end as io,
              case when a.argument_name is not null then
                case when a.data_type='TABLE'
                  then case when type_owner!='PUBLIC' and type_owner!=a.owner then lower(type_owner)||'.' end||lower(a.type_name)
                  else lower(a.data_type)
                end
              end as dt,
            case when a.argument_name is not null then a.defaulted end as df, ----->>> ???
              max(length(a.argument_name)) over (partition by a.owner, a.object_name, p.overload) as al,
              case when a.position=0
                then chr(10)||'  return '||case when a.data_type='TABLE'
                                            then case when type_owner!='PUBLIC' and type_owner!=a.owner then lower(type_owner)||'.' end||lower(a.type_name)
                                            else lower(a.data_type)
                                          end||';'
              end as rv,
              a.position as p,
              a.argument_default as dv
              --> owner.package_name.object_name
        from  dba_procedures p
        left  --> owner.object_name.procedure_name
        join  (
          select arg.*, c.argument_default 
            from dba_arguments arg
            left join
            (
              select schema_name, package_name, subprogram_name as object_name, argument_name,
                     case when count(ps.subprogram_name) over (partition by package_id, ps.subprogram_name) > 1 then
                      dense_rank() over (partition by package_id, ps.subprogram_name order by ps.order_sequence)
                     end as overload,
                     argument_default
                from schema_package sp
                join package_subprogram ps using (package_id)
                join subprogram_argument sa using ( subprogram_id )
            ) c on (arg.owner=c.schema_name 
                and arg.package_name=c.package_name
                and arg.object_name=c.object_name
                and arg.argument_name=c.argument_name
                and decode(arg.overload,c.overload,1,0)=1 )
           where arg.owner='OCD_DEMO'
             and arg.package_name='PKG_SAMPLE'
        ) a on (p.owner=a.owner
            and p.object_name=a.package_name
            and p.procedure_name=a.object_name
--            and p.overload=a.overload)
            and decode(p.overload,a.overload,1,0)=1 )
       where p.procedure_name is not null
         and p.owner='OCD_DEMO'
         and p.object_name='PKG_SAMPLE'
      ), subprogram_detail as (
      select  any_value(sn) as schema_name,
              any_value(pn) as package_name,
              upper(any_value(n)) as component_name,
              'SUBPROGRAM' as component_type,
              nvl(upper(any_value(t)),'PROCEDURE') as component_type_detail,
              any_value(ol ) as overload,
              nvl(any_value(t),'procedure')||' '||any_value(n)||
               case when any_value(an) is not null then '('||chr(10) end||
               listagg(
                case when p>0 then '    '||rpad(an,al,' ')||' '||io||' '||dt||case when dv is not null then ' default '||dv end end,
                ','||chr(10)
               ) within group (order by p)||
               case when any_value(an) is not null then ')' end||
               any_value(rv) as stx
          from subprogram_base
      group by n, ol
      ),
      jsn_l2 as (
      select b.schema_name,
             b.package_name,
             b.component_name,
             coalesce(d.component_type_detail, b.component_type) as component_type,
             b.component_desc,
             b.component_id,
             b.parent_id,
             b.component_sequence,
             b.hierarchical_level,
             d.stx 
        from jsn_base b
        left join subprogram_detail d on (b.schema_name=d.schema_name
                                      and b.package_name=d.package_name
                                      and b.component_name=d.component_name
                                      and b.component_type=d.component_type
                                      and nvl(b.overload,-1)=nvl(d.overload,-1))
      where b.hierarchical_level=2
      ),
      jsn_type_field as (
      select parent_id,
             json_arrayagg(
              json_object (
                key 'name' value component_name,
                key 'type' value '..tbd...',--attr_type_name||case when attr_type_name='VARCHAR2' then '('||length||')' end,--component_type,
                key 'desc' value component_desc
              ) order by component_sequence
             ) as jsn
      from jsn_base
     where hierarchical_level=3 and component_type='FIELD' group by parent_id
      ),
      jsn_subprogram_argument as (
      select parent_id,
             json_arrayagg(
              json_object (
                key 'name' value component_name,
--                key 'type' value component_type,
                key 'desc' value component_desc
              ) order by component_sequence
             ) as jsn
      from jsn_base where hierarchical_level=3 and component_type='ARGUMENT' group by parent_id
      ),
      jsn_subprogram_example as (
      select parent_id,
             json_arrayagg(
              json_object (
                key 'name' value component_name,
--                key 'type' value component_type,
                key 'desc' value component_desc
              ) order by component_sequence
             ) as jsn
      from jsn_base where hierarchical_level=3 and component_type='EXAMPLE' group by parent_id
      )
       select json_query(
              json_object (
                key 'name' value jsn_base.package_name,
                key 'desc' value jsn_base.component_desc,
                key 'components' value json_arrayagg(
                  json_object (
                    key 'name' value jsn_l2.component_name,
                    -- weiter oben via left join subprogram_detail geholt, alle functions haben min. return type und somit greift der join; ergo sind alle restlichen SUBPROGRAMS automatisch procedures...
                    key 'type' value decode(jsn_l2.component_type,'SUBPROGRAM','PROCEDURE',jsn_l2.component_type),
                    key 'desc' value jsn_l2.component_desc,
                    key 'syntax' value jsn_l2.stx,
                    key 'fields' value jsn_type_field.jsn,
                    key 'parameters' value jsn_subprogram_argument.jsn
    --                       ,
    --                       key 'examples'  value jsn_subprogram_example.jsn
                    absent on null
                  ) order by jsn_l2.component_sequence
                returning clob)
              returning clob
              )
              ,'$' returning clob pretty)
              as v
         from jsn_base
         join jsn_l2 on (jsn_base.component_id=jsn_l2.parent_id )
    left join jsn_type_field          on (jsn_l2.component_id=jsn_type_field.parent_id)
    left join jsn_subprogram_argument on (jsn_l2.component_id=jsn_subprogram_argument.parent_id)
--    left join jsn_subprogram_example  on (jsn_l2.component_id=jsn_subprogram_example.parent_id)
      where jsn_base.schema_name='OCD_DEMO' and jsn_base.package_name='APEX_CSS_MODIFIED'
--      where jsn_base.schema_name=c_schema_name and jsn_base.package_name=c_package_name
     group by jsn_base.schema_name, jsn_base.package_name, jsn_base.component_desc;
    