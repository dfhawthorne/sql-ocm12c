-- -----------------------------------------------------------------------------
-- OCM 12C Exam Preparation Script:
--   General Database and Network Administration, and Backup Strategy
--     Create and manage pluggable databases
--       Create a PDB from the SEED PDB
--
-- (1) Must connect to JAR database instance running on PERSONAL
-- -----------------------------------------------------------------------------
ALTER SESSION SET container = cdb$root;
CREATE PLUGGABLE DATABASE plum ADMIN USER plummer IDENTIFIED BY "Christopher";
ALTER PLUGGABLE DATABASE plum OPEN READ WRITE;
CONNECT plummer/Christopher@localhost/plum.yaocm.id.au