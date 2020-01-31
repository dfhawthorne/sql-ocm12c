REM ============================================================
REM Display the database status in the data guard configuration.
REM ============================================================

SET LINESIZE 180
SET PAGESIZE 40
SET HEADING  ON

SELECT
    name,
    db_unique_name,
    open_mode,
    protection_mode,
    protection_level,
    database_role,
    primary_db_unique_name
  FROM
    v$database;
