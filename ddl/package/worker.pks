create or replace package worker authid definer
-- Synchronizing comments in packages with OCD data model tables.
as

  -- Executed by Trigger [[DDL_ON_PACKAGE]] when package code is compiled.
  procedure package_compiled(
      i_schema_name in varchar2,
      i_object_name in varchar2,
      i_object_code in clob);
  -- Executed by Trigger [[DDL_ON_PACKAGE]] when an existing package is deleted.
  procedure package_removed(
      i_schema_name in varchar2,
      i_object_name in varchar2);
  -- Executed by Trigger [[DDL_ON_PACKAGE]] when an existing schema user is deleted.
  procedure user_dropped(
      i_schema_name in varchar2);


  -- Get source code from package specification.
  function object_code(
      i_schema_name  in varchar2,
      i_package_name in varchar2)
    return clob;


  -- Split code into separate declaration.
  -- @The schema name.
  -- @The package name.
  -- @The source code from package specification.
  procedure split_package(
      i_schema_name  in varchar2,
      i_package_name in varchar2,
      i_package_code in clob);

  -- Split declaration into data model tables.
  procedure split_declaration (
      i_package_id     in raw,
      i_order_sequence in integer,
      i_block_t        in token_table,
      io_last_type     in out nocopy varchar2,
      io_last_name     in out nocopy varchar2);


  -- Improve content readability and convert datatype.
  function refine_comment(
      i_comment in clob)
    return varchar2;


  -- Extract argument/field comments (if exists) and example code (if exists) and remove it from original comment.
  procedure inspect_subprogram_type_comment(
      io_comment            in out nocopy clob,
      o_argument_or_field_c out nocopy sys.ora_mining_varchar2_nt,
      o_example_c           out nocopy sys.ora_mining_varchar2_nt);


  -- Return all package names comma separated for the user (for use in OCD-APEX).
  function schema_packages(
      i_schema_name in varchar2)
    return clob;

end worker;
/