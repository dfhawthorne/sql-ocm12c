#!/bin/sh
# ------------------------------------------------------------------------------
# Creates the files necessary to create a physical standby database by backing
# up the primary database.
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

# ------------------------------------------------------------------------------
# DESCRIPTION: Backup the primary database.
#
# USAGE:       backup_database
#
# RETURNS:     RMAN return code
# ------------------------------------------------------------------------------

backup_database()
{
  rman target / <<DONE
  run {
    allocate channel d1 device type disk;
    allocate channel d2 device type disk;
    backup database archivelog all delete input;
    delete noprompt obsolete;
  }
  backup recovery area to destination '/tmp';
  exit
DONE
}

# ------------------------------------------------------------------------------
# DESCRIPTION: 
#
# USAGE:       create_backup_parameter_file
#
# RETURNS:     
# ------------------------------------------------------------------------------

create_backup_parameter_file()
{
  run_sql_cmd "CREATE PFILE='/tmp/initpadstow.ora' FROM SPFILE;"
}

# ------------------------------------------------------------------------------
# DESCRIPTION: 
#
# USAGE:       create_standby_control_file
#
# RETURNS:     
# ------------------------------------------------------------------------------

create_standby_control_file()
{
  run_sql_cmd "ALTER DATABASE CREATE STANDBY CONTROLFILE AS '/tmp/botany.ctl';"
}

# ------------------------------------------------------------------------------
# DESCRIPTION: 
#
# USAGE:       update_tnsnames_file
#
# RETURNS:     
# ------------------------------------------------------------------------------

update_tnsnames_file()
{
}

# ------------------------------------------------------------------------------
# DESCRIPTION: 
#
# USAGE:       transfer_files_to_standby
#
# RETURNS:     
# ------------------------------------------------------------------------------

transfer_files_to_standby()
{
  tar cvzf /tmp/padstow.gz /tmp/OCM12PRI_PADSTOW
  scp /tmp/botany.ctl botany:/tmp
  scp /tmp/initbotany.ora botany:/tmp
  scp /tmp/padstow.gz botany:/tmp
  scp /opt/app/oracle/product/12.1.0/dbhome_1/dbs/orapwocm12 botany:/opt/app/oracle/product/12.1.0/dbhome_1/dbs
}

# ------------------------------------------------------------------------------
# Creates a physical backup of the primary database.
# Creates a paramater file for the standby database.
# Creates a standby control file.
# Updates the TNSNAMES file for the primary and standby databases.
# Transfers files to the standby server.
# ------------------------------------------------------------------------------

log_file=/dev/null
{
  ensure_db_is_open
  backup_database
  create_backup_parameter_file
  create_standby_control_file
  update_tnsnames_file
  transfer_files_to_standby
} >$log_file