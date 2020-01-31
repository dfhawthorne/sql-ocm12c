REM =============================================================
REM Start a physical standby database
REM ============================================================

STARTUP MOUNT

ALTER DATABASE
    RECOVER MANAGED STANDBY DATABASE
    DISCONNECT FROM SESSION
;

EXIT

