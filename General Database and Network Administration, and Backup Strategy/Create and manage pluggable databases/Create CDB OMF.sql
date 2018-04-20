-- -----------------------------------------------------------------------------
-- OCM 12C Exam Preparation Script:
--   General Database and Network Administration, and Backup Strategy
--     Create and manage users, roles, and privileges
--       Create CDB OMF
-- -----------------------------------------------------------------------------
create database jar
  user sys identified by "&pw_sys"
  user system identified by "&pw_system"
  logfile group 1 size 50m,
          group 2 size 50m,
          group 3 size 50m
  character set al32utf8 national character set al16utf16
  set default bigfile tablespace
  archivelog
  set time_zone='+10:00'
  extent management local
  default temporary tablespace temp
  default tablespace users
  undo tablespace undotbs1
  enable pluggable database
/
-- -----------------------------------------------------------------------------
-- Install CDB Components
--
-- According to "ORA-01917: User Or Role 'PDB_DBA' Does Not Exist" while
-- creating container enabled (cdb) database manually (Doc ID 1967358.1), the
-- following commands are run to install the CDB components:
-- -----------------------------------------------------------------------------
connect / as sysdba
@?/rdbms/admin/catcdb.sql
connect system/&pw_system
@?/sqlplus/admin/pupbld.sql
