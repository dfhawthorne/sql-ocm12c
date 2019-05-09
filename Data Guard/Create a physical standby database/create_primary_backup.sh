#!/bin/sh
# ------------------------------------------------------------------------------
# Creates a physical backup of the primary database.
# Creates a paramater file for the standby database.
# Creates a standby control file.
# Updates the TNSNAMES file for the primary and standby databases.
# Transfers files to the standby server.
# ------------------------------------------------------------------------------

run_sql_cmd() ## DESCRIPTION: Runs a SQL*Plus command against the local database
{             ##              instance.
              ##              Assumes ORACLE_SID and ORACLE_HOME have been set
              ##              correctly.
              ## USAGE: run_sql_cmd "SELECT * FROM DUAL;"
              ## RETURNS:     Results of execution
  sqlplus -L -S / as sysdba <<-DONE
  $* 
  EXIT
DONE

  return $?
}

r=$(run_sql_cmd "SELECT status FROM V\$DATABASE\;" )
echo $r
# TODO: Check for "ORA-01034: ORACLE not available"
