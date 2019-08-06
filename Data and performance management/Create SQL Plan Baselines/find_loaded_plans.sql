-- -----------------------------------------------------------------------------
-- Find plans that were loaded into the plan baseline for the sample SH
--   statement
-- -----------------------------------------------------------------------------

SELECT SQL_HANDLE, SQL_TEXT, PLAN_NAME,
       ORIGIN, ENABLED, ACCEPTED, FIXED 
FROM   DBA_SQL_PLAN_BASELINES
WHERE  SQL_TEXT LIKE '%q1_group%';
