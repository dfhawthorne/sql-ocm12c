-- -----------------------------------------------------------------------------
-- Create the default tablespace for Flashback Data Archive
-- -----------------------------------------------------------------------------
DECLARE
  c_req_ts_name CONSTANT VARCHAR2(128) := 'FDA_DEFAULT';
  l_db_dest     VARCHAR2(1024)         := NULL;
  l_db_dir      VARCHAR2(1024)         := NULL;
  l_ts_name     VARCHAR2(128)          := NULL;
BEGIN
  -- ---------------------------------------------------------------------------
  -- If the required tablespace does not exist, create it.
  -- ---------------------------------------------------------------------------
  BEGIN
    SELECT tablespace_name
    INTO l_ts_name
    FROM dba_tablespaces
    WHERE tablespace_name = c_req_ts_name;
  EXCEPTION
  WHEN no_data_found THEN
    -- -------------------------------------------------------------------------
    -- Create the required tablespace.
    --
    -- Determine if OMF is used. If not, put the data file into the same
    -- directory as that for the SYSTEM tablespace.
    -- -------------------------------------------------------------------------
    SELECT "VALUE"
    INTO l_db_dest
    FROM v$parameter
    WHERE "NAME"  = 'db_create_file_dest';
    IF l_db_dest IS NOT NULL THEN
      EXECUTE immediate 'CREATE BIGFILE TABLESPACE ' || c_req_ts_name;
    ELSE
      SELECT regexp_substr(file_name, '.*/')
      INTO l_db_dir
      FROM dba_data_files
      WHERE TABLESPACE_NAME = 'SYSTEM'
      AND rownum            = 1;
      EXECUTE immediate 'CREATE BIGFILE TABLESPACE ' || c_req_ts_name ||
        ' DATAFILE ''' || l_db_dir || c_req_ts_name || 
        '01.dbf'' SIZE 500M AUTOEXTEND ON NEXT 5M';
    END IF;
  END;
END;
/