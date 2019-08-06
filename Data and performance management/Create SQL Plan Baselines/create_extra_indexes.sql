-- -----------------------------------------------------------------------------
-- Create extra indexes for sample SH statement
-- -----------------------------------------------------------------------------

CREATE INDEX ind_prod_cat_name 
  ON products(prod_category_id, prod_name, prod_id);
CREATE INDEX ind_sales_prod_qty_sold 
  ON sales(prod_id, quantity_sold);
