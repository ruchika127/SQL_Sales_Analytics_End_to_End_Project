<h1>📊 Sales Analytics & Customer Intelligence — End-to-End SQL Project</h1>

<hr>

<h2 id="toc">📌 Table of Contents</h2>
<ul>
  <li><a href="#overview">1. Project Overview</a></li>
  <li><a href="#problem">2. Problem Statement</a></li>
  <li><a href="#repo">3. Repository Structure</a></li>
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
A comprehensive <b>end-to-end sales analytics project</b> that transforms raw transactional data 
from CRM and ERP systems into <b>actionable business insights using SQL</b>.
</p>

<p>
A <b>star-schema data warehouse</b> was designed, cleaned, and queried to build analytical views, 
following real-world data warehousing and analytics best practices.
</p>

<hr>

<h2 id="problem">2. 🎯 Problem Statement</h2>
<p>The business faces challenges in:</p>
<ul>
  <li>Understanding revenue concentration and category dependence</li>
  <li>Identifying high-value customers vs one-time buyers</li>
  <li>Detecting churn risk early using Recency & Frequency</li>
  <li>Evaluating product lifecycle and YoY performance</li>
  <li>Knowing which products drive acquisition vs long-term value</li>
  <li>Aligning marketing, retention, and product strategy with data</li>
</ul>

<p><b>This project answers:</b></p>
<p>
<i>Where is revenue coming from, who is generating it, what is driving churn, 
and how can growth be made sustainable?</i>
</p>

<hr>

<h2 id="repo">3. 📁 Repository Structure</h2>

<pre>
Sales-Analytics-SQL/
│
├── Datasets/
│   └── Raw_Data/
│
├── Scripts/
│   ├── 01_Clean_Layer_ddl.sql
│   ├── 02_Data_Cleaning_etl.sql
│   ├── 03_Modelling_Views.sql
│   └── 04_EDA_insights.sql
│
├── Diagrams/
│   ├── Data_Flow.png
│   └── Star_Schema.png
│
├── Images/
│   ├── eda_q1.png
│   ├── eda_q2.png
│   └── churn_analysis.png
│
└── README.md
</pre>

<p>
<b>Note:</b> Images (result grids, diagrams) must be committed to GitHub inside an <code>Images/</code> 
or <code>Diagrams/</code> folder to render correctly.
</p>

<hr>

<h2 id="dataset">4. Dataset & Source Systems</h2>

<ul>
  <li><b>Source Systems:</b> CRM & ERP</li>
  <li><b>Granularity:</b> Order-line level</li>
  <li><b>Initial Tables:</b> 6 raw tables</li>
  <li><b>Final Analytical Layer:</b> 3 clean, joined views</li>
</ul>

<p><b>Data Flow Overview:</b></p>
<img src="Diagrams/Data_Flow.png" alt="Data Flow Diagram" width="700">

<hr>

<h2 id="modeling">5. Data Modelling & Architecture</h2>

<h3>5.1 Clean Layer DDL</h3>
<p>
Defines clean, standardized tables for analytics.
</p>
<p>
🔗 <a href="Scripts/01_Clean_Layer_ddl.sql">Clean Layer DDL Script</a>
</p>

<h3>5.2 Data Cleaning & ETL</h3>
<ul>
  <li>Standardized date formats</li>
  <li>Handled missing values and duplicates</li>
  <li>Normalized categorical fields</li>
  <li>Derived sales and pricing metrics</li>
</ul>

<p>
🔗 <a href="Scripts/02_Data_Cleaning_etl.sql">Data Cleaning & ETL Script</a>
</p>

<h3>5.3 Analytical Views & Star Schema</h3>
<ul>
  <li>Fact table built using surrogate keys</li>
  <li>Dimension tables joined via star schema</li>
  <li>Views abstract complexity and ensure reusability</li>
</ul>

<p>
🔗 <a href="Scripts/03_Modelling_Views.sql">Analytical Views</a>
</p>

<img src="Diagrams/Star_Schema.png" alt="Star Schema Diagram" width="700">

<hr>

<h2 id="eda">6. Exploratory Data Analysis</h2>

<p>
The EDA answers <b>17 business-driven analytical questions</b> across revenue, customers,
products, churn, acquisition, and retention.
</p>

<p>
🔗 <a href="Scripts/04_EDA_insights.sql">Full EDA SQL File</a>
</p>

<h4>Example Question Format</h4>

<pre><code>
-- Q. What customer segments drive the majority of revenue?
SELECT ...
</code></pre>

<img src="Images/eda_q1.png" alt="EDA Result Grid Example" width="700">

<p><i>Insight: VIP customers contribute disproportionate revenue despite smaller size.</i></p>

<hr>

<h2 id="insights">7. 📌 Key Insights</h2>

<h3>Revenue & Products</h3>
<ul>
  <li>🚲 Bikes contribute ~96% of total revenue — extreme category dependence</li>
  <li>📉 Accessories & apparel drive acquisition but minimal revenue</li>
  <li>📊 2013 peak year; 2014 shows market-wide contraction</li>
</ul>

<h3>Customer Segmentation</h3>
<ul>
  <li>👥 ~85% of customers are New buyers; only ~9% become VIPs</li>
  <li>💎 VIPs (~1.6K) generate revenue comparable to ~14.8K New customers</li>
  <li>🔁 62% customers are one-time buyers</li>
</ul>

<h3>Churn & Retention</h3>
<ul>
  <li>⚠️ At-Risk customers generate the highest revenue</li>
  <li>🔒 Active customers form the most stable revenue base</li>
  <li>🎯 Churn is frequency-driven, not value-driven</li>
</ul>

<h3>Acquisition & Cohorts</h3>
<ul>
  <li>📈 Acquisition surged in 2012–2013; retention lagged</li>
  <li>🔄 Seasonal retention spikes in months 7, 8, and 12</li>
  <li>🧩 Hybrid base: one-time buyers + loyal enthusiasts</li>
</ul>

<h3>Product–Customer Interaction</h3>
<ul>
  <li>🧲 Low-cost accessories dominate acquisition</li>
  <li>💰 High-priced bikes are mostly one-time purchases</li>
  <li>🔄 Repeat purchases are rare across products</li>
</ul>

<hr>

<h2 id="recommendations">8. 📈 Business Recommendations</h2>
<ul>
  <li>Prioritize win-back campaigns for At-Risk high-value customers</li>
  <li>Create structured upsell paths from accessories to bikes</li>
  <li>Improve onboarding for new customers</li>
  <li>Rationalize low-performing products</li>
  <li>Invest in loyalty programs for Active & VIP customers</li>
</ul>

<hr>

<h2 id="skills">9. 🛠 Tools & Skills Demonstrated</h2>
<ul>
  <li>SQL (MySQL)</li>
  <li>CTEs & Window Functions</li>
  <li>Star Schema & Data Warehousing</li>
  <li>Time-Series Analysis</li>
  <li>RFM & Cohort Analysis</li>
  <li>Business-Driven EDA</li>
  <li>KPI & Metric Engineering</li>
</ul>

<hr>

<p><b>⭐ If you like this project, feel free to star the repository!</b></p>
