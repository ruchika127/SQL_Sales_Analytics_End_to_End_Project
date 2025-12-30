/*
=====================================================================
DDL Script: Create Clean Layer Tables

Purpose:
  This script defines the table structures for the CLEAN layer used in the
  Sales Analytics SQL project.

Actions Performed:
  • Creates the CLEAN schema if it does not already exist.
  • Drops existing CLEAN tables (if present) to ensure a fresh rebuild.
  • Re-creates all CLEAN tables with standardized, validated datatypes.

Notes:
  These tables are the target layer for the ETL transformation script.
  CLEAN tables represent validated, standardized source data, but are
  not yet analytically modeled.
=====================================================================
*/

CREATE DATABASE IF NOT EXISTS sales_analytics;
USE sales_analytics;

-- 1. CRM Customers
DROP TABLE IF EXISTS crm_customer_clean;
CREATE TABLE crm_customer_clean (
    cst_id INT,
    cst_key VARCHAR(50),
    cst_firstname VARCHAR(100),
    cst_lastname VARCHAR(100),
    cst_marital_status VARCHAR(20),
    cst_gndr VARCHAR(10),
    cst_create_date DATE
);

-- 2. CRM Products
DROP TABLE IF EXISTS crm_product_clean;
CREATE TABLE crm_product_clean (
    prd_id INT,
    cat_id VARCHAR(50),
    prd_key VARCHAR(50),
    prd_nm VARCHAR(200),
    prd_cost INT,
    prd_line VARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt DATE
);

-- 3. CRM Sales
DROP TABLE IF EXISTS crm_sales_clean;
CREATE TABLE crm_sales_clean (
    sls_ord_num VARCHAR(50),
    sls_prd_key VARCHAR(50),
    sls_cust_id INT,
    sls_order_dt DATE,
    sls_ship_dt DATE,
    sls_due_dt DATE,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT
);

-- 4. ERP customer demographics
DROP TABLE IF EXISTS erp_customer_clean;
CREATE TABLE erp_customer_clean (
    cid VARCHAR(50),
    bdate DATE,
    gen VARCHAR(10)
);

-- 5. ERP location
DROP TABLE IF EXISTS erp_location_clean;
CREATE TABLE erp_location_clean (
    cid VARCHAR(50),
    cntry VARCHAR(50)
);

-- 6. ERP product category
DROP TABLE IF EXISTS erp_category_clean;
CREATE TABLE erp_category_clean (
    id VARCHAR(50),
    cat VARCHAR(50),
    subcat VARCHAR(100),
    maintenance VARCHAR(50)
);
