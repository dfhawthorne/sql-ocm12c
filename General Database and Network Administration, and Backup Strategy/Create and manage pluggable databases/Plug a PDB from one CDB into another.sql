-- -----------------------------------------------------------------------------
-- OCM 12C Exam Preparation Script:
--   General Database and Network Administration, and Backup Strategy
--     Create and manage pluggable databases
--       Plug a PDB from one CDB into another
--
-- (1) Must connect to JAR database instance running on PERSONAL
-- (2) PDB VEGEMITE must already exist in JAR
--     (See "Create a PDB from an existing PDB.sql")
-- -----------------------------------------------------------------------------
-- Close the VEGEMITE PDB, unplug it, and drop i
-- -----------------------------------------------------------------------------
ALTER SESSION SET container=cdb$root;
ALTER PLUGGABLE DATABASE vegemite CLOSE;
ALTER PLUGGABLE DATABASE vegemite UNPLUG INTO 'vegemite.xml';
DROP PLUGGABLE DATABASE vegemite;
-- -----------------------------------------------------------------------------
-- Check the validity of the XML file as follows:
-- -----------------------------------------------------------------------------
SET SERVEROUTPUT ON SIZE UNLIMITED
BEGIN
  IF dbms_pdb.check_plug_compatibility('vegemite.xml', 'VEGEMITE') THEN
    dbms_output.put_line('Pluggable');
  ELSE
    dbms_output.put_line('Not pluggable');
  END IF;
END;
/
-- -----------------------------------------------------------------------------
-- Plug the PDB back in, and open it as follows
--   (NOCOPY is used because the data files are unchanged):
-- -----------------------------------------------------------------------------
CREATE PLUGGABLE DATABASE vegemite USING 'vegemite.xml' NOCOPY;
ALTER PLUGGABLE DATABASE vegemite OPEN READ WRITE;