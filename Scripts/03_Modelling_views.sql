/*
=====================================================================
MODELING LAYER: Analytical Views

Purpose:
    This script defines the ANALYTICS / MODELING layer of the Sales Analytics
    project. It transforms CLEAN layer tables into business-ready, 
    analytics-friendly views used for reporting, EDA, and downstream insights.

Views Created:
    • dim_customers
    • dim_products
    • fact_sales

Design Principles:
    • Read-only analytical views (no data mutation)
    • Business logic centralized in views for consistency
    • Built on top of validated CLEAN tables
    • Optimized for exploration, dashboards, and insight generation

Notes:
    These views represent the final semantic layer of the project and are
    intentionally designed to be directly consumed by EDA queries, dashboards,
    or BI tools without additional transformation.
=====================================================================
*/


-- 1. dim_customers
CREATE OR REPLACE VIEW dim_customers AS
SELECT 
	ROW_NUMBER() OVER(ORDER BY c_cust.cst_id) AS customer_key,
	c_cust.cst_id AS customer_id,
	c_cust.cst_key AS customer_number,
	c_cust.cst_firstname AS first_name,
	c_cust.cst_lastname AS last_name,
    e_loc.cntry AS country,
	c_cust.cst_marital_status AS marital_status,
	CASE
		WHEN c_cust.cst_gndr <> 'n/a' THEN c_cust.cst_gndr -- CRM is the Master for gender info
        ELSE COALESCE(e_cust.gen, 'n/a')
    END AS gender,
    e_cust.bdate AS birthdate,
	c_cust.cst_create_date AS create_date
FROM crm_customer_clean c_cust
LEFT JOIN erp_customer_clean e_cust 
	ON c_cust.cst_key = e_cust.cid
LEFT JOIN erp_location_clean e_loc
	ON c_cust.cst_key = e_loc.cid
;

-- 2.dim_products
CREATE OR REPLACE VIEW dim_products AS
SELECT
	ROW_NUMBER() OVER(ORDER BY c_prod.prd_start_dt, c_prod.prd_key) AS product_key,
	c_prod.prd_id AS product_id,
	c_prod.prd_key AS product_number,
	c_prod.prd_nm AS product_name,
	c_prod.cat_id AS category_id,
	e_cat.cat AS category,
	e_cat.subcat AS subcategory,
	e_cat.maintenance,
	c_prod.prd_cost AS cost,
	c_prod.prd_line AS product_line,
	c_prod.prd_start_dt AS start_date
FROM crm_product_clean c_prod
LEFT JOIN erp_category_clean e_cat
	ON c_prod.cat_id= e_cat.id
WHERE c_prod.prd_end_dt IS NULL -- Filter out all historical data
;

-- 3. fact_sales
CREATE OR REPLACE VIEW fact_sales AS
SELECT
	sls_ord_num AS order_number,
    pr.product_key,
	cu.customer_key,
	sls_order_dt AS order_date,
	sls_ship_dt AS shipping_date,
	sls_due_dt AS due_date,
	sls_sales AS sales_amount,
	sls_quantity AS quantity,
	sls_price AS price
FROM crm_sales_clean c_sales
LEFT JOIN dim_products pr
	ON c_sales.sls_prd_key = pr.product_number
LEFT JOIN dim_customers cu
	ON c_sales.sls_cust_id=cu.customer_id
;


