# SQL_Sales_Analytics_End_to_End_Project
Building a modern data warehouse using mySQL, including ETL, data modeling and advanced analytics with business improvement strategies.

<h1>📊 Sales Analytics & Customer Intelligence — End-to-End SQL Project</h1>

<h2>1. Project Overview</h2>
<p>
A comprehensive end-to-end sales analytics project that transforms raw transactional data
from CRM and ERP systems into actionable business insights using SQL.
</p>
<p>
A star-schema data warehouse was designed, cleaned, and queried to build analytical views,
following real-world data warehousing and analytics best practices.
</p>

<h2>📁 Repository Structure</h2>
<pre>
SQL_Sales_Analytics_End_to_End_Project/
│
├── datasets/
│   ├── crm_customers_raw.csv
│   ├── crm_products_raw.csv
|   ├── crm_sales_raw.csv
|   ├── erp_category_raw.csv
|   ├── erp_customer_raw.csv
│   └── erp_location_raw.csv
│
├── Scripts/
│   ├── 01_Clean_Layer_ddl.sql
│   ├── 02_Data_Cleaning_etl.sql
│   ├── 03_Modelling_Views.sql
│   └── 04_EDA_insights.sql
│
├── diagrams/
│   ├── Data_flow.png
│   ├── Star_schema.png
│
├── README.md
└── LICENSE
</pre>

<h2>🎯 Problem Statement</h2>
<p>The Bikes Data Sales Mart business faces challenges in:</p>
<ul>
  <li>Understanding revenue concentration and category dependence</li>
  <li>Identifying high-value customers vs one-time buyers</li>
  <li>Detecting churn risk early using Recency & Frequency</li>
  <li>Evaluating product lifecycle and YoY performance</li>
  <li>Knowing which products drive acquisition vs long-term value</li>
  <li>Aligning marketing, retention, and product strategy with data</li>
</ul>

<p><strong>This project answers:</strong><br>
Where is revenue coming from, who is generating it, what is driving churn, and how can growth be made sustainable?
</p>

<h2>3. Dataset & Source Systems</h2>
![Data flow Diagram](./diagrams/Data_flow.jpg)
<h3>Source Systems (Raw Tables)</h3>
<ul>
  <li><strong>CRM:</strong> customer demographics, product, sales</li>
  <li><strong>ERP:</strong> customer, location, category</li>
</ul>

<p>
<strong>Granularity:</strong> Order-line level.<br>
Data cleaned into 6 tables and further transformed into 3 core analytical views.
</p>

<h2>4. Data Modelling & Architecture</h2>

<h3>4.1 Clean Layer DDL</h3>
<p>
Defined standardized clean-layer table structures.
(<em>See <code>01_Clean_Layer_ddl.sql</code></em>)
[Clean Layer DDL](./Scripts/01_Clean_Layer_ddl.sql)

</p>

<h3>4.2 Data Cleaning & ETL</h3>
<p>
Raw data was transformed and loaded into the clean layer.
(<em>See <code>02_Data_Cleaning_etl.sql</code></em>)
</p>
<ul>
  <li>Standardized date formats and handled missing values</li>
  <li>Removed duplicates and nulls using validation checks</li>
  <li>Normalized gender and marital status fields</li>
  <li>Derived sales amount field</li>
  <li>Ensured consistent customer and product identifiers</li>
</ul>

<h3>4.3 Analytical Views</h3>
<p>(<em>See <code>03_Modelling_Views.sql</code></em>)</p>
<ul>
  <li>Star schema design to simplify analysis and improve query readability</li>
  <li>Fact table built using surrogate keys from dimension tables</li>
  <li>Entity relationships enforced during joins</li>
  <li>Views used to abstract complexity and ensure reusability</li>
</ul>

<p><strong>Core Views:</strong></p>
<ul>
  <li><code>fact_sales</code></li>
  <li><code>dim_customers</code></li>
  <li><code>dim_products</code></li>
</ul>

<p><em>![Star schema](diagrams/Star_schema.png)</em></p>

<h2>5. Exploratory Data Analysis</h2>
<p>(<em>See <code>04_EDA_insights.sql</code></em>)</p>

<p>
Highlights:
</p>
<ul>
  <li>Q. Generate a report that summarizes key business metrics (sales, orders, customers, products).</li>
  <li>
    ```SELECT 'Dataset Start Date' AS Metric, MIN(order_date) AS Measure_value FROM fact_sales
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
</li>
  <li>Result grid visualization</li>
  <li>Insight: Spans 36 months duration with '18484' customers and total sales revenue 'Total Sales', '29355840' across 3 categories (Bikes,apparel, accessories).</li>
</ul>

<h3>Key Insights</h3>

<h4>Business Overview & Product Trends</h4>
<ul>
  <li>🚲 Bikes contribute ~96% of total revenue, indicating extreme dependence on high-ticket products</li>
  <li>📉 Accessories and Apparel drive acquisition but contribute marginal revenue</li>
  <li>📊 2013 was the strongest year across nearly all products; 2014 shows a broad market contraction</li>
</ul>

<h4>Customer Segmentation & Revenue Distribution</h4>
<ul>
  <li>👥 ~85% of customers are New buyers, while only ~9% become VIPs</li>
  <li>💎 VIP customers (~1.6K) generate nearly the same revenue as ~14.8K New customers due to very high AOV</li>
  <li>🔁 62% of customers are one-time buyers, indicating weak retention</li>
  <li>🎯 Customers aged 40+ contribute the majority of revenue with higher AOVs</li>
</ul>

<h4>Churn & Retention</h4>
<ul>
  <li>⚠️ At-Risk customers generate the highest revenue but show declining engagement</li>
  <li>🔒 Active customers form a small but extremely stable revenue base</li>
  <li>🎯 Churn is driven by low frequency rather than low customer value</li>
</ul>

<h4>Acquisition & Cohorts</h4>
<ul>
  <li>📈 Customer acquisition surged in 2012–2013, but retention did not scale</li>
  <li>🔄 Seasonal retention recovery observed in months 7, 8, and 12</li>
  <li>🧩 The business serves a hybrid customer base:
    <ul>
      <li>One-time mass buyers</li>
      <li>Loyal cycling enthusiasts</li>
    </ul>
  </li>
  <li>🧠 Profitability depends more on customer quality than customer quantity</li>
</ul>

<h4>Product–Customer Interaction</h4>
<ul>
  <li>🧲 Low-cost accessories dominate acquisition but convert poorly into long-term value</li>
  <li>💰 High-priced bikes are mostly one-time purchases but drive revenue</li>
  <li>🔄 Repeat purchases are rare across most products</li>
</ul>

<h2>7. Business Recommendations</h2>
<ul>
  <li>Prioritize win-back campaigns for At-Risk high-value customers</li>
  <li>Design structured upsell paths from low-cost acquisition products</li>
  <li>Improve onboarding journeys for new customers</li>
  <li>Rationalize low-performing products to improve margins</li>
  <li>Invest in loyalty programs for Active and VIP customers</li>
</ul>

<h2>8. Tools & Skills Demonstrated</h2>
<ul>
  <li>SQL (MySQL)</li>
  <li>CTEs, Window Functions, Complex Joins, CASE Statements</li>
  <li>Data Warehousing & Star Schema Design</li>
  <li>Time-Series Analysis</li>
  <li>RFM & Cohort Analysis</li>
  <li>Business-Driven EDA</li>
  <li>KPI & Metric Engineering</li>
  <li>Analytics-Ready View Creation</li>
</ul>
