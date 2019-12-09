#!/bin/bash
# ------------------------------------------------------------------------------
# Simple CPU Hog script
# ------------------------------------------------------------------------------

export ORAENV_ASK=NO
export ORACLE_SID=jar
. oraenv
sqlplus / as sysdba <<DONE
alter session set container=$1;
select sum( dbms_random.value() ) from dual connect by level < 1000000;
EXIT
DONE

exit 0
