-- -----------------------------------------------------------------------------
-- OCM 12C Exam Preparation Script:
--   General Database and Network Administration, and Backup Strategy
--     Migrate a non-CDB to a PDB database
--       Plug a non-CDB using DBMS_PDB
--
-- (1) Must connect to JAR database instance running on PERSONAL
-- -----------------------------------------------------------------------------
-- After connecting to CAN, I ran the following command:
-- exec dbms_pdb.describe('can_db.xml')
-- -----------------------------------------------------------------------------
-- After connecting to JAR, I ran the following PL/SQL block to verify that the
-- export information in 'can_db.xml' was usable to create a PDB called BISCUIT
-- in the JAR CDB:
-- -----------------------------------------------------------------------------
SET SERVEROUTPUT ON SIZE UNLIMITED
BEGIN
  IF dbms_pdb.check_plug_compatibility('can_db.xml', 'biscuit') THEN
    dbms_output.put_line('Pluggable');
  ELSE
    dbms_output.put_line('Not pluggable');
  END IF;
END;
/
-- -----------------------------------------------------------------------------
-- The result should be:
--   Pluggable
-- -----------------------------------------------------------------------------
-- The BISCUIT PDB is created from CAN as follows:
-- -----------------------------------------------------------------------------
CREATE PLUGGABLE DATABASE biscuit USING 'can_db.xml';
-- -----------------------------------------------------------------------------
-- Then, the following script is used to do the conversion from non-CDB to PDB:
-- -----------------------------------------------------------------------------
ALTER SESSION SET CONTAINER=biscuit;
@?/rdbms/admin/noncdb_to_pdb
-- -----------------------------------------------------------------------------
-- However, this fails with ORA-600 as described in Bug 20981713
--
-- The pluggable database, BISCUIT, is opened anyway, but is not usable because
-- of the failed conversion.
-- -----------------------------------------------------------------------------
