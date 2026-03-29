set pagesize 0
clear screen
    with
      jsn_base as (
    select content_revision.schema_name, content_revision.package_name,
           content_revision.component_name, content_revision.component_type,
           case when priority_fl=1 then modified_comment_or_code else content_revision.original_comment_or_code end component_desc,
           component_id, parent_id,
           component_sequence,
           content_revision.hierarchical_level
      from content_revision join package_component using (package_id, component_id)
      ), jsn_l2 as (
      select * from jsn_base where hierarchical_level=2
      ), jsn_type_field as (
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
      ), jsn_subprogram_argument as (
      select parent_id,
             json_arrayagg(
              json_object (
                key 'name' value component_name,
--                key 'type' value component_type,
                key 'desc' value component_desc
              ) order by component_sequence
             ) as jsn
      from jsn_base where hierarchical_level=3 and component_type='ARGUMENT' group by parent_id
      ), jsn_subprogram_example as (
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
      select  JSON_QUERY(
      json_object (
                key 'name' value jsn_base.package_name,
                key 'desc' value jsn_base.component_desc,
                key 'components' value json_arrayagg(
                  json_object (
                       key 'name' value jsn_l2.component_name,
key 'type' value jsn_l2.component_type,
                       key 'desc' value jsn_l2.component_desc,
                       key 'fields' value jsn_type_field.jsn,
                       key 'arguments' value jsn_subprogram_argument.jsn,
                       key 'examples'  value jsn_subprogram_example.jsn
                        absent on null
                  ) order by jsn_l2.component_sequence
                )
              ) --as v
              ,'$' RETURNING VARCHAR2(4000) PRETTY)
         from jsn_base
         join jsn_l2 on (jsn_base.component_id=jsn_l2.parent_id )
    left join jsn_type_field          on (jsn_l2.component_id=jsn_type_field.parent_id)
    left join jsn_subprogram_argument on (jsn_l2.component_id=jsn_subprogram_argument.parent_id)
    left join jsn_subprogram_example  on (jsn_l2.component_id=jsn_subprogram_example.parent_id)
      where jsn_base.schema_name='OCD_DEMO' and jsn_base.package_name='PKG_SAMPLE2'
--      where jsn_base.schema_name=c_schema_name and jsn_base.package_name=c_package_name
     group by jsn_base.schema_name, jsn_base.package_name, jsn_base.component_desc;
    