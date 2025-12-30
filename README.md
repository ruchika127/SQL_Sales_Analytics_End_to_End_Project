<h1>📊 Sales Analytics & Customer Intelligence — End-to-End SQL Project</h1>

<p>
A comprehensive end-to-end sales analytics project that transforms raw transactional data
from CRM and ERP systems into actionable business insights using SQL.
</p>

<p>
A star-schema data warehouse was designed, cleaned, and queried to build analytical views,
following real-world data warehousing and analytics best practices.
</p>

<hr>

<h2 id="toc">📌 Table of Contents</h2>
<ul>
  <li><a href="#overview">1. Project Overview</a></li>
  <li><a href="#repo">2. Repository Structure</a></li>
  <li><a href="#problem">3. Problem Statement</a></li>
  <li><a href="#dataset">4. Dataset & Source Systems</a></li>
  <li><a href="#modeling">5. Data Modelling & Architecture</a></li>
  <li><a href="#eda">6. Exploratory Data Analysis</a></li>
  <li><a href="#insights">7. Key Insights</a></li>
  <li><a href="#recommendations">8. Business Recommendations</a></li>
  <li><a href="#skills">9. Tools & Skills Demonstrated</a></li>
</ul>

<hr>

<h2 id="overview">1. Project Overview</h2>
<p>
This project simulates a real-world analytics workflow where raw data from multiple business
systems is transformed into a clean analytical model and explored through SQL-driven insights.
</p>

<hr>

<h2 id="repo">2. 📁 Repository Structure</h2>

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

<hr>

<h2 id="problem">3. 🎯 Problem Statement</h2>
<p>
The Bikes Sales business faces challenges in:
</p>
<ul>
  <li>Understanding revenue concentration and category dependence</li>
  <li>Identifying high-value customers vs one-time buyers</li>
  <li>Detecting churn risk early using recency and frequency signals</li>
  <li>Evaluating product lifecycle and YoY performance</li>
  <li>Understanding which products drive acquisition vs long-term value</li>
  <li>Aligning marketing, retention, and product strategy with data</li>
</ul>

<p><b>This project answers:</b><br>
Where is revenue coming from, who is generating it, what is driving churn, and how can growth be made sustainable?
</p>

<hr>

<h2 id="dataset">4. Dataset & Source Systems</h2>

<img src="diagrams/Data_flow.png" alt="Data Flow Diagram" width="700">

<p><b>Source Systems (Raw tables):</b></p>
<ul>
  <li>CRM: customer demographics, product data, sales transactions</li>
  <li>ERP: customer master, location, product categories</li>
</ul>

<p>
<b>Granularity:</b> Order-line level<br>
<b>Transformation:</b> Raw data cleaned into 6 tables and consolidated into 3 analytical views
</p>

<hr>

<h2 id="modeling">5. Data Modelling & Architecture</h2>

<h3>5.1 Clean Layer DDL</h3>
<p>
Defines standardized schemas and datatypes for analytics-ready tables.
</p>
<p>
🔗 <a href="Scripts/01_Clean_Layer_ddl.sql">01_Clean_Layer_ddl.sql</a>
</p>

<h3>5.2 Data Cleaning & ETL</h3>
<p>
Transforms raw data into clean, validated tables.
</p>
<ul>
  <li>Standardized date formats and categorical values</li>
  <li>Removed duplicates and invalid records</li>
  <li>Derived sales amount and pricing fields</li>
  <li>Validated referential integrity</li>
</ul>
<p>
🔗 <a href="Scripts/02_Data_Cleaning_etl.sql">02_Data_Cleaning_etl.sql</a>
</p>

<h3>5.3 Analytical Views & Star Schema</h3>
<p>
A star schema was implemented to simplify analytics and improve query performance.
</p>
<ul>
  <li>fact_sales</li>
  <li>dim_customers</li>
  <li>dim_products</li>
</ul>

<p>
🔗 <a href="Scripts/03_Modelling_Views.sql">03_Modelling_Views.sql</a>
</p>

<img src="diagrams/Star_schema.png" alt="Star Schema Diagram" width="700">

<hr>

<h2 id="eda">6. Exploratory Data Analysis</h2>
<p>
All analytical questions, SQL queries, and business logic are documented in a structured EDA script.
</p>

<p>
🔗 <a href="Scripts/04_EDA_insights.sql">04_EDA_insights.sql</a>
</p>

<p>
Each question includes:
</p>
<ul>
  <li>Business question</li>
  <li>SQL query</li>
  <li>Result grid snapshot</li>
  <li>Concise insight for decision-making</li>
</ul>

<hr>

<h2 id="insights">7. 🔍 Key Insights</h2>

<h3>Revenue & Product Trends</h3>
<ul>
  <li>🚲 Bikes contribute ~96% of total revenue, indicating extreme dependence on high-ticket products.</li>
  <li>📉 Accessories and Apparel drive acquisition but contribute marginal revenue.</li>
  <li>📊 2013 was the strongest year across nearly all products; 2014 shows broad market contraction.</li>
</ul>

<h3>Customer Segmentation</h3>
<ul>
  <li>👥 ~85% of customers are New buyers, while only ~9% become VIPs.</li>
  <li>💎 VIP customers (~1.6K) generate nearly the same revenue as ~14.8K New customers.</li>
  <li>🔁 62% of customers are one-time buyers, indicating weak retention.</li>
</ul>

<h3>Churn & Retention</h3>
<ul>
  <li>⚠️ At-Risk customers generate the highest revenue but show declining engagement.</li>
  <li>🔒 Active customers form a small but highly stable revenue base.</li>
  <li>🎯 Churn is driven by low frequency, not low value.</li>
</ul>

<h3>Acquisition & Cohorts</h3>
<ul>
  <li>📈 Customer acquisition surged in 2012–2013, but retention did not scale.</li>
  <li>🔄 Seasonal retention recovery occurs in months 7, 8, and 12.</li>
  <li>🧩 The business serves both mass one-time buyers and loyal cycling enthusiasts.</li>
</ul>

<h3>Product–Customer Interaction</h3>
<ul>
  <li>🧲 Low-cost accessories dominate acquisition.</li>
  <li>💰 High-priced bikes are mostly one-time purchases, revealing a cross-sell gap.</li>
  <li>🔄 Repeat purchases are rare across most products.</li>
</ul>

<hr>

<h2 id="recommendations">8. 📈 Business Recommendations</h2>
<ul>
  <li>Prioritize win-back campaigns for At-Risk high-value customers</li>
  <li>Build structured upsell paths from low-cost entry products</li>
  <li>Improve onboarding journeys for new customers</li>
  <li>Rationalize low-performing products to improve margins</li>
  <li>Invest in loyalty programs for Active and VIP customers</li>
</ul>

<hr>

<h2 id="skills">9. 🛠 Tools & Skills Demonstrated</h2>
<ul>
  <li>SQL (MySQL)</li>
  <li>CTEs, Window Functions, Complex Joins</li>
  <li>Star Schema & Data Warehousing</li>
  <li>Time-Series & Cohort Analysis</li>
  <li>RFM-based Churn Analysis</li>
  <li>KPI Engineering & Analytics Views</li>
  <li>Business-driven Exploratory Analysis</li>
</ul>
