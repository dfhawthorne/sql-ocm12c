-- -----------------------------------------------------------------------------
-- OCM 12C Exam Preparation Script:
--   General Database and Network Administration, and Backup Strategy
--     Create and manage users, roles, and privileges
--       Create Common User
--
-- (1) Must connect to JAR database instance running on PERSONAL
-- -----------------------------------------------------------------------------
ALTER SESSION SET CONTAINER=cdb$root;
CREATE USER "C##DOUG"
    PROFILE "DEFAULT"
    IDENTIFIED BY "&PW."
    DEFAULT TABLESPACE "USERS"
    TEMPORARY TABLESPACE "TEMP"
    QUOTA UNLIMITED ON "USERS"
    ACCOUNT UNLOCK
    CONTAINER=ALL;
