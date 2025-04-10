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

SELECT country, SUM(total_laid_off)
FROM tech_layoffs_dup
GROUP BY country
ORDER BY 2 DESC
LIMIT 5;

-- Answer: United States, Germany, India, United Kingdom, Sweden

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
    COUNT(CASE 
			WHEN percentage_laid_off IS NULL THEN 1 
		  END) AS percentage_laid_off_nulls,
    COUNT(CASE WHEN total_laid_off IS NULL THEN 1 END) AS total_laid_off_nulls
FROM tech_layoffs_dup;

-- Answer: 391 percentage_laid_off_nulls, 0 total_laid_off_nulls Meaning they report more in terms of Absolute Numbers than Percentages.

-- -----------------------------------------------------------------------------------------------------------------------------------------
/*
2. Intermediate Analysis (Joins, Ranking, Conditional Logic)

2.1. Company-Specific Insights
2.1.1. Which 10 companies had the largest layoffs (by headcount and percentage)?
2.1.2. Are companies at certain stages (e.g., stage = 'Acquired') more likely to lay off employees?

2.2. Financial Correlations
2.2.1. Do companies with higher funds_raised have larger/smaller layoffs?
2.2.2. What is the average funds raised for companies that laid off >20% of their workforce?

2.3. Temporal Patterns
2.3.1. How did layoffs trend quarter-over-quarter?
2.3.2. Are layoffs concentrated in specific weeks/months of the year?

2.4. Industry vs. Country
2.4.1. Which country-industry pairs have the most severe layoffs?
2.4.2. Are certain industries declining globally or only in specific regions?
*/

-- Section: 2.1. Company-Specific Insights
-- Qstn: 2.1.1. Which 10 companies had the largest layoffs (by headcount and percentage)?

-- Order by Both Headcount and Percentage
SELECT company, total_laid_off, percentage_laid_off
FROM tech_layoffs_dup
WHERE percentage_laid_off IS NOT NULL
ORDER BY total_laid_off DESC,  percentage_laid_off DESC
LIMIT 10;

-- Order by Headcount
SELECT company, total_laid_off, percentage_laid_off
FROM tech_layoffs_dup
WHERE percentage_laid_off IS NOT NULL
ORDER BY total_laid_off DESC
LIMIT 10;

-- Order by Percentage Laid Off
SELECT company, total_laid_off, percentage_laid_off
FROM tech_layoffs_dup
WHERE percentage_laid_off IS NOT NULL
ORDER BY percentage_laid_off DESC
LIMIT 10;

/* Answer: 
By both Headcount and Percentage: Intel, Tesla, Google, Microsoft, Ericsson, Flink, Salesforce, SAP, Amazon, Dell
By Headcount: Intel, Tesla, Google, Microsoft, Ericsson, SAP, Amazon, Flink, Salesforce, Dell
By Percentage: We have a lot that did 100% lay offs going beyond the 10 limit: Humble Games, EMX Digital, Dealtale, Dropp, ON, Assurance, Scribe Media, Avocargo, Arkane Studios, Phantom Auto
*/
-- Qstn: 2.1.2. Are companies at certain stages (e.g., stage = 'Acquired') more likely to lay off employees?
SELECT stage, 
	   ROUND(AVG(total_laid_off), 2), 
       AVG(percentage_laid_off),
       COUNT(*) AS companies_count
FROM tech_layoffs_dup
WHERE stage IS NOT NULL
GROUP BY stage
ORDER BY AVG(percentage_laid_off) DESC;

-- Answer: Ordered as  Seed, Series A, Unknown, Series B, Acquired, Subsidiary, Series C, Series D, Series E, Private Equity, Post-IPO, Series H, Series G, Series F, Series J, Series I

-- Section: 2.2. Financial Correlations

-- Qstn: 2.2.1. Do companies with higher funds_raised have larger/smaller layoffs? (MIN 1, MAX 27200, AVG 870.3721282279607 )

-- Two Step Implementation
SELECT AVG(funds_raised)
FROM tech_layoffs_dup;

-- Answer: AVG 870.3721282279607

SELECT
	CASE
		WHEN funds_raised < 870.3721282279607 THEN "lower_funds_raised"
        WHEN funds_raised > 870.3721282279607 THEN "higher_funds_raised"
        -- ELSE "Other"
    END AS funds_raised_category,
    AVG(percentage_laid_off) AS avg_percentage_laid_off
FROM tech_layoffs_dup
WHERE funds_raised IS NOT NULL
GROUP BY funds_raised_category
ORDER BY 2 DESC;

-- More Integrated Query 
SELECT
    CASE
        WHEN funds_raised < (SELECT AVG(funds_raised) FROM tech_layoffs_dup)  -- SUBQUERY IN SELECT STATEMENT FOR CALCULATING AVERAGE
            THEN 'lower_funds_raised'
        WHEN funds_raised > (SELECT AVG(funds_raised) FROM tech_layoffs_dup) 
            THEN 'higher_funds_raised'
    END AS funds_raised_category,
    ROUND(AVG(percentage_laid_off), 2) AS avg_percentage_laid_off, -- ROUND TO 2 D.P.
    ROUND(AVG(total_laid_off), 2) AS avg_headcount_laid_off, -- ROUND TO 2 D.P.
    COUNT(*) AS companies_count,
    AVG(funds_raised)
FROM tech_layoffs_dup
WHERE funds_raised IS NOT NULL
GROUP BY funds_raised_category
ORDER BY avg_percentage_laid_off DESC;

/*Thoughts on the 2 above Implementations:

Limitations:
1. Using two separate queries requires manual calculation
2. The average might be skewed by extreme outliers (max 27,200 vs avg ~870)
3. Equal values (= 870.37) are excluded (though rare)
*/

-- Robust Implementation

-- This subquery calculates how many rows to skip to reach the median
SELECT median_offset 
FROM (
	 -- For median position: count all records and divide by 2
	 -- FLOOR() rounds down to nearest integer (for odd counts)
		SELECT FLOOR(COUNT(*)/2) AS median_offset 
		FROM tech_layoffs_dup 
		WHERE funds_raised IS NOT NULL
) AS offset_calc;  -- Every Derived Table must be Named

-- Median Offset = 561

-- Create a temporary result set named 'stats' that we can reference later
WITH stats AS (
    SELECT 
        -- Calculate the average funds raised across all companies
        AVG(funds_raised) AS avg_funds,
        -- Start calculating the median (middle value) of funds_raised
        (SELECT funds_raised 
         FROM tech_layoffs_dup 
         -- Only consider non-null values for accurate calculation
         WHERE funds_raised IS NOT NULL
         -- Sort all values from smallest to largest
         ORDER BY funds_raised 
         -- We only want to return 1 row (the median)
         LIMIT 1 
         -- OFFSET skips the first N rows before returning results
         OFFSET 561
        ) AS median_funds  -- Names the median calculation result
    FROM tech_layoffs_dup
    -- Only include rows where funds_raised exists for our calculations
    WHERE funds_raised IS NOT NULL
)
SELECT
    CASE
        WHEN t.funds_raised < s.avg_funds THEN 'below_avg_funds'
        WHEN t.funds_raised >= s.avg_funds THEN 'above_avg_funds'
    END AS funding_category,
    ROUND(AVG(t.percentage_laid_off), 2) AS avg_percentage_laid_off,
    ROUND(AVG(t.total_laid_off), 2) AS avg_headcount_laid_off,
    COUNT(*) AS companies_count,
    MIN(t.funds_raised) AS min_funds_in_category,
    MAX(t.funds_raised) AS max_funds_in_category,
    ROUND(s.avg_funds, 2),
    ROUND(s.median_funds, 2),
    ROUND(AVG(funds_raised), 2)
FROM tech_layoffs_dup t
CROSS JOIN stats s
WHERE t.funds_raised IS NOT NULL
GROUP BY funding_category,
		 s.avg_funds,
         s.median_funds;
         
/*
Answer: The Average is Skewed with Mean at 870.37 and the Median at 235.00, 
all considered when companies making "Below Average Funds" have an Average Percentage Laid off of 21%;
and companies making "Above Average Funds" have an Average Percentage Laid off of 17%;
*/

-- Qstn: 2.2.2. What is the average funds raised for companies that laid off >20% of their workforce?

SELECT AVG(funds_raised) AS avg_funds_raised
FROM tech_layoffs_dup
WHERE percentage_laid_off > 0.2;

-- Answer: 504.1835748792271 million

-- Section: 2.3. Temporal Patterns
-- 2.3.1. How did layoffs trend quarter-over-quarter?

-- Way 1 to Execute this
-- Understand the Date Boundaries
SELECT MIN(`date`), MAX(`date`)
FROM tech_layoffs_dup;

-- Check if there are values for every
SELECT MONTH(`date`), SUM(total_laid_off), AVG(percentage_laid_off)
FROM tech_layoffs_dup
GROUP BY MONTH(`date`)
ORDER BY 1;

SELECT 
	CASE
		WHEN `date` BETWEEN "2023-01-01 00:00:00" AND "2023-03-31 00:00:00" THEN "2023 Q1"
        WHEN `date` BETWEEN "2023-04-01 00:00:00" AND "2023-06-30 00:00:00" THEN "2023 Q2"
        WHEN `date` BETWEEN "2023-07-01 00:00:00" AND "2023-09-30 00:00:00" THEN "2023 Q3"
        WHEN `date` BETWEEN "2023-10-01 00:00:00" AND "2023-12-31 00:00:00" THEN "2023 Q4"
        WHEN `date` BETWEEN "2024-01-01 00:00:00" AND "2024-03-31 00:00:00" THEN "2024 Q1"
        WHEN `date` BETWEEN "2024-04-01 00:00:00" AND "2024-06-30 00:00:00" THEN "2024 Q2"
        WHEN `date` BETWEEN "2024-07-01 00:00:00" AND "2024-09-30 00:00:00" THEN "2024 Q3"
        WHEN `date` BETWEEN "2024-10-01 00:00:00" AND "2024-12-31 00:00:00" THEN "2024 Q4"
        WHEN `date` BETWEEN "2025-01-01 00:00:00" AND "2025-03-31 00:00:00" THEN "2025 Q1"
    END AS Quarter_Year,
    SUM(total_laid_off), AVG(percentage_laid_off)
FROM tech_layoffs_dup
WHERE `date` IS NOT NULL
GROUP BY Quarter_Year
ORDER BY 1;

-- To confirm if there is any data in any month or year 
SELECT COUNT(*) 
FROM tech_layoffs_dup 
WHERE MONTH(`date`) IN (7,8,9) AND YEAR(`date`) IN (2023,2024);

-- Way 2 to Execute this

SELECT YEAR(`date`),
       QUARTER(`date`), 
       SUM(total_laid_off), 
       AVG(percentage_laid_off)
FROM tech_layoffs_dup
WHERE percentage_laid_off IS NOT NULL
GROUP BY YEAR(`date`), QUARTER(`date`)
ORDER BY 1,2;

-- Qstn: 2.3.2. Are layoffs concentrated in specific weeks/months of the year?
-- for Weeks
SELECT WEEKOFYEAR(`date`) AS week_of_year, 
       SUM(total_laid_off), 
       AVG(percentage_laid_off),
       COUNT(*) AS layoff_events
FROM tech_layoffs_dup
WHERE `date` IS NOT NULL
GROUP BY WEEKOFYEAR(`date`)
ORDER BY 3 DESC; -- change columns to order by between Total Laid Off and Percentage Laid Off metrics

-- for Months
SELECT MONTHNAME(`date`) AS month_name, 
       SUM(total_laid_off), 
	   AVG(percentage_laid_off),
       COUNT(*) AS layoff_events
FROM tech_layoffs_dup
WHERE `date` IS NOT NULL
GROUP BY MONTHNAME(`date`)
ORDER BY 3 DESC; -- change columns to order by between Total Laid Off and Percentage Laid Off metrics

-- Answer:  Collectively Companies lay off most people on Average in December and June, by Total most people where laid off in January and February 

-- Section: 2.4. Industry vs. Country

-- Qstn: 2.4.1. Which country-industry pairs have the most severe layoffs?

SELECT country, 
       industry, 
       SUM(total_laid_off), 
       AVG(percentage_laid_off),
       COUNT(*) AS cases
FROM tech_layoffs_dup
WHERE country IS NOT NULL
      AND industry IS NOT NULL
GROUP BY country, industry
ORDER BY 3 DESC;  -- Change Order by column between 3 and 4 here

-- Answer: When considering by Total Number of Laid Off Persons, Top 5: United States-Hardware, United States-Consumer, United States-Other, United States-Retail, United States-Transportation
-- Answer: When considering by Average Percentage Laid Off, Top 5: Germany-Aerospace, Denmark-Retail, United Kingdom-Education, Australia-Food, Ireland-Healthcare

-- Qstn: 2.4.2. Are certain industries declining globally or only in specific regions?

WITH global_industry AS (
    SELECT 
        industry,
        SUM(total_laid_off) AS global_layoffs,
        COUNT(*) AS global_cases
    FROM 
        tech_layoffs_dup
    GROUP BY 
        industry
),
country_industry AS (
    SELECT 
        country,
        industry,
        SUM(total_laid_off) AS country_layoffs,
        COUNT(*) AS country_cases
    FROM 
        tech_layoffs_dup
    GROUP BY 
        country, industry
)
SELECT 
    ci.country,
    ci.industry,
    ci.country_layoffs,
    gi.global_layoffs,
    ROUND((ci.country_layoffs/gi.global_layoffs)*100, 2) AS pct_of_global
FROM 
    country_industry ci
JOIN 
    global_industry gi ON ci.industry = gi.industry
ORDER BY 
    pct_of_global DESC
LIMIT 20;


-- --------------------------------------------------------------------------------------------------------------------------------------------


