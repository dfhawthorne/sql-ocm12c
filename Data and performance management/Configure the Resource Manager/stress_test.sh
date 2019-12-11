#!/bin/bash
# ------------------------------------------------------------------------------
# Stress test all PDBs using CPU hog script
# - Parameters:
#     1: CDB resource plan to be tested (defaults to internal plan)
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Set the environment for connection to the JAR CDB
# ------------------------------------------------------------------------------

export ORAENV_ASK=NO
export ORACLE_SID=jar
. oraenv

# ------------------------------------------------------------------------------
# Settings for this stress test
# ------------------------------------------------------------------------------

new_plan_name="${1:-ORA\$INTERNAL_CDB_PLAN}"
new_snap_interval=0

# ------------------------------------------------------------------------------
# Get current settings
# ------------------------------------------------------------------------------

old_plan_name=$(sqlplus -S / as sysdba <<DONE
SET HEADING OFF FEEDBACK OFF
SELECT value FROM v\$parameter WHERE name = 'resource_manager_plan';
EXIT
DONE
)

old_snap_interval=$(sqlplus -S / as sysdba <<DONE
SET HEADING OFF FEEDBACK OFF
SELECT 60*EXTRACT(HOUR FROM snap_interval) + EXTRACT(MINUTE FROM snap_interval) FROM DBA_HIST_WR_CONTROL;
EXIT
DONE
)

# ------------------------------------------------------------------------------
# Change settings, if needed, for this stress test.
# ------------------------------------------------------------------------------

if [ "${new_plan_name}" != "${old_plan_name}" ]
then
sqlplus -S / as sysdba <<DONE
REM Set the appropriate Resource Plan for the CDB
ALTER SYSTEM SET resource_manager_plan="${new_plan_name}";
EXIT
DONE
fi

if [ ${new_snap_interval} -ne ${old_snap_interval} ]
then
sqlplus -S / as sysdba <<DONE
REM Turn off automatic AWR snapshots
EXEC DBMS_WORKLOAD_REPOSITORY.MODIFY_SNAPSHOT_SETTINGS(interval=>${new_snap_interval});
EXIT
DONE
fi

# ------------------------------------------------------------------------------
# Create an AWR snapshot
# ------------------------------------------------------------------------------

start_snap_id=$(sqlplus -S / as sysdba <<DONE
SET HEADING OFF FEEDBACK OFF
REM Take a manual snapshot
SELECT DBMS_WORKLOAD_REPOSITORY.CREATE_SNAPSHOT() FROM DUAL;
EXIT
DONE
)

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

while [ $(jobs | wc -l) -gt 1 ]
do sleep 300
printf "$(date) %3d\n" $(jobs | wc -l)
done

# ------------------------------------------------------------------------------
# Create an AWR snapshot
# ------------------------------------------------------------------------------

end_snap_id=$(sqlplus -S / as sysdba <<DONE
SET HEADING OFF FEEDBACK OFF
REM Take a manual snapshot
SELECT DBMS_WORKLOAD_REPOSITORY.CREATE_SNAPSHOT() FROM DUAL;
EXIT
DONE
)

# ------------------------------------------------------------------------------
# Restore the internal database environment after stress test
# ------------------------------------------------------------------------------

if [ "${new_plan_name}" != "${old_plan_name}" ]
then
sqlplus -S / as sysdba <<DONE
REM Set the appropriate Resource Plan for the CDB
ALTER SYSTEM SET resource_manager_plan="${old_plan_name}";
EXIT
DONE
fi

if [ ${new_snap_interval} -ne ${old_snap_interval} ]
then
sqlplus -S / as sysdba <<DONE
REM Turn off automatic AWR snapshots
EXEC DBMS_WORKLOAD_REPOSITORY.MODIFY_SNAPSHOT_SETTINGS(interval=>${old_snap_interval});
EXIT
DONE
fi

exit 0
