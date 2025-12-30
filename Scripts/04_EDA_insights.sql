/*
====================================================================================================
                           EXPLORATORY DATA ANALYSIS (EDA)
							 Sales Analytics Case Study
Purpose:
    This file contains analytical SQL queries answering key business questions 
    across dimensions, customer behavior, product performance, 
    sales trends, segmentation, acquisition and retention.

How to Read:
    • Each section includes:
        - Section Title
        - Business Purpose
        - SQL Techniques Used
        - Query
        - Insights derived (used later in README / dashboard)

Core Tables / Views Used:
    • fact_sales
    • dim_customers
    • dim_products
    • report_customers (derived view)
    • report_products (derived view)
===================================================================================================
*/

/*
===================================================================================================
SECTION 1: BUSINESS OVERVIEW
===================================================================================================
Purpose: Explore KPI metrics, data distribution, sales performance for a quick business health overview
(overall trends or anomalies).

SQL Functions Used:
    • SUM(), COUNT(), AVG(), MIN(), MAX(), ROUND()
    • GROUP BY, ORDER BY with LIMIT, CROSS JOIN, LEFT JOIN, UNION ALL 
    • TIMESTAMPDIFF(), CURDATE()
===================================================================================================
*/
---------------------------------------------------------------------------------------------------
-- Q1. Generate a report that summarizes key business metrics (sales, orders, customers, products).
---------------------------------------------------------------------------------------------------
SELECT 'Dataset Start Date' AS Metric, MIN(order_date) AS Measure_value FROM fact_sales
UNION ALL
SELECT 'Dataset End Date', MAX(order_date) FROM fact_sales
UNION ALL
SELECT	'Duration_in_months', TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) FROM fact_sales
UNION ALL
SELECT 'Total Sales', SUM(sales_amount) FROM fact_sales
UNION ALL
SELECT 'Total Quantity', SUM(quantity) FROM fact_sales
UNION ALL
SELECT 'Average Price', ROUND(AVG(price),2) FROM fact_sales
UNION ALL
SELECT 'Total Orders', COUNT(DISTINCT order_number) FROM fact_sales
UNION ALL
SELECT 'Total Products', COUNT(DISTINCT product_key) FROM dim_products
UNION ALL
SELECT 'Total Customers', COUNT(*) FROM dim_customers;

-------------------------------------------------------------------------------
-- Q2. What is the geographic distribution of sold items across countries?
-------------------------------------------------------------------------------
SELECT 
	c.country, 
    SUM(f.quantity) AS total_sold_items
FROM fact_sales f
LEFT JOIN dim_customers c
	ON f.customer_key=c.customer_key
GROUP BY c.country
ORDER BY total_sold_items DESC;
-- Insight: Top regions: US, Australia, Canada, UK.
	
-------------------------------------------------------------------------------
-- Q3. Which are the top 5 Revenue-generating (Best-selling) products.
-------------------------------------------------------------------------------
SELECT 
	p.product_name,
    SUM(f.sales_amount) AS total_revenue
FROM fact_sales f
LEFT JOIN dim_products p
	ON f.product_key=p.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC
LIMIT 5;
/* Insight: Top performers are dominated by Mountain-200 variants (Black/Silver, 38–46 size range).
indicating very strong demand for mid-to-premium mountain bikes */

/*
================================================================================================================
SECTION 2: PERFORMANCE OVER TIME 
================================================================================================================
Purpose:
    - Identify growth patterns, declines, seasonality and long-term trends.
    - Measure yearly performance against historical average and Previous year's performance (YoY trend).

SQL Functions Used:
	- CTEs
    - LAG(): Accesses data from previous rows
    - Window Functions: SUM() OVER(), AVG() OVER()
    - CASE: Defines conditional logic for trend analysis
    - YEAR(), MONTH(), DATE_FORMAT()
    - SUM(), AVG(), COUNT(), MIN(), MAX(), DISTINCT(), CONCAT()
=================================================================================================================
*/

-------------------------------------------------------------------------------
-- Q4. How do sales perform over time at yearly and monthly levels?
-------------------------------------------------------------------------------
SELECT
	YEAR(order_date) AS order_year,
	SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customer,
    SUM(quantity) AS total_quantity
FROM fact_sales 
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date);
/* Insights: 2013 is the strongest year. Sales decline sharply in 2014 likely because 
data ends early in 2014.December is the highest revenue month (holiday-driven seasonality). 
February is the lowest. */

------------------------------------------------------------------------------------
-- Q5. Compute monthly revenue trend with running total and moving average price. 
------------------------------------------------------------------------------------
WITH monthly_sales AS (
SELECT
	DATE_FORMAT(order_date, '%Y-%m-01') AS month_start,
	SUM(sales_amount) AS total_sales,
    AVG(price) AS avg_price
FROM fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATE_FORMAT(order_date, '%Y-%m-01')
)
SELECT
	month_start,
    total_sales,
    SUM(total_sales) OVER (PARTITION BY YEAR(month_start) ORDER BY month_start
    ) AS running_total_sales, -- Running cumulative revenue per year
    ROUND(AVG(avg_price) OVER (PARTITION BY YEAR(month_start) ORDER BY month_start),2
    ) AS moving_average_price -- Monthly moving average of price trend
FROM monthly_sales
ORDER BY month_start;
/* Insights: 
1. December is consistently the highest-performing month across all years.
2. 2011–2012 shows declining annual revenue despite stable volumes, likely due to a shift toward lower-cost products.
3. 2013 shows explosive growth (~16M), driven by very high volume at significantly lower average price points.
4. Running totals reveal the company’s strongest acceleration in mid-to-late 2013.
5. Price trends indicate three phases:
     - 2011: Premium pricing era ~ €3200
     - 2012: Mid-price transition period ~ €1,753
     - 2013: High-volume budget strategy ~ €350
*/

------------------------------------------------------------------------------------------------------------------
-- Q6. How does yearly product performance compare against each product’s historical average and prior year (YoY)?
-------------------------------------------------------------------------------------------------------------------
WITH yearly_product_sales AS (
SELECT 
	DATE_FORMAT(f.order_date, '%Y') AS order_year,
    p.product_name,
	SUM(f.sales_amount) AS current_sales
FROM fact_sales f
LEFT JOIN dim_products p
	ON f.product_key=p.product_key
WHERE f.order_date IS NOT NULL
GROUP BY DATE_FORMAT(f.order_date, '%Y'), p.product_name
) 
SELECT 
	order_year,
    product_name,
    current_sales,
    ROUND(AVG(current_sales) OVER(PARTITION BY product_name),0) AS avg_sales,
    current_sales - ( ROUND(AVG(current_sales) OVER(PARTITION BY product_name))) AS diff_from_avg,
    CASE
		WHEN current_sales - ( ROUND(AVG(current_sales) OVER(PARTITION BY product_name))) > 0 THEN 'Above Avg'
        WHEN current_sales - ( ROUND(AVG(current_sales) OVER(PARTITION BY product_name))) < 0 THEN 'Below Avg'
        ELSE 'Avg'
	END avg_change,
	LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS py_sales,
	current_sales - (LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year)) AS diff_from_py,
	CASE
		WHEN current_sales - (LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year)) > 0 THEN 'Increase'
        WHEN current_sales - (LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year)) < 0 THEN 'Decrease'
        ELSE 'No Change'
	END AS yoy_change
FROM yearly_product_sales
ORDER BY product_name, order_year;
/* Insights:
	- 2013 stands out as a breakout year, with most products outperforming their historical averages and 
      showing strong YoY growth across the catalog.
    - 2014 shows a uniform decline for nearly all products, suggesting a market-wide contraction rather than 
      product-specific failure.
    - High-priced bikes: stable revenue, long-term strength
    - Accessories and clothing: highly volatile, hence, potential catalog cleanup or margin optimization */

---------------------------------------------------------------------------------------------------------------
/* Q7. Does product lifecycle length relate to YOY sales performance, and do longer-lived/short-lived products 
show more stable growth patterns?  */
---------------------------------------------------------------------------------------------------------------
WITH product_yearly AS (
    SELECT
        p.product_key,
        p.product_name,
        YEAR(order_date) AS order_year,
        SUM(f.sales_amount) AS yearly_sales
    FROM fact_sales f
    JOIN dim_products p ON f.product_key = p.product_key
    GROUP BY p.product_key, p.product_name, order_year
),
product_lifecycle AS (
    SELECT
        product_key,
        MIN(order_year) AS first_year,
        MAX(order_year) AS last_year,
        MAX(order_year) - MIN(order_year) + 1 AS lifecycle_years
    FROM product_yearly
    GROUP BY product_key
)
SELECT
    y.product_key,
    y.product_name,
    y.order_year,
    y.yearly_sales,
    l.lifecycle_years,
    LAG(y.yearly_sales) OVER(PARTITION BY y.product_key ORDER BY y.order_year) AS prev_year_sales,
    y.yearly_sales -
    LAG(y.yearly_sales) OVER(PARTITION BY y.product_key ORDER BY y.order_year) AS yoy_change
FROM product_yearly y
JOIN product_lifecycle l
    ON y.product_key = l.product_key
ORDER BY y.product_name, y.order_year;
/* Insights: Most products show sharp YoY spikes during their mid-lifecycle years (mainly 2013) followed by steep 
declines in their final year, indicating that demand peaks early and then rapidly fades. Short-lifecycle products 
are especially volatile, while long-lifecycle bikes maintain more stable, predictable sales patterns. */

/*
===============================================================================
SECTION 3: PRODUCT REPORT
===============================================================================
Purpose:
    - Create a reusable, product-level analytical view that consolidates product 
    performance, behaviors, and lifecycle metrics.

Key Metrics Captured:
    • Total orders, sales, quantity sold
    • Unique customers per product
    • Product lifespan and recency
    • Average order revenue (AOR)
    • Average monthly revenue
    • Product performance segmentation (High / Mid / Low)

SQL Techniques Used:
    - Create View
    - CTEs
    - SUM() OVER()
    - CROSS JOIN, LEFT JOIN, CASE, GROUP BY, ORDER BY
    - SUM(), COUNT(), MIN(), MAX(), AVG(), DISTINCT()
    - CAST(), NULLIF(), TIMESTAMPDIFF(), MONTH()
===============================================================================
*/
CREATE OR REPLACE VIEW report_products AS
WITH base_query AS (
    SELECT 
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost,
        f.customer_key,
        f.order_number,
        f.order_date,
        f.sales_amount,
        f.quantity
    FROM fact_sales f
    LEFT JOIN dim_products p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL    
),
product_aggregations AS (
    SELECT
        product_key,
        product_name,
        category,
        subcategory,
        cost,
        TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan_in_months,
        MAX(order_date) AS last_sale_date,
        COUNT(DISTINCT order_number) AS total_orders,
        COUNT(DISTINCT customer_key) AS total_customers,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity_sold,
        AVG(CAST(sales_amount AS FLOAT)/NULLIF(quantity,0)) AS avg_selling_price
    FROM base_query
    GROUP BY product_key, product_name, category, subcategory, cost
),
max_date AS (
    SELECT MAX(order_date) AS dataset_last_date
    FROM fact_sales
)
SELECT
    pa.product_key,
    pa.product_name,
    pa.category,
    pa.subcategory,
    pa.cost,
    pa.last_sale_date,
    TIMESTAMPDIFF(
        MONTH,
        pa.last_sale_date,
        m.dataset_last_date
    ) AS recency_in_months,
    pa.lifespan_in_months,
    CASE
        WHEN pa.total_sales > 50000 THEN 'High-Performer'
        WHEN pa.total_sales >= 10000 THEN 'Mid-Range'
        ELSE 'Low-Performer'
    END AS product_segment,
    pa.total_sales,
    pa.total_orders,
    pa.total_quantity_sold,
    pa.total_customers,
    pa.avg_selling_price,
    CASE 
        WHEN pa.total_orders = 0 THEN 0
        ELSE pa.total_sales / pa.total_orders
    END AS avg_order_revenue,
    CASE 
        WHEN pa.lifespan_in_months = 0 THEN pa.total_sales
        ELSE pa.total_sales / pa.lifespan_in_months
    END AS avg_monthly_revenue
FROM product_aggregations pa
CROSS JOIN max_date m;

-------------------------------------------------------------------------------
-- Q8. Which product categories contribute the most to overall revenue?
-------------------------------------------------------------------------------
WITH category_sales AS (
SELECT 
	p.category,
    SUM(f.sales_amount) AS total_sales
FROM fact_sales f
LEFT JOIN dim_products p
	ON f.product_key= p.product_key
GROUP BY p.category)
SELECT 
	category,
    total_sales,
    SUM(total_sales) OVER() AS overall_sales,
    CONCAT(ROUND((total_sales/SUM(total_sales) OVER()) *100,2), '%') AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC;
/* Insights:
	1. Category "Bikes" dominates revenue 96.46% (~28.3M EUR).
	2. Accessories & Clothing contribute far less → potential upsell opportunity.
    3. This creates both opportunity (focus on best-sellers) and risk (high category concentration). */

---------------------------------------------------------------------------------------------
-- Q9. How are products distributed across cost ranges?
---------------------------------------------------------------------------------------------
WITH product_segment AS (
	SELECT 
		product_key,
		product_name,
		cost,
		CASE
			WHEN cost<100 THEN 'Below 100'
			WHEN cost BETWEEN 100 AND 500 THEN '100-500'
			WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
			ELSE 'Above 1000'
		END AS cost_range
	FROM dim_products
)
SELECT 
	cost_range,
    COUNT(product_key) AS total_products
FROM product_segment
GROUP BY cost_range
ORDER BY total_products DESC;
/* Insights: Over 70% of products cost below 500, while only a small fraction (≈15%) fall above 1000,
indicating a catalogue dominated by budget-friendly SKUs rather than premium offerings. */

/*
===========================================================================================
SECTION 4: CUSTOMER REPORT
===========================================================================================
Purpose:
    - Build a reusable customer-level analytical view capturing purchase behavior,
    value contribution, and engagement patterns.

Key Metrics Captured:
    • Total orders, sales, quantity, and product diversity
    • Customer lifespan and recency
    • Average order value (AOV)
    • Average monthly spend
    • Customer segmentation (VIP / Regular / New)
    • Age-group segmentation

SQL Techniques Used:
    - Create View
    - CTEs
    - CROSS JOIN, LEFT JOIN, CASE, GROUP BY, ORDER BY
    - SUM(), COUNT(), MIN(), MAX(), AVG(), DISTINCT(), ROUND()
    - CONCAT(), CAST(), NULLIF(), TIMESTAMPDIFF(), YEAR(), MONTH(), NOW()
===========================================================================================
*/

CREATE OR REPLACE VIEW report_customers AS
WITH base_query AS (
-- ----------------------------------------------------------------------------------------
-- Base query: Retrieves all columns from tables
-- ----------------------------------------------------------------------------------------
SELECT
	f.order_number,
    f.product_key,
    f.order_date,
    f.sales_amount,
    f.quantity,
    c.customer_key,
    c.customer_number,
	CONCAT(c.first_name, ' ', c.last_name) customer_name,
    TIMESTAMPDIFF(YEAR, c.birthdate, NOW()) age
FROM fact_sales f
LEFT JOIN dim_customers c
	ON f.customer_key=c.customer_key
WHERE f.order_date IS NOT NULL
),
customer_aggregation AS (
-- ----------------------------------------------------------------------------------------
-- Customer aggregation: Summarizes key metric at customer level
-- ----------------------------------------------------------------------------------------
	SELECT 
		customer_key,
		customer_number,
		customer_name,
		age,
		COUNT(DISTINCT order_number) AS total_orders,
		SUM(sales_amount) AS total_sales,
		SUM(quantity) AS total_quantity_purchased,
		COUNT(DISTINCT product_key) AS total_products,
		MAX(order_date) AS last_order_date,
		TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) lifespan_in_months
	FROM base_query
	GROUP BY customer_key, customer_number, customer_name, age
),
max_date AS (
    SELECT MAX(order_date) AS dataset_last_date FROM fact_sales
)
-- ------------------------------------------------------------------------------------------
-- valuable KPIs
-- ------------------------------------------------------------------------------------------    
SELECT 
	ca.customer_key,
	ca.customer_number,
	ca.customer_name,
	ca.age,
     CASE 
		WHEN age < 20 THEN 'Under 20'
		WHEN age between 20 and 29 THEN '20-29'
		WHEN age between 30 and 39 THEN '30-39'
		WHEN age between 40 and 49 THEN '40-49'
		ELSE '50 and above'
	END AS age_group,
    CASE 
		WHEN lifespan_in_months>=12 AND total_sales>5000 THEN 'VIP'
        WHEN lifespan_in_months>=12 AND total_sales<=5000 THEN 'Regular'
        ELSE 'New'
	END AS customer_segment,
    lifespan_in_months,
    last_order_date,
    TIMESTAMPDIFF(MONTH, last_order_date, m.dataset_last_date) AS recency_in_months,
    total_orders,
    total_sales,
    total_quantity_purchased,
    total_products, 
    -- Compute Average Order Value (AOV)
    CASE 
		WHEN total_orders = 0 THEN 0
        ELSE ROUND(total_sales/total_orders,2) 
	END AS average_order_value,
    -- Compute Average Monthly Spend (Total_sales/no. of months)
    CASE 
		WHEN lifespan_in_months =0 THEN total_sales
        ELSE ROUND(total_sales/lifespan_in_months,2)
	END AS average_monthly_spend
FROM customer_aggregation ca
CROSS JOIN max_date m;

---------------------------------------------------------------------------------------------------------------
-- Q10. How does revenue contribution vary across customer age groups?
---------------------------------------------------------------------------------------------------------------
SELECT
    age_group,
    COUNT(*) AS total_customers,
    SUM(total_sales) AS total_revenue,
    ROUND(AVG(average_order_value),2) AS avg_order_value
FROM report_customers
GROUP BY age_group
ORDER BY total_revenue DESC;
/* Insights: The “50 and above” dominates. older customers are the primary revenue drivers, supported by higher 
average order values across mature age brackets. */

---------------------------------------------------------------------------------------------------------------
-- Q11. Which customer segments (New, Regular, VIP) drive the majority of revenue?
---------------------------------------------------------------------------------------------------------------
SELECT 
	customer_segment,
    SUM(total_orders),
    COUNT(customer_number) AS total_customers,
    SUM(total_sales) AS total_spending,
    AVG(average_order_value)
FROM report_customers
GROUP BY customer_segment
ORDER BY total_spending DESC;
/* Insights: 
	1. Revenue is highly concentrated: ~1.6K VIP customers generate nearly the same revenue as 
		~14.8K New customers, driven by significantly higher AOV. 
	2. Customer base skews heavily toward New buyers (~85%), while only ~9% reach VIP status, 
		indicating strong acquisition but weak long-term retention. */

---------------------------------------------------------------------------------------------------------------
-- Q12. What proportion of customers exhibit one-time purchase behavior?
---------------------------------------------------------------------------------------------------------------
SELECT 
    COUNT(*) AS total_customers,
    SUM(CASE WHEN total_orders = 1 THEN 1 ELSE 0 END) AS one_time_customers,
    ROUND(SUM(CASE WHEN total_orders = 1 THEN 1 ELSE 0 END) * 100.0 
          / COUNT(*), 2) AS pct_one_time_customers
FROM report_customers;
/* Insights: Over 62% of customers placed only one order, indicating weak retention and a heavy dependence on 
continuous new-customer acquisition rather than repeat buying. */

/*
===============================================================================
SECTION 5: CHURN & RETENTION
===============================================================================
Purpose: Evaluate customer disengagement and retention risk using RFM (Recency, Frequency, Monetary).

SQL Functions Used:
    - CTEs
    - CASE, GROUP BY, ORDER BY
    - SUM(), COUNT(), MIN(), MAX(), AVG(), ROUND(), DISTINCT() 
===============================================================================
*/

---------------------------------------------------------------------------------------------------------------
-- Q13. Analyse Churn pattern Using Combined RFM (Recency–Frequency–Monetary) behaviour.
---------------------------------------------------------------------------------------------------------------
WITH 
churn_base AS (
	SELECT 
		CASE
			WHEN lifespan_in_months < 3 THEN 'New'
			WHEN recency_in_months > 12 THEN 'Churned'
			WHEN recency_in_months BETWEEN 4 AND 12 THEN 'At Risk'
			ELSE 'Active'
		END AS churn_status,
        CASE
			WHEN total_orders=1 THEN 'One-time'
            WHEN total_orders BETWEEN 2 AND 3 THEN 'Occasional'
            ELSE 'Loyal'
		END AS frequency_status,
		customer_key,
		total_sales,
		total_orders,
		average_order_value,
		average_monthly_spend,
		recency_in_months
	FROM report_customers
    )
	SELECT
		churn_status,
        frequency_status,
        COUNT(DISTINCT customer_key) AS total_customer,
		SUM(total_sales) AS total_revenue,
		SUM(total_orders) AS total_orders,
		ROUND(AVG(average_order_value), 2) AS avg_order_value,
		ROUND(AVG(average_monthly_spend), 2) AS avg_monthly_spend,
		ROUND(AVG(recency_in_months), 2) AS avg_recency
	FROM churn_base
	GROUP BY churn_status, frequency_status
	ORDER BY total_customer DESC;
/* Insights: Churn is extremely low. Most customers are New + One-Time buyers, while the At-Risk + Occasional segment 
contributes the highest revenue, indicating strong spenders slipping away. Active customers remain the most stable group, 
but loyal customers are rare—highlighting retention as the biggest opportunity area. */

/*
===============================================================================
SECTION 6: ACQUISITION & COHORT ANALYSIS
===============================================================================
Purpose: Analyze customer acquisition patterns and post-acquisition behavior
    using cohort-based analysis.

SQL Functions Used:
    - CTEs
    - CASE, JOIN, GROUP BY, ORDER BY
    - SUM(), COUNT(), MIN(), MAX(), AVG(), MIN(), MAX(), ROUND(), DISTINCT()
    - DATE_FORMAT(), TIMESTAMPDIFF(), MONTH
===============================================================================
*/
---------------------------------------------------------------------------------------------------------------
-- Q14. How are customers distributed across profitability segments based on spend and purchase frequency?
---------------------------------------------------------------------------------------------------------------
WITH profitability_map AS (SELECT
    customer_key,
    customer_name,
    total_sales,
    total_orders,
    average_order_value,
    recency_in_months,

    CASE
        WHEN total_sales > 5000 AND total_orders > 10 THEN 'High-Value Frequent'
        WHEN total_sales > 5000 AND total_orders <= 10 THEN 'High-Value Infrequent'
        WHEN total_sales <= 5000 AND total_orders > 10 THEN 'Low-Value Frequent'
        ELSE 'Low-Value Infrequent'
    END AS profitability_segment
FROM report_customers
ORDER BY total_sales DESC)
SELECT 
	profitability_segment,
    SUM(total_sales),
    SUM(total_orders)
FROM profitability_map
GROUP BY profitability_segment;
/* Insights: Most customers fall into the low-value segments, with Low-Value Infrequent customers dominating 
revenue volume, while High-Value Infrequent customers contribute a strong €11.24M despite low order frequency 
— highlighting a dependency on high-ticket but infrequent buyers. */

---------------------------------------------------------------------------------------------------------------
-- Q15. How does customer acquisition evolve over time by cohort, and find out retention % across cohorts?
---------------------------------------------------------------------------------------------------------------
WITH first_purchase AS (
    SELECT 
        customer_key,
        DATE_FORMAT(MIN(order_date), '%Y-%m-01') AS cohort_month
    FROM fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY customer_key
),
customer_orders AS (
    SELECT
        f.customer_key,
        DATE_FORMAT(f.order_date, '%Y-%m-01') AS order_month
    FROM fact_sales f
    JOIN first_purchase fp
      ON f.customer_key = fp.customer_key
),
cohort_calculation AS (
    SELECT
        fp.cohort_month,
        TIMESTAMPDIFF(MONTH, fp.cohort_month, co.order_month) AS period,
        co.customer_key
    FROM customer_orders co
    JOIN first_purchase fp
      ON co.customer_key = fp.customer_key
),
-- counts of active customers per cohort & period
cohort_activity AS (
    SELECT
        cohort_month,
        period,
        COUNT(DISTINCT customer_key) AS active_customers
    FROM cohort_calculation
    WHERE period IS NOT NULL
    GROUP BY cohort_month, period
),
-- cohort size (period 0 customers) = denominator
cohort_size AS (
    SELECT
        cohort_month,
        MAX(CASE WHEN period = 0 THEN active_customers END) AS cohort_customers
    FROM cohort_activity
    GROUP BY cohort_month
)
SELECT
    ca.cohort_month,
    ca.period,
    ca.active_customers,
    ROUND(ca.active_customers * 100.0 / cs.cohort_customers, 2) AS retention_pct
FROM cohort_activity ca
JOIN cohort_size cs
  ON ca.cohort_month = cs.cohort_month
ORDER BY ca.cohort_month, ca.period;
/* Insights:Customer acquisition accelerated sharply in 2012–2013, with 2013 onboarding the largest cohort (12.5K customers),
 but retention did not scale proportionally—early cohorts (2010–2011) show stronger long-tail engagement, while 2013’s surge 
 consists mostly of one-time or short-term buyers despite seasonal retention bumps around July, August, and December. */

/*
===============================================================================
SECTION 7: PRODUCT CUSTOMER INTERACTION
===============================================================================
Purpose: Understand how customer segments interact with product segments to
    uncover acquisition drivers, cross-sell gaps, and retention opportunities.

SQL Functions Used:
    - Multiple CTEs
    - RANK() OVER()
    - CASE, GROUP BY
    - NULLIF(), ROUND(), DISTINCT(), SUM(), COUNT(), MIN(), MAX(), AVG() 
    - TIMESTAMPDIFF(), MONTH()
===============================================================================
*/
---------------------------------------------------------------------------------------------------------------
-- Q16. Which customer segments purchase which product segments?
---------------------------------------------------------------------------------------------------------------
SELECT
    rc.customer_segment,
    rp.product_segment,
    COUNT(DISTINCT rc.customer_key) AS total_customers,
    SUM(f.sales_amount) AS total_revenue
FROM fact_sales f
JOIN report_customers rc ON f.customer_key = rc.customer_key
JOIN report_products rp ON f.product_key = rp.product_key
GROUP BY rc.customer_segment, rp.product_segment
ORDER BY total_revenue DESC;
/* Insights: High-Performer products drive nearly all revenue across all customer segments, 
especially New and VIP customers, while Mid/Low-Performer products contribute minimally 
— signaling an extremely top-heavy product portfolio. */

---------------------------------------------------------------------------------------------------------------
-- Q17. Which 5 products drive initial customer acquisition across Churn states (Active, At risk, Churned)?
---------------------------------------------------------------------------------------------------------------
WITH customer_churn AS (
    SELECT
        customer_key,
        CASE
            WHEN TIMESTAMPDIFF(MONTH, MAX(order_date), (SELECT MAX(order_date) FROM fact_sales)) > 12 THEN 'Churned'
            WHEN TIMESTAMPDIFF(MONTH, MAX(order_date), (SELECT MAX(order_date) FROM fact_sales)) BETWEEN 4 AND 12 THEN 'At Risk'
            ELSE 'Active'
        END AS churn_status
    FROM fact_sales
    GROUP BY customer_key
    
),

first_purchase AS (
    SELECT
        customer_key,
        MIN(order_date) AS first_order_date
    FROM fact_sales
    GROUP BY customer_key
),

acquisition_products AS (
    SELECT
        c.churn_status,
        f.product_key,
        COUNT(DISTINCT f.customer_key) AS acquired_customers,
        AVG(f.sales_amount / NULLIF(f.quantity,0)) AS avg_selling_price
    FROM fact_sales f
    JOIN first_purchase fp
        ON f.customer_key = fp.customer_key
       AND f.order_date = fp.first_order_date
    JOIN customer_churn c
        ON f.customer_key = c.customer_key
    GROUP BY c.churn_status, f.product_key
),

ranked_products AS (
    SELECT
        churn_status,
        p.product_name,
        acquired_customers,
        ROUND(avg_selling_price,2) AS avg_selling_price,
        RANK() OVER (
            PARTITION BY churn_status
            ORDER BY acquired_customers DESC
        ) AS rnk
    FROM acquisition_products ap
    JOIN dim_products p
        ON ap.product_key = p.product_key
)
SELECT *
FROM ranked_products
WHERE rnk <= 5
ORDER BY churn_status, rnk;
/* Insights: Classic “entry funnel” behavior, Low-cost accessories (e.g., Water Bottle – 30 oz., Tire Tubes, Patch Kits) 
are the strongest acquisition drivers for Active and At-Risk customers but fail to retain them long-term, while 
high-priced bikes primarily attract one-time buyers who quickly churn.
 */


-- THE END --