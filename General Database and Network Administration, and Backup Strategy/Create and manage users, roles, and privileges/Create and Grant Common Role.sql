-- -----------------------------------------------------------------------------
-- OCM 12C Exam Preparation Script:
--   General Database and Network Administration, and Backup Strategy
--     Create and manage users, roles, and privileges
--       Create and Grant Common Role
--
-- (1) Must connect to JAR database instance running on PERSONAL
-- -----------------------------------------------------------------------------
ALTER SESSION SET CONTAINER=cdb$root;
CREATE ROLE c##yaocm CONTAINER=ALL;
-- -----------------------------------------------------------------------------
-- Grant Role to Common User in the current container
-- -----------------------------------------------------------------------------
GRANT c##yaocm TO c##doug;
-- -----------------------------------------------------------------------------
-- Display role privileges for common user
-- -----------------------------------------------------------------------------
SELECT * FROM cdb_role_privs WHERE grantee = 'C##DOUG';
-- -----------------------------------------------------------------------------
-- Grant Role to Common User in all containers
-- -----------------------------------------------------------------------------
GRANT c##yaocm TO c##doug CONTAINER=ALL;
-- -----------------------------------------------------------------------------
-- Display role privileges for common user
-- -----------------------------------------------------------------------------
SELECT * FROM cdb_role_privs WHERE grantee = 'C##DOUG';

