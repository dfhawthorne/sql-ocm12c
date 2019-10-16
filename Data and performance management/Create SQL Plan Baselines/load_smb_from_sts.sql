-- -----------------------------------------------------------------------------
-- Load SQL Plan Baselines from a SQL Tuning Set (STS)
--
-- (1) Create STS
-- (2) Load SQL Statements from cursor cache
-- (3) Load STS into SQL Management Base (SMB)
-- (4) Drop STS
--
-- Reference:
--   https://docs.oracle.com/database/121/TGSQL/tgsql_sts.htm#TGSQL526
--   Oracle Database 12.1 Tuning Guide
--     Managing SQLTuning Sets
-- -----------------------------------------------------------------------------

DECLARE
  c_tuning_set_name
    CONSTANT
    VARCHAR2(128)
      := 'LOAD_CACHE_INTO_SMB';
  csr_cached_sql
    DBMS_SQLTUNE.SQLSET_CURSOR;
  l_plan_cnt
    NUMBER;
  l_owner
    VARCHAR2(128)
      := NULL;
BEGIN
  l_owner := sys_context('USERENV', 'CURRENT_SCHEMA');
  -- Create STS
  DBMS_SQLTUNE.CREATE_SQLSET (
    sqlset_name  => c_tuning_set_name,
    description  => 'STS to store SQL from cursor cache captured during q1_group_by tests' 
  );
  -- Locate Relevant SQL
  OPEN csr_cached_sql FOR
     SELECT VALUE(P)
     FROM table(
       DBMS_SQLTUNE.SELECT_CURSOR_CACHE(
         'parsing_schema_name = ''' || l_owner || '''',
          NULL, NULL, NULL, NULL, 1, NULL,
         'ALL')) P;
  -- Load SQL statments into STS
  DBMS_SQLTUNE.LOAD_SQLSET(
    sqlset_name     => c_tuning_set_name,
    populate_cursor => csr_cached_sql,
    sqlset_owner    => l_owner
  );
  -- Close cursor
  CLOSE csr_cached_sql;
  -- Load STS into SMB
  l_plan_cnt := DBMS_SPM.LOAD_PLANS_FROM_SQLSET(
    sqlset_name  => c_tuning_set_name,
    basic_filter => 'sql_text like ''SELECT /* q1_group_by */%''',
    sqlset_owner => l_owner
  );
  -- Drop STS
  DBMS_SQLTUNE.DROP_SQLSET (
    sqlset_name  => c_tuning_set_name,
    sqlset_owner => l_owner
  );
END;
/
           
