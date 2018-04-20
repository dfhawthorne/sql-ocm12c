-- -----------------------------------------------------------------------------
-- OCM 12C Exam Preparation Script:
--   General Database and Network Administration, and Backup Strategy
--     Create and manage users, roles, and privileges
--       Create CDB No OMF
-- -----------------------------------------------------------------------------
create database jar
user sys identified by "&pw_sys"
user system identified by "&pw_system"
logfile group 1 (
          '/opt/app/oracle/jar/redo1/redo01.log',
          '/opt/app/oracle/jar/redo2/redo01.log')
          size 50m,
        group 2 (
          '/opt/app/oracle/jar/redo1/redo02.log',
          '/opt/app/oracle/jar/redo2/redo02.log')
          size 50m,
        group 3 (
          '/opt/app/oracle/jar/redo1/redo03.log',
          '/opt/app/oracle/jar/redo2/redo03.log')
          size 50m
character set al32utf8 national character set al16utf16
extent management local
  datafile '/opt/app/oracle/jar/oradata/root/system01.dbf'
  size 200m reuse autoextend on next 5m maxsize unlimited
sysaux
  datafile '/opt/app/oracle/jar/oradata/root/sysaux01.dbf'
  size 200m reuse autoextend on next 5m maxsize unlimited
default temporary tablespace temp
  tempfile '/opt/app/oracle/jar/oradata/root/temp01.dbf'
  size 200m reuse autoextend on next 5m maxsize unlimited
undo tablespace undotbs1
  datafile '/opt/app/oracle/jar/oradata/root/undotbs101.dbf'
  size 200m reuse autoextend on next 5m maxsize unlimited
enable pluggable database
seed
  file_name_convert = (
    '/opt/app/oracle/jar/oradata/root',
    '/opt/app/oracle/jar/oradata/seed'
    )
user_data tablespace users
  datafile '/opt/app/oracle/jar/oradata/seed/users01.dbf'
  size 200m reuse autoextend on next 5m maxsize unlimited
/
-- -----------------------------------------------------------------------------
-- Run Scripts to Build Data Dictionary Views
--
-- The following commands are run to build the data dictionary views and system
-- packages:
-- -----------------------------------------------------------------------------
@?/rdbms/admin/catalog.sql
@?/rdbms/admin/catproc.sql
connect system/&pw_system
@?/sqlplus/admin/pupbld.sql
-- -----------------------------------------------------------------------------
-- Install CDB Components
-- -----------------------------------------------------------------------------
connect / as sysdba
@?/rdbms/admin/catcdb.sql

