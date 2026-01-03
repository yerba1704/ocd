--> hack to avoid ORA-28702
--------------------------------------------------------------------------------
set feedback off

  alter trigger ddl_on_package disable;

  create procedure tmp authid definer is
  begin
    -- Code Based Access Control (CBAC) 
    execute immediate 'grant select_catalog_role to package ocd.worker';
  end;
  /

  begin tmp; end;
  /

  drop procedure tmp;

  alter package worker compile;

  alter trigger ddl_on_package enable;

  alter trigger ddl_on_package compile;
  
set feedback on

prompt 
prompt Grant succeeded.
prompt 
