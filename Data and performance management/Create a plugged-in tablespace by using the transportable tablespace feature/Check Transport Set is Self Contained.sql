-- -----------------------------------------------------------------------------
-- OCM 12C Exam Preparation Script:
--   Data and Performance Management
--     Create a plugged-in tablespace by using the transportable tablespace feature
--       Check Transport Set is Self Contained
--
-- (1) Must connect to PERSONAL database instance running on PERSONAL
-- -----------------------------------------------------------------------------
-- Use the following PL/SQL program to see if the DEMO tablespace was
-- self-contained.
-- -----------------------------------------------------------------------------
execute dbms_tts.transport_set_check('DEMO', TRUE)
-- -----------------------------------------------------------------------------
-- To see if there were any violations, run the following query
-- -----------------------------------------------------------------------------
select * from transport_set_violations;
-- -----------------------------------------------------------------------------
-- exit
-- -----------------------------------------------------------------------------
exit