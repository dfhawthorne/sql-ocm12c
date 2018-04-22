-- -----------------------------------------------------------------------------
-- OCM 12C Exam Preparation Script:
--   General Database and Network Administration, and Backup Strategy
--     Create and manage users, roles, and privileges
--       Grant Privilege to Common User on One Container
--
-- (1) Must connect to JAR database instance running on PERSONAL
-- -----------------------------------------------------------------------------
ALTER SESSION SET CONTAINER=plum;
GRANT CREATE SESSION TO "C##FRED" CONTAINER=CURRENT;
-- -----------------------------------------------------------------------------
-- Display role privileges for common user
-- -----------------------------------------------------------------------------
SELECT * FROM cdb_sys_privs WHERE grantee = 'C##FRED';

