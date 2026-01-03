create or replace view package_component
as
with collection as (
    select  null                  as parent_id,
            package_id            as component_id,
            'PACKAGE'             as component_type,
            'SCHEMA_PACKAGE'      as table_name,
            'SP'                  as table_code,
            package_name          as component_name,
            package_comment       as comment_or_code,
            0                     as order_sequence,
            created_at            as created_at,
            deprecated_fl         as deprecated_fl,
            deprecate_warning     as deprecate_warning,
            schema_name||'.'||package_name as qualified_name
      from  schema_package
  union all
    select  package_id            as parent_id,
            constant_id           as component_id,
            'CONSTANT'            as component_type,
            'PACKAGE_CONSTANT'    as table_name,
            'PC'                  as table_code,
            constant_name         as component_name,
            constant_comment      as comment_or_code,
            order_sequence        as order_sequence,
            null                  as created_at,
            deprecated_fl         as deprecated_fl,
            deprecate_warning     as deprecate_warning,
            null                  as qualified_name
      from  package_constant
  union all
    select  package_id            as parent_id,
            exception_id          as component_id,
            'EXCEPTION'           as component_type,
            'PACKAGE_EXCEPTION'   as table_name,
            'PE'                  as table_code,
            exception_name        as component_name,
            exception_comment     as comment_or_code,
            order_sequence        as order_sequence,
            null                  as created_at,
            deprecated_fl         as deprecated_fl,
            deprecate_warning     as deprecate_warning,
            null                  as qualified_name
      from  package_exception
  union all
    select  package_id            as parent_id,
            subprogram_id         as component_id,
            'SUBPROGRAM'          as component_type,
            'PACKAGE_SUBPROGRAM'  as table_name,
            'PS'                  as table_code,
            subprogram_name       as component_name,
            subprogram_comment    as comment_or_code,
            order_sequence        as order_sequence,
            null                  as created_at,
            deprecated_fl         as deprecated_fl,
            deprecate_warning     as deprecate_warning,
            null                  as qualified_name
      from  package_subprogram
  union all
    select  subprogram_id         as parent_id,
            argument_id           as component_id,
            'PARAMETER'           as component_type,
            'SUBPROGRAM_ARGUMENT' as table_name,
            'SA'                  as table_code,
            argument_name         as component_name,
            argument_comment      as comment_or_code,
            order_sequence        as order_sequence,
            null                  as created_at,
            -1                    as deprecated_fl,
            null                  as deprecate_warning,
            null                  as qualified_name
      from  subprogram_argument
  union all
    select  subprogram_id         as parent_id,
            example_id            as component_id,
            'EXAMPLE'             as component_type,
            'SUBPROGRAM_EXAMPLE'  as table_name,
            'SE'                  as table_code,
            example_name          as component_name,
            example_code          as comment_or_code,
            order_sequence        as order_sequence,
            null                  as created_at,
            -1                    as deprecated_fl,
            null                  as deprecate_warning,
            null                  as qualified_name
      from  subprogram_example
  union all
    select  package_id            as parent_id,
            type_id               as component_id,
            'TYPE'                as component_type,
            'PACKAGE_TYPE'        as table_name,
            'PT'                  as table_code,
            type_name             as component_name,
            type_comment          as comment_or_code,
            order_sequence        as order_sequence,
            null                  as created_at,
            deprecated_fl         as deprecated_fl,
            deprecate_warning     as deprecate_warning,
            null                  as qualified_name
      from  package_type
  union all
    select  type_id               as parent_id,
            field_id              as component_id,
            'EXAMPLE'             as component_type,
            'TYPE_FIELD'          as table_name,
            'TF'                  as table_code,
            field_name            as component_name,
            field_comment         as comment_or_code,
            order_sequence        as order_sequence,
            null                  as created_at,
            -1                    as deprecated_fl,
            null                  as deprecate_warning,
            null                  as qualified_name
      from  type_field
)
  select connect_by_root component_id   as package_id,
         connect_by_root qualified_name as qualified_name,
         connect_by_root created_at     as created_at,
         level                                             as hierarchical_level,
         rpad('.',(level - 1) * 2, '.') || component_type  as component_type,
         rpad('.',(level - 1) * 2, '.') || component_name      as component_name,
         comment_or_code,
         component_id,
         table_name,
         table_code,
         deprecated_fl,
         deprecate_warning,
         order_sequence
    from collection
   start with parent_id is null
 connect by parent_id = prior component_id
   order siblings by order_sequence;