create or replace type stdpub authid current_user as object (
  schema_name   varchar2(30 char),
  package_name  varchar2(30 char),
  not instantiable member function about     return varchar2,
  not instantiable member function output    return blob,
  not instantiable member function mime_type return varchar2
) not instantiable not final;