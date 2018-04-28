#!/bin/sh
# ------------------------------------------------------------------------------
# OCM 12C Upgrade Practice
#   Data and Performance Management
#     Create a plugged-in tablespace by using the transportable tablespace
#         feature
#
# Transport DEMO Tablespace
# ------------------------------------------------------------------------------
# Set up Oracle environment
# ------------------------------------------------------------------------------
export ORAENV_ASK=NO
export ORACLE_SID=personal
. oraenv
export NLS_DATE_FORMAT="YYYY/MM/DD HH24:MI:SS"
# ------------------------------------------------------------------------------
# Perform Transport Tablespace Check
# ------------------------------------------------------------------------------
sqlplus / as sysdba @"Check Transport Set is Self Contained.sql"
# ------------------------------------------------------------------------------
# Create directories for transport tablespaces
# ------------------------------------------------------------------------------
mkdir -p /opt/app/oracle/oradata/transport
mkdir -p /opt/app/oracle/oradata/auxdata
# ------------------------------------------------------------------------------
# Use RMAN to create transport tablespace set
# ------------------------------------------------------------------------------
rman target / nocatalog log=transport_demo.log append \
    cmdfile="Create_Transport_Set_for_DEMO.rcv"