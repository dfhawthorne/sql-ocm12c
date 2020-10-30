#!/bin/bash
# ------------------------------------------------------------------------------
# Gets the status of data guard instance.
#
# Parameters:
#   1: ORACLE_SID
#   2: ORACLE_HOME
# -------------------------------------------------------------------------------

[ -n "$1" ] && export ORACLE_SID=$1
[ -n "$2" ] && export ORACLE_HOME=$2

dir=$(dirname $0)

"${ORACLE_HOME}"/bin/sqlplus -S -L / as sysdba <<DONE
@"${dir}/display_dg_status.sql"
EXIT
DONE

exit $?
