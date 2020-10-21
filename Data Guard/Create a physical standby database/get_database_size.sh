#!/bin/bash
# ------------------------------------------------------------------------------
# Calculates the size of a database by adding up all data and temporary files.
#   The size is given in GB.
# ------------------------------------------------------------------------------

sqlplus -L -S / as sysdba <<DONE
SET HEADING OFF
SET FEEDBACK OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE
WHENEVER OSERROR EXIT FAILURE

SELECT
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
    )/1024/1024/1024 AS gb
  FROM
    dual
;
EXIT
DONE

exit $?
