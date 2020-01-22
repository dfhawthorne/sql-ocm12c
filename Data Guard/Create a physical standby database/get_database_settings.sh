#!/bin/bash
# -------------------------------------------------------------------------------
# Get current database settings
#
# Parameters:
#   1: ORACLE_SID
#   2: ORACLE_HOME
# -------------------------------------------------------------------------------

[ ! -z "$1" ] && export ORACLE_SID=$1
[ ! -z "$2" ] && export ORACLE_HOME=$2

${ORACLE_HOME}/bin/sqlplus -S -L / as sysdba <<DONE
WHENEVER SQLERROR EXIT SQL.SQLCODE

SET FEEDBACK OFF HEADING OFF VERIFY OFF LINESIZE 32767

COLUMN name                   NOPRINT NEW_VALUE database_name
COLUMN log_mode               NOPRINT NEW_VALUE log_mode
COLUMN open_mode              NOPRINT NEW_VALUE open_mode
COLUMN protection_mode        NOPRINT NEW_VALUE protection_mode
COLUMN database_role          NOPRINT NEW_VALUE database_role
COLUMN dataguard_broker       NOPRINT NEW_VALUE dataguard_broker
COLUMN guard_status           NOPRINT NEW_VALUE guard_status
COLUMN db_unique_name         NOPRINT NEW_VALUE db_unique_name
COLUMN primary_db_unique_name NOPRINT NEW_VALUE primary_db_unique_name
COLUMN force_logging          NOPRINT NEW_VALUE force_logging

SELECT
    name,
    log_mode, 
    open_mode, 
    protection_mode, 
    database_role, 
    dataguard_broker, 
    guard_status, 
    db_unique_name, 
    primary_db_unique_name, 
    force_logging
  FROM 
    v\$database
;
PROMPT database_name='&&database_name'
PROMPT log_mode='&&log_mode'
PROMPT open_mode='&&open_mode'
PROMPT protection_mode='&&protection_mode'
PROMPT database_role='&&database_role'
PROMPT dataguard_broker='&&dataguard_broker'
PROMPT guard_status='&&guard_status'
PROMPT db_unique_name='&&db_unique_name'
PROMPT primary_db_unique_name='&&primary_db_unique_name'
PROMPT force_logging='&&force_logging'

SELECT
    name || '=''' || value || ''''
  FROM
    v\$parameter
  WHERE
    NAME IN (
      'log_archive_config',
      'log_archive_dest_1',
      'log_archive_dest_2',
      'remote_login_passwordfile',
      'log_archive_format',
      'fal_server',
      'standby_file_management'
    )
  ORDER BY
    name
/

EXIT
DONE
