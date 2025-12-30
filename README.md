<h1>📊 Sales Analytics & Customer Intelligence — End-to-End SQL Project</h1>

<hr/>

<h2 id="overview">1. Project Overview</h2>
<p>
A comprehensive end-to-end sales analytics project that transforms raw transactional data from
CRM and ERP systems into actionable business insights using SQL.
</p>
<p>
A star-schema data warehouse was designed, cleaned, and queried to build analytical views,
following real-world data warehousing and analytics best practices.
</p>

<hr/>

<h2 id="repo-structure">📁 Repository Structure</h2>

<pre>
SQL_Sales_Analytics_End_to_End_Project/
│
├── datasets/
│   ├── raw_crm/
│   └── raw_erp/
│
├── Scripts/
│   ├── 01_Clean_Layer_ddl.sql
│   ├── 02_Data_Cleaning_etl.sql
│   ├── 03_Modelling_Views.sql
│   └── 04_EDA_insights.sql
│
├── diagrams/
│   ├── query_results/
│   ├── Data_flow.png
│   └── Star_schema.png
│
├── LICENSE
└── README.md
</pre>

<hr/>

<h2 id="problem">🎯 Problem Statement</h2>
<p>The business faces challenges in:</p>
<ul>
  <li>Understanding revenue concentration and category dependence</li>
  <li>Identifying high-value customers vs one-time buyers</li>
  <li>Detecting churn risk early using Recency & Frequency</li>
  <li>Evaluating product lifecycle and YoY performance</li>
  <li>Knowing which products drive acquisition vs long-term value</li>
  <li>Aligning marketing, retention, and product strategy with data</li>
</ul>

<p><strong>This project answers:</strong><br/>
Where is revenue coming from, who is generating it, what is driving churn, and how can growth be made sustainable?
</p>

<hr/>

<h2 id="dataset">3. Dataset & Source Systems</h2>
<img src="diagrams/Data_flow.png" alt="Data Flow Diagram" width="800"/>

<ul>
  <li><strong>CRM:</strong> Customer demographics, products, sales</li>
  <li><strong>ERP:</strong> Customer, location, category</li>
  <li>Granularity: Order-line level</li>
</ul>

<p>
Raw data was cleaned into 6 tables and modeled into 3 analytical views.
</p>

<hr/>

<h2 id="modeling">4. Data Modelling & Architecture</h2>

<h3>4.1 Clean Layer DDL</h3>
<p><a href="Scripts/01_Clean_Layer_ddl.sql">View SQL</a></p>

<h3>4.2 Data Cleaning ETL</h3>
<p><a href="Scripts/02_Data_Cleaning_etl.sql">View SQL</a></p>
<ul>
  <li>Standardized date formats and missing values</li>
  <li>Removed duplicates using validation checks</li>
  <li>Normalized gender & marital status</li>
  <li>Derived sales amount and price</li>
  <li>Ensured consistent identifiers</li>
</ul>

<h3>4.3 Analytical Views</h3>
<p><a href="Scripts/03_Modelling_views.sql">View SQL</a></p>
<ul>
  <li>Star schema design</li>
  <li>Fact table built using surrogate keys</li>
  <li>Entity relationships enforced</li>
  <li>Reusable semantic layer</li>
</ul>

<img src="diagrams/Star_schema.png" alt="Star Schema" width="800"/>

<hr/>

<h2 id="eda">5. Exploratory Data Analysis</h2>
<p><a href="Scripts/04_EDA_insights.sql">View Full SQL</a></p>

<hr/>

<h2 id="eda-highlights">📌 EDA Question Highlights</h2>

<h3>Q1. Key Business Metrics Overview</h3>
<pre><code>
  </code></pre>
  
```sql
SELECT 'Dataset Start Date' AS Metric, MIN(order_date) FROM fact_sales
UNION ALL
SELECT 'Dataset End Date', MAX(order_date) FROM fact_sales
UNION ALL
SELECT 'Duration_in_months', TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) FROM fact_sales
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
```

<img src="diagrams/query_results/Q1.png" width="100"/>
<p><strong>Insight:</strong> Dataset spans 36 months with ~18.5K customers and €29.3M in sales.</p>

<hr/>

<h3>Q2. Sales Performance Over Time</h3>
<pre><code>
SELECT YEAR(order_date), SUM(sales_amount)
FROM fact_sales
GROUP BY YEAR(order_date);
</code></pre>
<img src="diagrams/query_results/Q2.png" width="700"/>
<p><strong>Insight:</strong> 2013 peaks; 2014 decline due to early data cutoff. December shows holiday seasonality.</p>

<hr/>

<h3>Q3. Revenue Contribution by Category</h3>
<pre><code>
WITH category_sales AS (
 SELECT p.category, SUM(f.sales_amount) AS total_sales
 FROM fact_sales f
 JOIN dim_products p ON f.product_key = p.product_key
 GROUP BY p.category
)
SELECT category, total_sales,
ROUND(total_sales / SUM(total_sales) OVER() * 100,2) AS pct
FROM category_sales;
</code></pre>
<img src="diagrams/query_results/Q3.png" width="700"/>
<p><strong>Insight:</strong> Bikes drive ~96% of revenue → high concentration risk.</p>

<hr/>

<h3>Q4. Churn Analysis Using RFM Behavior</h3>
<img src="diagrams/query_results/Q4.png" width="700"/>
<p><strong>Insight:</strong> At-Risk customers generate highest revenue but show declining engagement.</p>

<hr/>

<h3>Q5. Acquisition Products by Churn Segment</h3>
<img src="diagrams/query_results/Q5.png" width="700"/>
<p><strong>Insight:</strong> Low-cost accessories drive acquisition but fail to retain long-term.</p>

<hr/>

<h2 id="insights">6. Key Insights</h2>

<h3>Revenue & Products</h3>
<ul>
  <li>🚲 Bikes contribute ~96% of revenue</li>
  <li>📉 Accessories drive acquisition but minimal revenue</li>
  <li>📊 2013 peak followed by market-wide decline</li>
</ul>

<h3>Customers</h3>
<ul>
  <li>👥 ~85% customers are New; ~9% VIP</li>
  <li>💎 VIPs generate revenue comparable to all New buyers</li>
  <li>🔁 62% one-time buyers</li>
</ul>

<h3>Churn & Retention</h3>
<ul>
  <li>⚠️ At-Risk customers = top win-back opportunity</li>
  <li>🔒 Active customers are stable but few</li>
  <li>🎯 Churn is behavioral, not value-driven</li>
</ul>

<h3>Acquisition & Cohorts</h3>
<ul>
  <li>📈 Acquisition surged in 2012–13</li>
  <li>🔄 Seasonal retention recovery (Jul, Aug, Dec)</li>
  <li>🧩 Hybrid customer base: mass buyers + enthusiasts</li>
</ul>

<h3>Product–Customer Interaction</h3>
<ul>
  <li>🧲 Low-cost accessories dominate acquisition</li>
  <li>💰 High-priced bikes are one-time purchases</li>
  <li>🔄 Repeat purchases are rare</li>
</ul>

<hr/>

<h2 id="recommendations">7. Business Recommendations</h2>
<ul>
  <li>Target At-Risk high-value customers with win-back campaigns</li>
  <li>Build upsell paths from accessories to bikes</li>
  <li>Improve onboarding for new customers</li>
  <li>Optimize product portfolio</li>
  <li>Invest in VIP & loyalty programs</li>
</ul>

<hr/>

<h2 id="skills">8. Tools & Skills Demonstrated</h2>
<ul>
  <li>MySQL</li>
  <li>CTEs & Window Functions</li>
  <li>Star Schema Design</li>
  <li>Time-Series Analysis</li>
  <li>RFM & Cohort Analysis</li>
  <li>Business-Focused EDA</li>
</ul>
