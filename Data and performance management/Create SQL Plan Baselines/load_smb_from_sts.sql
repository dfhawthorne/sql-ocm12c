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
      := 'LOAD_AWR_INTO_SMB';
  csr_hr_sql
    DBMS_SQLTUNE.SQLSET_CURSOR;
  l_plan_cnt
    NUMBER;
BEGIN
  -- Create STS
  DBMS_SQLTUNE.CREATE_SQLSET (
    sqlset_name  => c_tuning_set_name,
    description  => 'STS to store SQL from AWR captured during q1_group_by tests' 
  );
  -- Locate Relevant SQL
  OPEN csr_hr_sql FOR
     SELECT VALUE(P)
     FROM table(
       DBMS_SQLTUNE.SELECT_CURSOR_CACHE(
         'parsing_schema_name = ''HR''',
          NULL, NULL, NULL, NULL, 1, NULL,
         'ALL')) P;
  -- Load SQL statments into STS
  DBMS_SQLTUNE.LOAD_SQLSET(
    sqlset_name     => c_tuning_set_name,
    populate_cursor => csr_hr_sql
  );
  -- Close cursor
  CLOSE csr_hr_sql;
  -- Load STS into SMB
  l_plan_cnt := DBMS_SPM.LOAD_PLANS_FROM_SQLSET(
    sqlset_name  => c_tuning_set_name,
    basic_filter => 'sql_text like ''SELECT /* q1_group_by */%'''
  );
  -- Drop STS
  DBMS_SQLTUNE.DROP_SQLSET (
    sqlset_name  => c_tuning_set_name
  );
END;
/
           
