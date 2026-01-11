clear screen

define ocd_password   = ora0CODEDOCpassword
define ocd_tablespace = sysaux

  /*******************************/
 /** INSTALL ora*CODEDOC (OCD) **/
/*******************************/

whenever sqlerror exit failure rollback
whenever oserror exit failure rollback

set serveroutput on
set feedback on
set echo off
set heading off
set verify off

--------------------------------------------------------------------------------
prompt >>> create ocd user

create user ocd identified by "&ocd_password"
                default tablespace &ocd_tablespace
                quota 100m on &ocd_tablespace;

grant create session,
      create table,
      create sequence,
      create view,
      create procedure,
      create type,
      create trigger,
      administer database trigger
   to ocd;

-- SELECT ANY DICTIONARY => https://dba.stackexchange.com/questions/1295/how-do-i-allow-users-to-see-grants-view-definitions-pl-sql-etc-in-a-database
grant select_catalog_role
   to ocd 
 with admin option;

alter session set current_schema=ocd;
alter session set plsql_warnings='DISABLE:ALL';
--------------------------------------------------------------------------------
prompt >>> install lexer objects
--> NATIVE compilation!
--> https://asktom.oracle.com/ords/f?p=100:11:0::::P11_QUESTION_ID:9546893500346020349
--> https://oracle-base.com/articles/9i/plsql-native-compilation-9i
@lib/modified_code/token.tps
@lib/modified_code/token_table.tps
@lib/modified_code/varchar2_table.pks
@lib/modified_code/plsql_lexer.pks
@lib/modified_code/plsql_lexer.pkb
--------------------------------------------------------------------------------
prompt >>> create minimal logging

@ddl/table/logs.tbl
@ddl/procedure/l.prc
--------------------------------------------------------------------------------
prompt >>> create main objects 1/2

@ddl/table/schema_package.tbl
@ddl/table/package_constant.tbl
@ddl/table/package_exception.tbl
@ddl/table/package_subprogram.tbl
@ddl/table/subprogram_argument.tbl
@ddl/table/subprogram_example.tbl
@ddl/table/package_type.tbl
@ddl/table/type_field.tbl
@ddl/table/content_revision.tbl
@ddl/view/package_component.vw
@ddl/comments.sql

--TODO alter session set plsql_warnings = 'ENABLE:ALL, DISABLE:(5005,5018)';

@ddl/package/api.pks
@ddl/package/worker.pks
@ddl/package/worker.pkb

@ddl/trigger/ddl_on_package.trg
--------------------------------------------------------------------------------
prompt >>> grant necessary roles

@dcl/worker.pks
@dcl/public/api.pks
--------------------------------------------------------------------------------
prompt >>> create main objects 2/2

@ddl/package/api.pkb
--------------------------------------------------------------------------------
prompt >>> done <<<
