#!/bin/bash
# ------------------------------------------------------------------------------
# Creates the required directories for an Oracle database
# ------------------------------------------------------------------------------

req_dirs=$(sqlplus -S -L / as sysdba <<DONE
WHENEVER SQLERROR EXIT FAILURE ROLLBACK

SET HEADING  OFF
SET FEEDBACK OFF
SET LINESIZE 32767
SET PAGESIZE 1000

SELECT
    "VALUE"
  FROM
    v\$parameter
  WHERE
    "NAME" IN
      (
        'db_create_file_dest',
        'db_create_online_log_dest_1',
        'db_create_online_log_dest_2',
        'db_create_online_log_dest_3',
        'db_create_online_log_dest_4',
        'db_create_online_log_dest_5',
        'db_recovery_file_dest',
        'audit_file_dest',
        'diagnostic_dest'
      )
/
EXIT
DONE
)

rc=$?
if [ ${rc} -ne 0 ]
then
  printf "%s\n" "Get parameters failed"
  exit 1
fi
   
for dir in $(printf "%s\n" "${req_dirs}" | sort -u)
do
  printf "%s\n" "${dir}"
  mkdir -p "${dir}"
done
