-- -----------------------------------------------------------------------------
-- OCM 12C Exam Preparation Script:
--   General Database and Network Administration, and Backup Strategy
--     Create and manage users, roles, and privileges
--       Allow Common User to See Some Dynamic Views
--
-- (1) Must connect to JAR database instance running on PERSONAL
-- -----------------------------------------------------------------------------
ALTER SESSION SET CONTAINER=cdb$root;
ALTER USER "C##DOUG" ADD CONTAINER_DATA = ( "PLUM" ) CONTAINER = CURRENT;
-- -----------------------------------------------------------------------------
-- Display the results
-- -----------------------------------------------------------------------------
SELECT
    username,
    default_attr,
    owner,
    object_name,
    all_containers,
    container_name,
    con_id
FROM
    cdb_container_data
WHERE
    username = 'C##DOUG'
ORDER BY
    object_name;
-- -----------------------------------------------------------------------------
-- Display objects only available to C##DOUG in PLUM
-- -----------------------------------------------------------------------------
WITH plum_data AS (
    SELECT
        owner,
        table_name
    FROM
        cdb_tab_privs
    WHERE
        con_id = 3
),jam_data AS (
    SELECT
        owner,
        table_name
    FROM
        cdb_tab_privs
    WHERE
        con_id = 4
) SELECT
    *
  FROM
    (
        SELECT
            *
        FROM
            plum_data
    )
MINUS
( SELECT
    *
  FROM
    jam_data
);
