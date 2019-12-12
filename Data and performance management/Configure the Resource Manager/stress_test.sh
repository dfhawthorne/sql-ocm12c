#!/bin/bash
# ------------------------------------------------------------------------------
# Stress test all PDBs using CPU hog script
# - Parameters:
#     1: CDB resource plan to be tested (defaults to internal plan)
#     2: File name for AWR report, if required.
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Set the environment for connection to the JAR CDB
# ------------------------------------------------------------------------------

export ORAENV_ASK=NO
export ORACLE_SID=jar
. oraenv

# ------------------------------------------------------------------------------
# Settings for this stress test
# - A snapshot interval of zero (0) disables all snapshots (including manual
#   ones)
# - The chosen snapshot interval (120) is greater than the expected run time of
#   the entire test.
# - Jobs are checked every minute (60 seconds) to give a one (1) minute
#   granualartity to the AWR reports.
# ------------------------------------------------------------------------------

new_plan_name="${1:-ORA\$INTERNAL_CDB_PLAN}"
new_snap_interval=120
job_check_interval=60

# ------------------------------------------------------------------------------
# Get current settings
# ------------------------------------------------------------------------------

raw_old_plan_name=$(sqlplus -S / as sysdba <<DONE
SET HEADING OFF FEEDBACK OFF
SELECT value FROM v\$parameter WHERE name = 'resource_manager_plan';
EXIT
DONE
)

raw_old_snap_interval=$(sqlplus -S / as sysdba <<DONE
SET HEADING OFF FEEDBACK OFF
SELECT 60*EXTRACT(HOUR FROM snap_interval) + EXTRACT(MINUTE FROM snap_interval) FROM DBA_HIST_WR_CONTROL;
EXIT
DONE
)

printf -v old_plan_name "%q" ${raw_old_plan_name}
printf -v old_snap_interval "%d" ${raw_old_snap_interval}
printf "Old values: plan=%s, snap_interval=%d\n" ${old_plan_name} ${old_snap_interval}
printf "New values: plan=%s, snap_interval=%d\n" ${new_plan_name} ${new_snap_interval}

# ------------------------------------------------------------------------------
# Change settings, if needed, for this stress test.
# ------------------------------------------------------------------------------

if [ "${new_plan_name}" != "${old_plan_name}" ]
then
sqlplus -S / as sysdba <<DONE
ALTER SYSTEM SET resource_manager_plan="${new_plan_name}";
EXIT
DONE
fi

if [ ${new_snap_interval} -ne ${old_snap_interval} ]
then
sqlplus -S / as sysdba <<DONE
EXEC DBMS_WORKLOAD_REPOSITORY.MODIFY_SNAPSHOT_SETTINGS(interval=>${new_snap_interval});
EXIT
DONE
fi

# ------------------------------------------------------------------------------
# Create an AWR snapshot
# ------------------------------------------------------------------------------

raw_start_snap_id=$(sqlplus -S / as sysdba <<DONE
SET HEADING OFF FEEDBACK OFF
REM Take a manual snapshot
SELECT DBMS_WORKLOAD_REPOSITORY.CREATE_SNAPSHOT() FROM DUAL;
EXIT
DONE
)

printf -v start_snap_id "%d" ${raw_start_snap_id}
printf "Start snapshot ID=%d\n" ${start_snap_id}

# ------------------------------------------------------------------------------
# Start background jobs to hog the CPU on all selected PDBs
# ------------------------------------------------------------------------------

PDBs="PLUM JAM JAM0 JAM1 VEGEMITE VEGEMITER"
for pdb in $PDBs
do nohup ./cpu_hog.sh $pdb >/dev/null 2>&1 &
done

# ------------------------------------------------------------------------------
# Wait until all jobs have completed
# ------------------------------------------------------------------------------

while [ $(jobs | wc -l) -gt 0 ]
do printf "$(date) %3d jobs are running:\n" $(jobs | wc -l)
jobs
sleep ${job_check_interval}
done
printf "$(date) %3d jobs are running:\n" $(jobs | wc -l)
jobs

# ------------------------------------------------------------------------------
# Create an AWR snapshot
# ------------------------------------------------------------------------------

raw_end_snap_id=$(sqlplus -S / as sysdba <<DONE
SET HEADING OFF FEEDBACK OFF
REM Take a manual snapshot
SELECT DBMS_WORKLOAD_REPOSITORY.CREATE_SNAPSHOT() FROM DUAL;
EXIT
DONE
)

printf -v end_snap_id "%d" ${raw_end_snap_id}
printf "End snapshot ID=%d\n" ${end_snap_id}

# ------------------------------------------------------------------------------
# Restore the internal database environment after stress test
# ------------------------------------------------------------------------------

if [ "${new_plan_name}" != "${old_plan_name}" ]
then
sqlplus -S / as sysdba <<DONE
ALTER SYSTEM SET resource_manager_plan="${old_plan_name}";
EXIT
DONE
fi

if [ ${new_snap_interval} -ne ${old_snap_interval} ]
then
sqlplus -S / as sysdba <<DONE
EXEC DBMS_WORKLOAD_REPOSITORY.MODIFY_SNAPSHOT_SETTINGS(interval=>${old_snap_interval});
EXIT
DONE
fi

# ------------------------------------------------------------------------------
# Produce an AWR Report if a file name is provided
# ------------------------------------------------------------------------------

if [ ! -z "${2}" ]
then
sqlplus -S / as sysdba >${2} <<DONE
SET PAGESIZE 0 LINESIZE 1500 FEEDBACK OFF HEADING OFF VERIFY OFF
column dbid noprint new_value dbid
column instance_number noprint new_value instance_number
select dbid from v\$database;
select instance_number from v\$instance;
select * from
    table(DBMS_WORKLOAD_REPOSITORY.AWR_REPORT_HTML(
        l_dbid       => &dbid.,
        l_inst_num   => &instance_number.,
        l_bid        => ${start_snap_id},
        l_eid        => ${end_snap_id},
        l_options    => 8));
EXIT
DONE
fi

exit 0
