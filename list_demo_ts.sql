-- -----------------------------------------------------------------------------
-- OCM 12C Exam Preparation Script:
--   Data and Performance Management
--     Create a plugged-in tablespace by using the transportable tablespace feature
--       List DEMO TS
--
-- -----------------------------------------------------------------------------
SET VERIFY OFF
DEFINE ts_name="DEMO"
DEFINE user_name="DEMO"
-- -----------------------------------------------------------------------------
-- Display name of current database
-- -----------------------------------------------------------------------------
COLUMN db_name NOPRINT NEW_VALUE db_name
SELECT
    name AS db_name
FROM
    v$database;
SPOOL list_demo_ts_&&db_name.
PROMPT Current database name is &&db_name..
-- -----------------------------------------------------------------------------
-- See if DEMO tablespace exists
-- -----------------------------------------------------------------------------
COLUMN ts_exists_msg NOPRINT NEW_VALUE ts_exists_msg
SELECT
        CASE COUNT(tablespace_name)
            WHEN 1   THEN 'exists'
            ELSE 'does not exist'
        END
    AS ts_exists_msg
FROM
    dba_tablespaces
WHERE
    tablespace_name = '&&ts_name.';
PROMPT &&ts_name. tablespace &&ts_exists_msg. in &&db_name. database.
-- -----------------------------------------------------------------------------
-- Find the owner(s) of all segments in the DEMO tablespace
-- -----------------------------------------------------------------------------
COLUMN owner FORMAT A25
PROMPT Find the owner(s) of all segments in the &&ts_name. tablespace
SELECT DISTINCT
    owner
FROM
    dba_segments
WHERE
    tablespace_name = '&&ts_name.';
-- -----------------------------------------------------------------------------
-- See if DEMO user exists
-- -----------------------------------------------------------------------------
COLUMN user_exists_msg NOPRINT NEW_VALUE user_exists_msg
SELECT
        CASE COUNT(username)
            WHEN 1   THEN 'exists'
            ELSE 'does not exist'
        END
    AS user_exists_msg
FROM
    dba_users
WHERE
    username = '&&user_name.';
PROMPT &&user_name. user &&user_exists_msg. in &&db_name. database.
-- -----------------------------------------------------------------------------
-- Show the system privileges of the DEMO user
-- -----------------------------------------------------------------------------
COLUMN owner FORMAT A25
PROMPT Show the system privileges of the &&user_name. user
SELECT
    privilege
FROM
    dba_sys_privs
WHERE
    grantee = '&&user_name.';
-- -----------------------------------------------------------------------------
-- Count the number of segments owned by the DEMO user
-- -----------------------------------------------------------------------------
COLUMN num_segs NOPRINT NEW_VALUE num_segs
SELECT
    COUNT(*) AS num_segs
FROM
    dba_segments
WHERE
    owner = '&&user_name.';
PROMPT &&user_name. owns &&num_segs. segments
-- -----------------------------------------------------------------------------
-- Show the segments owned by the DEMO user
-- -----------------------------------------------------------------------------
COLUMN segment_name    FORMAT A25
COLUMN tablespace_name FORMAT A25
PROMPT Show the segments owned byhe &&user_name. user
SELECT
    segment_name,
    tablespace_name
FROM
    dba_segments
WHERE
    owner = 'DEMO';
-- -----------------------------------------------------------------------------
-- Exit
-- -----------------------------------------------------------------------------
EXIT
