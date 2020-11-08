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

# ------------------------------------------------------------------------------
# After the standby instance has been confirmed as mounted, determine the
# current state of the redo apply process (MRP).
# Start MRP, if required.
# ------------------------------------------------------------------------------

curr_mrp_state=$(run_sql_cmd @display_mrp_status)

case "${curr_mrp_state}" in
  *"ORA-"*)
    echo "${curr_mrp_state}" >&2
    exit 1
    ;;
  *"no rows selected"* | \
  *"Managed Standby Recovery Canceled"*)
    start_mrp=$(run_sql_cmd "ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT FROM SESSION;")
    printf "%s\n" "${start_mrp}"
    ;;
  *"MRP0: Background Managed Standby Recovery process started"*)
    printf "%s\n" "Physical standby active"
    ;;
  *)
    echo "Unrecognised MRP state" >&2
    echo "${curr_mrp_state}" >&2
    exit 1
    ;;
esac

# ------------------------------------------------------------------------------
# Ensure that MRP has been started successfully.
# ------------------------------------------------------------------------------

final_mrp_state=$(run_sql_cmd @display_mrp_status)

case "${final_mrp_state}" in
  *"MRP0: Background Managed Standby Recovery process started"*)
    printf "%s\n" "Physical standby active"
    ;;
  *)
    echo "Unrecognised MRP state" >&2
    echo "${final_mrp_state}" >&2
    exit 1
    ;;
esac

exit 0
