#!/bin/sh
# ------------------------------------------------------------------------------
# Converts the Physical Standby database on BOTANY to a snapshot standby.
#
# This scripts runs from the primary site (PADSTOW).
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Environment variables
# ------------------------------------------------------------------------------

REMOTE_DB_ALIAS=botany_dg
REMOTE_DB_NAME=ocm12_botany
LOCAL_DB_NAME=ocm12
SYS_PW=$(cat .pw)

# ------------------------------------------------------------------------------
# Start up local primary database instance, if needed
# ------------------------------------------------------------------------------

primary_status=$(dgmgrl -silent / "show database ${LOCAL_DB_NAME} status")
echo ${primary_status} | \
    grep -qi "ORA-01034" && \
    primary_status=$(dgmgrl -silent / "startup")
    
printf "${primary_status}\n"

# ------------------------------------------------------------------------------
# Start up remote physical standby, if needed
# ------------------------------------------------------------------------------

standby_status=$(dgmgrl -silent / "show database ${REMOTE_DB_NAME} status")
echo ${standby_status} | \
    grep -qi "status = SHUTDOWN" && \
    standby_status=$(dgmgrl -silent sys/${SYS_PW}@${REMOTE_DB_ALIAS} "startup mount")
    
printf "${standby_status}\n"

# ------------------------------------------------------------------------------
# Convert remote physical standby to snapshot standby
# ------------------------------------------------------------------------------

snapshot_status=$(dgmgrl -silent / "convert database ${REMOTE_DB_NAME} to snapshot standby")

printf "${snapshot_status}\n"
