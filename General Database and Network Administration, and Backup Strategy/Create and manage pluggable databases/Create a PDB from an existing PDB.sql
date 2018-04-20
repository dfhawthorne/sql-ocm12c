-- -----------------------------------------------------------------------------
-- OCM 12C Exam Preparation Script:
--   General Database and Network Administration, and Backup Strategy
--     Create and manage pluggable databases
--       Create a PDB from an existing PDB
--
-- (1) Must connect to JAR database instance running on PERSONAL
-- (2) No need for file name conversion because I am using OMF in JAR
-- -----------------------------------------------------------------------------
ALTER SESSION SET container = cdb$root;
ALTER PLUGGABLE DATABASE jam CLOSE;
ALTER PLUGGABLE DATABASE jam OPEN READ ONLY;
CREATE PLUGGABLE DATABASE vegemite FROM jam;
ALTER PLUGGABLE DATABASE vegemite OPEN;