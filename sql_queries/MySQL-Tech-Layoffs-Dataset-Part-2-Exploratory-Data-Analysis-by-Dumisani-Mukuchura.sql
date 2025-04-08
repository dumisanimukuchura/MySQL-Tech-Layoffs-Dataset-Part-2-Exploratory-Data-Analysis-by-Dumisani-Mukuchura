/*
Project: Data Cleaning with SQL on a Tech Layoffs Dataset by Dumisani Mukuchura
By: Dumisani Maxwell Mukuchura
Email: dumisanimukuchura@gmail.com
Dataset: https://www.kaggle.com/datasets/swaptr/layoffs-2022

Description:
Building on the cleaned dataset from Part 1, this project performs comprehensive Exploratory Data Analysis (EDA) on tech industry layoffs using SQL. The analysis progresses from basic aggregations to advanced window functions, uncovering trends in layoffs by time, geography, industry, and company stage.

Key Sections:
🔹 Basic Analysis: Aggregations, time trends, and geographical distributions.
🔹 Intermediate Analysis: Company rankings, financial correlations, and temporal patterns.
🔹 Advanced Analysis: Cumulative metrics, anomaly detection, and industry-country insights.
*/

-- 0 Understand Dataset: the Columns, Rows and setup.
-- 0.0 Preview the Dataset and view Columns and Rows to have a sense of the Dataset.

SELECT *
FROM tech_layoffs_dup;

/*
1. Basic Analysis (Aggregations & Filtering)

1.1. Descriptive Statistics
1.1.1. What is the total number of employees laid off across all companies?
1.1.2. What is the average percentage of employees laid off per company?
1.1.3. How many companies have not reported total_laid_off or percentage_laid_off?

1.2 Time-Based Trends
1.2.1. How many layoffs occurred each month/year?
1.2.2. Which month had the highest number of layoffs?

1.3. Geographical Distribution
1.3.1. Which countries have the most layoffs?
1.3.2. How do layoffs differ between U.S. and Non-U.S. locations (us_status)?

1.4. Industry Focus
1.4.1. Which industries have the highest total layoffs?
1.4.2. Are certain industries more likely to report layoffs as percentages vs. absolute numbers?
*/

-- Section: 1.1. Descriptive Statistics
-- Qstn: 1.1.1. What is the total number of employees laid off across all companies?

SELECT SUM(total_laid_off) AS Total_Employeed_Laid_Off
FROM tech_layoffs_dup;

-- Answer: 414245

-- Qstn: 1.1.2. What is the average percentage of employees laid off per company?

SELECT AVG(percentage_laid_off)
FROM tech_layoffs_dup
WHERE percentage_laid_off IS NOT NULL;

-- Answer: 0.208953

-- Qstn: 1.1.3. How many companies have not reported total_laid_off or percentage_laid_off?

SELECT COUNT(company)
FROM tech_layoffs_dup
WHERE total_laid_off IS NULL OR percentage_laid_off IS NULL;

-- Answer: 391

-- Section: 1.2 Time-Based Trends
-- 1.2.1. How many layoffs occurred each month/year?
-- a) each month

SELECT MONTH(`date`),  SUM(total_laid_off) AS Total_Laid_Off
FROM tech_layoffs_dup
GROUP BY MONTH(`date`)
ORDER BY 1;

-- b) each year

SELECT YEAR(`date`),  SUM(total_laid_off) AS Total_Laid_Off
FROM tech_layoffs_dup
GROUP BY YEAR(`date`)
ORDER BY 1;

-- 1.2.2. Which month had the highest number of layoffs?

WITH Monthly_Laid_Off(`month`, monthly_total_laid_off)  AS
(
SELECT MONTH(`date`), SUM(total_laid_off) 
FROM tech_layoffs_dup
GROUP BY MONTH(`date`)
ORDER BY 1
)
SELECT `month`, monthly_total_laid_off
FROM Monthly_Laid_Off
WHERE monthly_total_laid_off = (
	SELECT MAX(monthly_total_laid_off)
	FROM Monthly_Laid_Off
);

-- Answer: Month 1: 123003

-- SECTION: 1.3. Geographical Distribution

-- Qstn: 1.3.1. Which countries have the most layoffs?

SELECT *
FROM tech_layoffs_dup
ORDER BY total_laid_off DESC
LIMIT 5;

-- Answer: Intel, Tesla, Google, Microsoft, Meta

-- Qstn: 1.3.2. How do layoffs differ between U.S. and Non-U.S. locations (us_status)?

SELECT us_status, SUM(total_laid_off)
FROM tech_layoffs_dup
GROUP BY us_status;

-- Answer: U.S.	298047, Non-U.S.	116198

-- 1.4. Industry Focus
-- Qstn: 1.4.1. Which industries have the highest total layoffs?

SELECT industry, SUM(total_laid_off)
FROM tech_layoffs_dup
GROUP BY industry
ORDER BY 2 DESC
LIMIT 5;

-- Answer: Other, Hardware, Consumer, Retail, Transportation

-- Qstn: 1.4.2. Are certain industries more likely to report layoffs as percentages vs. absolute numbers?

SELECT 
    COUNT(CASE WHEN percentage_laid_off IS NULL THEN 1 END) AS percentage_laid_off_nulls,
    COUNT(CASE WHEN total_laid_off IS NULL THEN 1 END) AS total_laid_off_nulls
FROM tech_layoffs_dup;

-- Answer: 391 percentage_laid_off_nulls, 0 total_laid_off_nulls Meaning they report more in terms of Absolute Numbers than Percentages.







