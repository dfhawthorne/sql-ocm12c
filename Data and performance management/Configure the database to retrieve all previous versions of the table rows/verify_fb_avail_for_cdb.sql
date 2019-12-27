-- -----------------------------------------------------------------------------
-- Script to verify that database is configured correctly for flashback query at
--   the CDB level.
--
-- 1. Database must be in ARCHIVELOG mode
-- 2. Automatic Undo Management must be configured and enabled
-- 3. Supplemental logging is enabled
--
-- Error messages:
--   ORA-20000 Database must be in ARCHIVELOG mode.
--   ORA-20001 Undo management must be AUTOMATIC.
--   ORA-20002 Undo tablespace must be defined.
--   ORA-20003 Undo retention must be defined.
--   ORA-20004 Supplemental logging must be enabled.
-- -----------------------------------------------------------------------------

WHENEVER SQLERROR EXIT FAILURE ROLLBACK

-- -----------------------------------------------------------------------------
-- Database must be in ARCHIVELOG mode
-- -----------------------------------------------------------------------------

PROMPT Verify that database is in ARCHIVELOG mode
DECLARE
  l_log_mode
    VARCHAR2(12) := NULL;
BEGIN
  SELECT log_mode INTO l_log_mode FROM v$database;
  IF l_log_mode <> 'ARCHIVELOG' THEN
    raise_application_error(
      -20000,
      'Database must be in ARCHIVELOG mode.',
      FALSE
      );
  END IF;
END;
/

-- -----------------------------------------------------------------------------
-- Automatic Undo Management must be configured and enabled
-- -----------------------------------------------------------------------------

PROMPT Verify that Automatic Undo Management in configured and enabled
DECLARE
  CURSOR cur_parm IS
    SELECT
        name,
        "VALUE"
      FROM
        v$parameter
      WHERE
          con_id = 1
        AND
          regexp_like(name,'^undo_','i');
BEGIN
  FOR l_parm IN cur_parm
  LOOP
    IF l_parm.name = 'undo_management' AND l_parm.value != 'AUTO' THEN
      raise_application_error(
        -20001,
        'Undo management must be AUTOMATIC.',
        FALSE
        );
    END IF;
    IF l_parm.name = 'undo_tablespace' AND l_parm.value IS NULL THEN
      raise_application_error(
        -20002,
        'Undo tablespace must be defined.',
        FALSE
        );
    END IF;
    IF l_parm.name = 'undo_retention' AND l_parm.value IS NULL THEN
      raise_application_error(
        -20003,
        'Undo retention must be defined.',
        FALSE
        );
    END IF;
  END LOOP;
END;
/
-- -----------------------------------------------------------------------------
-- Supplemental logging is enabled
-- -----------------------------------------------------------------------------

PROMPT Verify that supplemental logging is enabled
DECLARE
  l_log_data_min VARCHAR2(8);
  l_log_data_pk  VARCHAR2(3);
  l_log_data_ui  VARCHAR2(3);
  l_log_data_fk  VARCHAR2(3);
  l_log_data_all VARCHAR2(3);
  l_log_data_pl  VARCHAR2(3);
BEGIN
  SELECT
      supplemental_log_data_min,
      supplemental_log_data_pk,
      supplemental_log_data_ui,
      supplemental_log_data_fk,
      supplemental_log_data_all,
      supplemental_log_data_pl
    INTO
      l_log_data_min,
      l_log_data_pk,
      l_log_data_ui,
      l_log_data_fk,
      l_log_data_all,
      l_log_data_pl
    FROM
      v$database;
  IF l_log_data_min = 'NO' THEN
    raise_application_error(
      -20004,
      'Supplemental logging must be enabled.',
      FALSE
      );
  END IF;
END;
/

-- -----------------------------------------------------------------------------
-- All done
-- -----------------------------------------------------------------------------

