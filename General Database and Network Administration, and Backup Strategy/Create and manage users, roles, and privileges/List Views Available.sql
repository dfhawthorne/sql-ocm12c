-- -----------------------------------------------------------------------------
-- OCM 12C Exam Preparation Script:
--   General Database and Network Administration, and Backup Strategy
--     Create and manage users, roles, and privileges
--       List the dynamic views available to C##DOUG on PLUM
--
-- (1) Must connect to JAR database instance running on PERSONAL
-- -----------------------------------------------------------------------------
ALTER SESSION SET container=plum;git stat
WITH
  gv_views AS (
    SELECT
        view_name,
        substr(view_name,4)
          AS stub
      FROM
        all_views
      WHERE
          owner = 'SYS'
        AND
          regexp_like(view_name,'^gv_\$','i')
    ),
  v_views AS (
    SELECT
        view_name,
        substr(view_name,3)
          AS stub
      FROM
        all_views
      WHERE
          owner = 'SYS'
        AND
          regexp_like(view_name,'^v_\$','i')
    )
SELECT
    v_views.view_name
      AS v_view_name,
    gv_views.view_name
      AS gv_view_name
  FROM
      gv_views
    FULL OUTER JOIN
      v_views
    USING (
      stub
      )
  ORDER BY
    v_view_name
;

