-- -----------------------------------------------------------------------------
-- Drop all SQL Plan baselines
--
-- Ref: https://docs.oracle.com/database/121/TGSQL/tgsql_spm.htm#GUID-BA19EA4E-AFEF-4677-B08F-854DE59ED932
--      Oracle Database 12C SQL Tuning Guide
--        Managing SQL Plan Baselines
-- -----------------------------------------------------------------------------

DECLARE
  CURSOR csr_all_baselines IS
    SELECT
        sql_handle,
        plan_name
      FROM
        dba_sql_plan_baselines;
  l_dropped NUMBER;
BEGIN
  FOR l_spb IN csr_all_baselines LOOP
    l_dropped := dbms_spm.drop_sql_plan_baseline(
                   l_spb.sql_handle,
                   l_spb.plan_name
                 );
  END LOOP;
END;
/
