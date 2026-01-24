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
  begin
    l('API.INSPECT> execute inspect procedure ('||i_schema_name||'.'||i_package_name||')');
    worker.split_package(i_schema_name => c_schema_name, i_package_name => c_package_name, i_package_code => c_package_code);
    commit;
    l('API.INSPECT> data inserted successfully ('||i_schema_name||'.'||i_package_name||')');
  end inspect;
----------------------------------------------------------------------------------------------------------------------------------------------------------------
  function information(
      i_package_name in varchar2,
      i_schema_name  in varchar2 default user)
    return clob
  is
    c_package_name constant dbms_id_30 not null:=upper(i_package_name);
    c_schema_name constant dbms_id_30 not null:=upper(i_schema_name);
  begin
  
  -->select * from package_component where package_name='API';
  
    -- vermutlich nach worker "greifen" um auf die eigentlichen daten zuzukommen...
    return '{
  "name":"API",
  "comment_or_code":"Interface package for using ora* CODEDOC.",
  "subprogram":[
    {
      "name":"INSPECT",
      "comment_or_code":"Split source code in relevant information and save comments.",
      "argument":[
        {
          "name":"I_PACKAGE_CODE",
          "comment_or_code": null
        }
      ]
    }
  ]
}';
  end information;
----------------------------------------------------------------------------------------------------------------------------------------------------------------
end api;
/