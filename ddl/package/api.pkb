create or replace package body api
as
----------------------------------------------------------------------------------------------------------------------------------------------------------------
  procedure inspect(
      i_package_code in clob,
      i_package_name in varchar2,
      i_schema_name  in varchar2 default user) 
  is
    c_package_code constant clob not null:=i_package_code;
    c_package_name constant dbms_id_30 not null:=upper(i_package_name);
    c_schema_name constant dbms_id_30 not null:=upper(i_schema_name);
    l_package_id schema_package.package_id%type;
  begin
    l('API.INSPECT> execute inspect procedure ('||i_schema_name||'.'||i_package_name||')');
    worker.split_package(i_schema_name => c_schema_name, i_package_name => c_package_name, i_package_code => c_package_code);
    commit;
    l('API.INSPECT> data inserted successfully ('||i_schema_name||'.'||i_package_name||')');
  end inspect;
----------------------------------------------------------------------------------------------------------------------------------------------------------------
end api;
/