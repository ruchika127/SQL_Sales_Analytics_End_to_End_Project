/*
=====================================================================
ETL Script: Raw → Clean Layer

Purpose:
    This script performs the ETL (Extract, Transform, Load) process to populate
    the CLEAN tables from the RAW layer. It applies all business rules and data 
    quality transformations to prepare the dataset for modeling and analytics.

Operations Performed:
    • TRUNCATE clean tables to ensure idempotent loads (no duplication)
    • Transform raw source data (standardization, normalization, derived columns, data enrichment, validation)
    • Load the cleaned and structured data into CLEAN tables

Note:
    In a real production environment, these transformations would typically run inside
    a stored procedure or a scheduled ETL/ELT pipeline (Airflow, SSIS, DBT). For this 
    project, the logic is written explicitly for clarity and transparency. 
=====================================================================
*/

-- 1. CRM Customers
SELECT '>>Truncating Table: crm_customer_clean';
TRUNCATE TABLE crm_customer_clean;
SELECT '>>Inserting Data Into: crm_customer_clean';

INSERT INTO crm_customer_clean(
cst_id,
cst_key,
cst_firstname,
cst_lastname,
cst_marital_status,
cst_gndr,
cst_create_date
)
SELECT 
	cst_id,
	cst_key,
	TRIM(cst_firstname) AS cst_firstname,
	TRIM(cst_lastname) AS cst_lastname,
	CASE 
		WHEN UPPER(TRIM(cst_marital_status )) = 'M' THEN 'Married'
		WHEN UPPER(TRIM(cst_marital_status )) = 'S' THEN 'Single'
		ELSE 'n/a' 
	END AS cst_marital_status,  -- Normalize marital status values to readable format
	CASE 
		WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
		WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
		ELSE 'n/a'
	END AS cst_gndr,  -- -- Normalize gender values to readable format
cst_create_date
FROM 
	(SELECT 
		*, 
		ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
	FROM crm_customer_raw) t
WHERE flag_last=1  -- Select most recent record per customer
;


-- 2. CRM Products
SELECT '>>Truncating Table: crm_product_clean';
TRUNCATE TABLE crm_product_clean;
SELECT '>>Inserting Data Into: crm_product_clean';

INSERT INTO crm_product_clean(
prd_id,
cat_id,
prd_key,
prd_nm,
prd_cost,
prd_line,
prd_start_dt,
prd_end_dt
)
SELECT
	prd_id,
    REPLACE(SUBSTRING(prd_key, 1,5), '-', '_') AS cat_id, -- Extract Category ID
    SUBSTRING(prd_key, 7, LENGTH(prd_key)) AS prd_key,  -- Extract Product key
    prd_nm,
    CASE 
		WHEN prd_cost IS NULL OR TRIM(prd_cost) = '' OR prd_cost<0 THEN 0
        ELSE prd_cost
	END AS prd_cost,
    CASE UPPER(TRIM(prd_line))
		WHEN 'M' THEN 'Mountain'
		WHEN 'R' THEN 'Road'
        WHEN 'S' THEN 'Other Sales'
        WHEN 'T' THEN 'Touring'
        ELSE 'n/a'
    END AS prd_line,  -- Map product line codes to descriptive values
    CAST(prd_start_dt AS DATE) AS prd_start_dt,
    CAST(
		LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt ASC)
        - INTERVAL 1 DAY 
        AS DATE) AS prd_end_dt -- Calculate the end date as one day before the next start date
FROM crm_product_raw
;


-- 3. CRM Sales
SELECT '>>Truncating Table: crm_sales_clean';
TRUNCATE TABLE crm_sales_clean;
SELECT '>>Inserting Data Into: crm_sales_clean';

INSERT INTO crm_sales_clean(
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price
)
SELECT 
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	CASE
		WHEN sls_order_dt<=0 OR sls_order_dt='' OR LENGTH(sls_order_dt)<>8 THEN NULL
        ELSE STR_TO_DATE(sls_order_dt, '%Y%m%d') 
	END AS sls_order_dt,
    
	CASE
		WHEN sls_ship_dt<=0 OR sls_ship_dt='' OR LENGTH(sls_ship_dt)<>8 THEN NULL
        ELSE STR_TO_DATE(sls_ship_dt, '%Y%m%d') 
	END AS sls_ship_dt,
    
	CASE
		WHEN sls_due_dt<=0 OR sls_due_dt='' OR LENGTH(sls_due_dt)<>8 THEN NULL
        ELSE STR_TO_DATE(sls_due_dt, '%Y%m%d') 
	END AS sls_due_dt, 
    
	CASE 
		WHEN sls_sales IS NULL OR sls_sales<=0 OR sls_sales='' OR sls_sales<>sls_quantity*ABS(sls_price)
			THEN sls_quantity*ABS(sls_price)
		ELSE sls_sales
	END AS sls_sales,  -- Recalculate sales if original value is missing or incorrect
	sls_quantity,
	CASE 
		WHEN sls_price IS NULL OR sls_price<=0 OR sls_price='' THEN ROUND(sls_sales/NULLIF(sls_quantity,0))
		ELSE sls_price
	END AS sls_price  -- Derive price if original value is invalid
FROM crm_sales_raw
;


-- 4. ERP customer demographics
SELECT '>>Truncating Table: erp_customer_clean';
TRUNCATE TABLE erp_customer_clean;
SELECT '>>Inserting Data Into: erp_customer_clean';

INSERT INTO erp_customer_clean(cid, bdate, gen)
SELECT
	CASE
		WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
        ELSE cid
	END AS cid,
    CASE
		WHEN bdate>NOW() THEN null
        ELSE DATE(bdate)
	END AS bdate,
    CASE
		WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
        WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
        ELSE 'n/a'
	END AS gen
FROM erp_customer_raw
;


-- 5. ERP location
SELECT '>>Truncating Table: erp_location_clean';
TRUNCATE TABLE erp_location_clean;
SELECT '>>Inserting Data Into: erp_location_clean';

INSERT INTO erp_location_clean (cid, cntry)
SELECT
	REPLACE(cid,'-','') cid,
	CASE
		WHEN TRIM(cntry)='DE' THEN 'Germany'
		WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
		WHEN TRIM(cntry)='' or TRIM(cntry)=' ' or TRIM(cntry) IS NULL THEN 'n/a'
		ELSE TRIM(cntry)
	END AS cntry  -- Normalize and handle missing or blank country codes
FROM erp_location_raw
;


-- 6. ERP product category
SELECT '>>Truncating Table: erp_category_clean';
TRUNCATE TABLE erp_category_clean;
SELECT '>>Inserting Data Into: erp_category_clean';

INSERT INTO erp_category_clean
(id, cat, subcat, maintenance)
SELECT 
	id,
    cat,
    subcat,
    maintenance
FROM erp_category_raw
;




