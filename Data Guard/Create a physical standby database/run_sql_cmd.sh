#!/bin/bash
# ------------------------------------------------------------------------------
# DESCRIPTION: Runs a SQL*Plus command against the local database instance.
#
#              Assumes ORACLE_SID and ORACLE_HOME have been set correctly.
#
# USAGE:       run_sql_cmd "SELECT * FROM DUAL;"
#
# RETURNS:     Error code from SQL*Plus call
# ------------------------------------------------------------------------------

run_sql_cmd() 
{
  ${ORACLE_HOME}/bin/sqlplus -L -S / as sysdba <<-DONE
  SET HEADING OFF
  WHENEVER SQLERROR EXIT SQL.SQLCODE
  WHENEVER OSERROR EXIT FAILURE
  $* 
  EXIT
DONE

  return $?
}
