-- ------------------------------------------------------------------------------------------------
-- Drop JAR_CDB_PLAN
-- To be used before rerunning the resource manager plan creation script
-- ------------------------------------------------------------------------------------------------

PROMPT Disable CDB Plan

ALTER SYSTEM SET resource_manager_plan='ORA$INTERNAL_CDB_PLAN' SCOPE=BOTH;

PROMPT Drop resource plan

BEGIN
  DBMS_RESOURCE_MANAGER.CREATE_PENDING_AREA();
  DBMS_RESOURCE_MANAGER.DELETE_CDB_PLAN('jar_cdb_plan');
  DBMS_RESOURCE_MANAGER.VALIDATE_PENDING_AREA();
  DBMS_RESOURCE_MANAGER.SUBMIT_PENDING_AREA();
END;
/
