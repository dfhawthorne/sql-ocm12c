-- -----------------------------------------------------------------------------
-- Get the critical statuses of the standby database in order of occurrence.
-- The last one will be the current state.
-- -----------------------------------------------------------------------------

SELECT
    message
FROM
    v$dataguard_status
    INNER JOIN LATERAL (
        SELECT
            MAX(message_num) AS message_num
        FROM
            v$dataguard_status
        WHERE
            message  IN
                (
                  'MRP0: Background Managed Standby Recovery process started',
                  'Managed Standby Recovery Canceled'
                )
    ) USING ( message_num )
/
