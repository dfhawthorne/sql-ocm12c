#!/bin/sh
# -------------------------------------------------------------------------------
# Runs a scenario to demonstrate loading SQL Plan Baselines into the SQL
# Management Base (SMB) from a SQL Tuning Set (STS).
# -------------------------------------------------------------------------------


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
# DESCRIPTION: Ensure database is open
#
# USAGE:       ensure_db_is_open
#
# RETURNS:     0
#              Exits if the database instance is not open.
# -----------------------------------------------------------------------------

ensure_db_is_open()
{
  db_status=$(run_sql_cmd "SELECT status FROM V\$INSTANCE;" )
  case ${db_status} in
    *"ORA-01034: ORACLE not available"*)
      echo "Startup"
      run_sql_cmd "STARTUP";;
    *"STARTED"*)
      echo "ALTER DATABASE MOUNT;"
      run_sql_cmd "ALTER DATABASE MOUNT;"
      echo "ALTER DATABASE OPEN;"
      run_sql_cmd "ALTER DATABASE OPEN;";;
    *"MOUNTED"*)
      echo "ALTER DATABASE OPEN;"
      run_sql_cmd "ALTER DATABASE OPEN;";;
    *"OPEN"*)
      echo "Database instance is open"
      return 0;;
    *)
      echo "$db_status" >&2
      exit 1;;
  esac

  # Make sure that the database instance is really open
  
  db_status=$(run_sql_cmd "SELECT status FROM V\$INSTANCE;" )
  case ${db_status} in
    *"OPEN"*)
      echo "Database instance is successfully opened";;
    *)
      echo "Database instance is ${db_status}" >&2
      exit 1;;
  esac

  return 0
}

# -------------------------------------------------------------------------------
# Save current working directory and change it to where this script is stored.
# -------------------------------------------------------------------------------

cwd=$(dirname "${0}")
pushd "${cwd}" >/dev/null

# -------------------------------------------------------------------------------
# Ensure Database is open and run the scenario
# -------------------------------------------------------------------------------

ensure_db_is_open

[ -r run_scenario_load_smb_from_sts.sql ] && \
  run_sql_cmd "@run_scenario_load_smb_from_sts"

popd >/dev/null

exit 0
