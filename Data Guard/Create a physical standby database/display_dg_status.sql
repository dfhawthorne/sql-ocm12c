REM ====================================================================
REM Display the status of Data Guard
REM ====================================================================

set feedback off
WHENEVER SQLERROR EXIT SQL.SQLCODE

SET LINESIZE 180 PAGESIZE 100

COLUMN message FORMAT A80

SELECT
    facility,
    severity,
    to_char(timestamp, 'YYYY-MM-DD HH24:MI:SS') AS "TIMESTAMP",
    message
  FROM
    v$dataguard_status
  ORDER BY
    message_num
/
