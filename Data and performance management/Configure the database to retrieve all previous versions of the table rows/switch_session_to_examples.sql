-- -----------------------------------------------------------------------------
-- Switch the current session to the EXAMPLES container
-- -----------------------------------------------------------------------------
DECLARE
  c_req_pdb_name CONSTANT VARCHAR2(64) := 'EXAMPLES';
  l_pdb_name     VARCHAR2(64)          := NULL;
  l_con_id       NUMBER                := NULL;
  l_change_pdb   BOOLEAN               := false;
BEGIN
  -- ---------------------------------------------------------------------------
  -- Get the container ID (CON_ID) for the current session
  -- ---------------------------------------------------------------------------
  SELECT con_id
  INTO l_con_id
  FROM v$session
  WHERE sid   = sys_context('USERENV', 'SID');
  -- ---------------------------------------------------------------------------
  -- The root container (CON_ID=1) is not a PDB. Otherwise, get the name of the
  -- curent container.
  -- ---------------------------------------------------------------------------
  IF l_con_id = 1 THEN
    dbms_output.put_line('Current container is CDB$ROOT');
    l_change_pdb := true;
  ELSE
    SELECT pdb_name INTO l_pdb_name FROM cdb_pdbs WHERE con_id = l_con_id;
    dbms_output.put_line('Current container is ' || l_pdb_name);
    IF l_pdb_name  != c_req_pdb_name THEN
      l_change_pdb := true;
    END IF;
  END IF;
  -- ---------------------------------------------------------------------------
  -- Switch to the required container.
  -- ---------------------------------------------------------------------------
  IF l_change_pdb THEN
    EXECUTE immediate 'alter session set container=' || c_req_pdb_name;
    dbms_output.put_line('Switched current container to ' || c_req_pdb_name);
  END IF;
END;
/