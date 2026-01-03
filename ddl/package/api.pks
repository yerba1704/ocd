create or replace package api authid current_user
-- Interface package for using ora* CODEDOC.
as

  -- Split source code in relevant information and save comments.
  /*
  exec ocd.api.inspect(dbms_metadata.get_ddl('PACKAGE_SPEC', 'API'), 'API');
  */
  procedure inspect(
      i_package_code in clob,
      i_package_name in varchar2,
      i_schema_name  in varchar2 default user);

end api;
/