#!/bin/bash
# ------------------------------------------------------------------------------
# Starts up a standby database if needed
#
# Parameters:
#   1: ORACLE_SID
#   2: ORACLE_HOME
# -------------------------------------------------------------------------------

[ -n "$1" ] && export ORACLE_SID=$1
[ -n "$2" ] && export ORACLE_HOME=$2

. $(dirname $0)/run_sql_cmd.sh

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
