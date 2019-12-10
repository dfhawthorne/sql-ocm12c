#!/bin/bash
# ------------------------------------------------------------------------------
# Simple CPU Hog script
# ------------------------------------------------------------------------------

export ORAENV_ASK=NO
export ORACLE_SID=jar
. oraenv
sqlplus / as sysdba @cpu_hog.sql $1 100

exit 0
