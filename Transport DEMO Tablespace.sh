#!/bin/sh
# ------------------------------------------------------------------------------
# OCM 12C Upgrade Practice
#   Data and Performance Management
#     Create a plugged-in tablespace by using the transportable tablespace
#         feature
#
# Transport DEMO Tablespace from PERSONAL database to JAR database on the same
#   host.
#
# There is only enough memory to run one (1) database instance at a time.
#
# Parameters:
#   1: password for SYSTEM on JAR database
# ------------------------------------------------------------------------------
# Set up Oracle environment for PERSONAL Database instance
# ------------------------------------------------------------------------------
export ORAENV_ASK=NO
export ORACLE_SID=personal
. oraenv
export NLS_DATE_FORMAT="YYYY/MM/DD HH24:MI:SS"
# ------------------------------------------------------------------------------
# List information from PERSONAL database
# ------------------------------------------------------------------------------
sqlplus / as sysdba @"list_demo_ts.sql"
# ------------------------------------------------------------------------------
# Perform Transport Tablespace Check
# ------------------------------------------------------------------------------
sqlplus / as sysdba @"Check Transport Set is Self Contained.sql"
# ------------------------------------------------------------------------------
# Create directories for transport tablespaces
# ------------------------------------------------------------------------------
transport_dir=/opt/app/oracle/oradata/transport
mkdir -p ${transport_dir}
rm -f ${transport_dir}/*
mkdir -p /opt/app/oracle/oradata/auxdata
# ------------------------------------------------------------------------------
# Use RMAN to create transport tablespace set
# ------------------------------------------------------------------------------
rman target / nocatalog log=transport_demo.log append \
    cmdfile="Create_Transport_Set_for_DEMO.rcv"
# ------------------------------------------------------------------------------
# Shut down PERSONAL database instance
# ------------------------------------------------------------------------------
sqlplus / as sysdba <<DONE
shutdown immediate
exit
DONE
# ------------------------------------------------------------------------------
# Set up Oracle environment
# ------------------------------------------------------------------------------
export ORAENV_ASK=NO
export ORACLE_SID=jar
. oraenv
# ------------------------------------------------------------------------------
# Start up JAR database instance and create directory in PLUM PDB
# ------------------------------------------------------------------------------
sqlplus / as sysdba <<DONE
startup
alter session set container=plum;
CREATE OR REPLACE DIRECTORY transport_dir AS '${transport_dir}';
exit
DONE
# ------------------------------------------------------------------------------
# Import DEMO tablespace into the PLUM PDB in the JAR database
# ------------------------------------------------------------------------------
ts_file=$(ls ${transport_dir}/*.dbf)
dmp_file=$(basename $(ls ${transport_dir}/*.dmp))
impdp system/$1@plum directory=transport_dir dumpfile=${dmp_file} transport_datafiles=${ts_file} 
# ------------------------------------------------------------------------------
# List information from JAR database
# ------------------------------------------------------------------------------
sqlplus / as sysdba @"list_demo_ts.sql"
# ------------------------------------------------------------------------------
# Shut down JAR database instance
# ------------------------------------------------------------------------------
sqlplus / as sysdba <<DONE
shutdown immediate
exit
DONE
# ------------------------------------------------------------------------------
# Set up Oracle environment
# ------------------------------------------------------------------------------
export ORAENV_ASK=NO
export ORACLE_SID=personal
. oraenv
# ------------------------------------------------------------------------------
# Start up PERSONAL database instance
# ------------------------------------------------------------------------------
sqlplus / as sysdba <<DONE
startup
exit
DONE
