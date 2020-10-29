#!/bin/bash
# ------------------------------------------------------------------------------
# Calculates the size of a database by adding up all data and temporary files.
#   The size is given in GB.
#
# Parameters:
#   1: ORACLE_SID
#   2: ORACLE_HOME
# -------------------------------------------------------------------------------

[ -n "$1" ] && export ORACLE_SID=$1
[ -n "$2" ] && export ORACLE_HOME=$2

"${ORACLE_HOME}"/bin/sqlplus -S -L / as sysdba <<DONE
WHENEVER SQLERROR EXIT SQL.SQLCODE

SET FEEDBACK OFF HEADING OFF VERIFY OFF LINESIZE 32767

SELECT
    CEIL(
      (
        (SELECT
            SUM(bytes)
          FROM
            v\$datafile
        ) +
        (SELECT
            SUM(bytes)
          FROM
            v\$tempfile
        )
      )/1024/1024/1024
    ) AS gb
  FROM
    dual
;
EXIT
DONE

exit $?
