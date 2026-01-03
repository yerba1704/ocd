clear screen

  /*********************************/
 /** UNINSTALL ora*CODEDOC (OCD) **/
/*********************************/

whenever sqlerror exit failure rollback
whenever oserror exit failure rollback

set serveroutput on
set feedback on
set echo off
set heading off
set verify off

--------------------------------------------------------------------------------
prompt >>> drop user

drop user ocd cascade;

--------------------------------------------------------------------------------
prompt >>> done <<<