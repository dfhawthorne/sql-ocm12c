#!/bin/sh
# ------------------------------------------------------------------------------
# Starts up a standby database if needed
# ------------------------------------------------------------------------------

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
# Get the current status of the database instance. It should be MOUNTED for a
#   physical standby to function correctly.
#
# Attempt to get the database instance into MOUNTED if it is not already so.
# ------------------------------------------------------------------------------

db_status=$(run_sql_cmd "SELECT status FROM v\$instance;")

case ${db_status} in
  *"ORA-01034: ORACLE not available"*)
    echo "Startup"
    db_startup=$(run_sql_cmd "STARTUP MOUNT")
    ;;
  *"STARTED"*)
    echo "ALTER DATABASE MOUNT;"
    db_startup=$(run_sql_cmd "ALTER DATABASE MOUNT;")
    ;;
  *"MOUNTED"*)
    echo "Database instance is mounted"
    db_startup="${db_status}"
    ;;
  *)
    echo "$db_status" >&2
    exit 1;;
esac

# ------------------------------------------------------------------------------
# Ensure that the database instance is MOUNTED. If not, write an error message
#   and fail.
# ------------------------------------------------------------------------------

case "${db_startup}" in
  *"ORA-"*)
    echo "${db_startup}" >&2
    exit 1
    ;;
  *)
    ;;
esac

exit 0