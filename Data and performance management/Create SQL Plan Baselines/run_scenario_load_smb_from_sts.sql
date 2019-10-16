-- ---------------------------------------------------------------------------------
-- Runs a scenario to load SQL Plan Baselines into the SQL Management Base (SMB)
-- from a SQL Tuning Set (STS) that was populated from the cursor cache.
-- ---------------------------------------------------------------------------------

WHENEVER SQLERROR EXIT FAILURE ROLLBACK

-- Ensure we are not automatically populating the SMB

ALTER SYSTEM SET optimizer_capture_sql_plan_baselines=false SCOPE=BOTH;

-- Connect to the right schema in the right PDB

ALTER SESSION SET CONTAINER=examples;
ALTER SESSION SET CURRENT_SCHEMA=sh;

-- Remove all current SQL Plan Baselines from SMB

@@drop_all_sql_plan_baselines

-- Run the test SQL several times

@@q1_group_by
/
/

-- Load the SQL Plan Baselines into the SMB via a STS

@@load_smb_from_sts.sql

-- Display Summary of SQL Tuning Sets

SET HEADING ON

PROMPT Display Summary of SQL Tuning Sets
COLUMN NAME FORMAT a20
COLUMN COUNT FORMAT 99999
COLUMN DESCRIPTION FORMAT a30

SELECT NAME, STATEMENT_COUNT AS "SQLCNT", DESCRIPTION
FROM   DBA_SQLSET;

-- Display Contents of SMB

PROMPT Display Contents of SMB
COLUMN sql_handle FORMAT A20
COLUMN plan_name  FORMAT A30

SELECT
    sql_handle,
    plan_name
  FROM
    dba_sql_plan_baselines;
