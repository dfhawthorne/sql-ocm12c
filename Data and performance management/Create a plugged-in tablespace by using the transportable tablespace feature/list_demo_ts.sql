-- -----------------------------------------------------------------------------
-- OCM 12C Exam Preparation Script:
--   Data and Performance Management
--     Create a plugged-in tablespace by using the transportable tablespace feature
--       List DEMO TS
--
-- (1) Must connect to JAR database instance running on PERSONAL
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- See if DEMO tablespace exists
-- -----------------------------------------------------------------------------
SELECT
    tablespace_name
FROM
    dba_tablespaces
WHERE
    tablespace_name = 'DEMO';

-- -----------------------------------------------------------------------------
-- Find the owner(s) of all segments in the DEMO tablespace
-- -----------------------------------------------------------------------------

SELECT DISTINCT
    owner
FROM
    dba_segments
WHERE
    tablespace_name = 'DEMO';

-- -----------------------------------------------------------------------------
-- See if DEMO user exists
-- -----------------------------------------------------------------------------

SELECT
    username
FROM
    dba_users
WHERE
    username = 'DEMO';

-- -----------------------------------------------------------------------------
-- Show the system privileges of the DEMO user
-- -----------------------------------------------------------------------------

SELECT
    privilege
FROM
    dba_sys_privs
WHERE
    grantee = 'DEMO';

-- -----------------------------------------------------------------------------
-- Count the number of segments owned by the DEMO user
-- -----------------------------------------------------------------------------

SELECT
    COUNT(*)
FROM
    dba_segments
WHERE
    owner = 'DEMO';

-- -----------------------------------------------------------------------------
-- Show the segments owned by the DEMO user
-- -----------------------------------------------------------------------------

SELECT
    segment_name,
    tablespace_name
FROM
    dba_segments
WHERE
    owner = 'DEMO';