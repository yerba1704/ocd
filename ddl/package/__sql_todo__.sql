-- erstmal nur den subprogramblock, d.h. name (func/proc? pberladung?) + desc + syntx + parametertab? + example + deprecate?
    select case when min(position)=0 then 'FUNCTION' else 'PROCEDURE' end as subprogram_type,
           dp.procedure_name as subprogram_name,
           case when min(position)=0 then 'function ' else 'procedure ' end||lower(dp.procedure_name)
            ||case when any_value(argument_name) is not null then '(' || 'lisagg...' || ')' end
            ||case when min(position)=0 then '  return '||any_value(case when position=0 then lower(data_type) end) end||';'
           as subprogram_type
      from all_procedures dp
 left join all_arguments da on (dp.owner=da.owner and dp.object_name=da.package_name and dp.procedure_name=da.object_name)
 left join subprogram_argument

     where dp.owner='OCD_DEMO' and procedure_name is not null
  group by dp.procedure_name
  ;

select * from       subprogram_argument
;