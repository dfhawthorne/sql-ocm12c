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
