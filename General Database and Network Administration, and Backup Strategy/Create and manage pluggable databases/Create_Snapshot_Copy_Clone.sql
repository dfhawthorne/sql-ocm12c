REM ============================================================================
REM Clone PDB (VEGEMITER) from VEGEMITE using SNAPSHOT COPY
REM ============================================================================

REM ============================================================================
REM Set System Parameter
REM --------------------
REM
REM In order to use the SNAPSHOT COPY method of PDB cloning, the CLONEDB system
REM parameter must be set to TRUE. This is not a dynamic parameter. The 
REM container instance has to be in NOMOUNT state for this parameter to be
REM changed.
REM ============================================================================

connect / as sysdba
startup nomount
alter system set clonedb=true scope=spfile;
startup force

REM ============================================================================
REM Make Source PDB Read Only
REM -------------------------
REM
REM While any clones exist, the source PDB (VEGEMITE) has to be in READ ONLY
REM mode.
REM ============================================================================

alter pluggable database vegemite close;
alter pluggable database vegemite open read only;

REM ============================================================================
REM Create Snapshot Clone
REM ---------------------
REM
REM Create the clone PDB (VEGEMITER) from VEGEMITE:
REM ============================================================================

create pluggable database vegemiter from vegemite snapshot copy;
alter pluggable database vegemiter open read write;

REM ============================================================================
REM Save PDB States
REM ---------------
REM
REM Ensure the proper open states are kept across startups
REM ============================================================================

alter pluggable database vegemite save state;
alter pluggable database vegemiter save state;

