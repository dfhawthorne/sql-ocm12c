-- ------------------------------------------------------------------------------
-- Sample SH query used for SQL Plan baselines
--   Ref: https://docs.oracle.com/database/121/TGSQL/tgsql_spm.htm#TGSQL94653
-- -----------------------------------------------------------------------------

  SELECT /* q1_group_by */ prod_name, sum(quantity_sold)
  FROM   products p, sales s
  WHERE  p.prod_id = s.prod_id
  AND    p.prod_category_id =203
  GROUP BY prod_name;
