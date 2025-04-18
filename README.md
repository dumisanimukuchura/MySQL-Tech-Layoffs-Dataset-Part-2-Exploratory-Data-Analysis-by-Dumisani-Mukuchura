# MySQL Tech Layoffs Dataset - Part 2: Exploratory Data Analysis (EDA)

## Project Overview
This project continues the analysis of the **Tech Layoffs Dataset**, focusing on **Exploratory Data Analysis (EDA)** using **SQL (MySQL)**. Building on the cleaned dataset from Part 1, this phase aims to uncover patterns, trends, and relationships through **basic, intermediate, and advanced SQL techniques**.

- **Dataset Source:** [Kaggle - Tech Layoffs Dataset](https://www.kaggle.com/datasets/swaptr/layoffs-2022)
- **Tools Used:** MySQL, SQL Queries
- **Author:** Dumisani Maxwell Mukuchura
- **Email:** dumisanimukuchura@gmail.com
- **LinkedIn:** [LinkedIn Profile](https://www.linkedin.com/in/dumisani-maxwell-mukuchura-4859b7170/)

## Folder Structure
MySQL-Tech-Layoffs-Dataset-Part-2-EDA/ 
│── data/ # Contains the dataset 
│── nsql_queries/ # SQL scripts and documentation 
│── README.md # Project documentation


---

## Goals of This Project
- Understand dataset structure (columns, rows, and data types).
- Perform **basic aggregations** and **descriptive statistics**.
- Analyze **temporal trends** (monthly, quarterly).
- Explore **geographical distribution** of layoffs.
- Study **industry-specific** layoff patterns.
- Conduct **company-specific** ranking and segmentation.
- Investigate **financial correlations** (funds raised vs layoffs).
- Perform **cumulative analysis** and **ranking within industries**.
- Detect **anomalies** and **layoff clusters**.
- Explore **complex trends**, **hypothesis testing**, and **forecasting preparation**.

---

## Key Steps and Insights

### 1. Basic Analysis
- Total number of employees laid off: **414,245**.
- Average percentage laid off per company: **~21%**.
- United States leads globally in layoffs, followed by Germany, India, and the United Kingdom.
- Most layoffs by total count occurred in **January**.
- Industries most affected: **Hardware, Consumer, Retail, Transportation**.

### 2. Intermediate Analysis
- **Top Companies by Layoffs:** Intel, Tesla, Google, Microsoft, and others.
- Companies at **Seed and Series A** stages had higher layoff percentages.
- Companies with **lower funds raised** tended to have **higher layoff percentages**.
- **Layoffs spiked heavily in early 2023**, tapering slightly afterward.
- December and June had the **highest average percentage layoffs**.

### 3. Advanced Analysis
- **Cumulative layoffs** were tracked quarter-over-quarter.
- **Top 10% companies by layoffs** were identified using window functions.
- **Anomaly detection** highlighted companies that laid off despite strong funding.
- **Temporal clustering** around post-funding layoffs was analyzed.

### 4. Complex Trends & Predictive Insights
- **Early-stage companies** (Seed, Series A) showed the highest layoff percentages compared to late-stage ones.
- **Hardware and Infrastructure** industries saw the fastest month-over-month layoff growth.
- **Recovery analysis** identified industries like **Hardware, Sales, and Consumer** showing declining layoff trends.
- **Correlation between funds raised and layoffs** was weakly positive (**correlation coefficient ≈ 0.25**).
- **Layoff percentages were higher outside the U.S.** but the difference was **not statistically significant**.

### 5. Bonus: Advanced SQL Techniques
- Created **pivot tables** showing layoffs by industry and year.
- **Identified missing months** and **confirmed completeness** of the time series.
- Set up **rolling averages** to prepare for **forecasting future layoffs**.

---

## Final Outcomes
✅ Full **descriptive, diagnostic, and early predictive analysis** of the Tech Layoffs dataset.  
✅ Dataset is clean, structured, and ready for **predictive modeling** or **deeper business analysis**.  
✅ Clear understanding of **industry shifts**, **geographic layoffs**, and **company behaviors** post-pandemic.

---

## Next Steps
- Perform **predictive modeling** (forecasting future layoffs).
- Conduct **segmentation analysis** by funding stage or geographic region.
- Develop **dashboards** for dynamic visualization using tools like Tableau or Power BI.
- Extend hypothesis testing with external economic indicators (e.g., interest rates, GDP changes).

---

## License
This project is open-source and free to use.

---

🚀 *Happy Analyzing! Let me know if you'd like a next-phase README for modeling too!* 🚀
