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
  SET HEADING OFF
  WHENEVER SQLERROR EXIT SQL.SQLCODE
  WHENEVER OSERROR EXIT FAILURE
  $* 
  EXIT
DONE

  return $?
}

# ------------------------------------------------------------------------------
# Ensure database is open
# -----------------------------------------------------------------------------

ensure_db_is_open()
{
  db_status=$(run_sql_cmd "SELECT status FROM V\$INSTANCE;" )
  case ${db_status} in
    *"ORA-01034: ORACLE not available"*)
      run_sql_cmd "STARTUP";;
    *"STARTED"*)
      run_sql_cmd "ALTER DATABASE MOUNT;"
      run_sql_cmd "ALTER DATABASE OPEN;";;
    *"MOUNTED"*)
      run_sql_cmd "ALTER DATABASE OPEN;";;
    *"OPEN"*)
      ;;
    *)
      echo "$db_status"
      exit 1;;
  esac
}

ensure_db_is_open
