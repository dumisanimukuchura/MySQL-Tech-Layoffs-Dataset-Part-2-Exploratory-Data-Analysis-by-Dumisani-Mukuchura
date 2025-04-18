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

-- Answer: Some Industries are dorminant in the Country United States: Infrastructure, Hardware, Sales, Support, Legal, HR, Product have above 90% concerntration in US.


-- --------------------------------------------------------------------------------------------------------------------------------------------

/*
3. Advanced Analysis (Window Functions, CTEs, Subqueries)

3.1. Cumulative Metrics
3.1.1. What is the cumulative number of layoffs over time?
3.1.2. How does each company’s layoff count compare to the industry average?

3.2. Ranking & Percentiles
3.2.1. Which companies are in the top 10% of layoffs within their industry?
3.2.2. How do layoffs rank by country when normalized by company size?

3.3. Anomaly Detection
3.3.1. Are there companies that laid off employees despite high funding (funds_raised)?
3.3.2. Identify companies with layoffs significantly above/below industry averages.

3.4. Temporal Clustering
3.4.1. Are there clusters of layoffs following specific dates (e.g., post-funding rounds)?
3.4.2. How long after funding do layoffs typically occur?
*/

-- SECTION: 3.1. Cumulative Metrics
-- 3.1.1. What is the cumulative number of layoffs over time?
WITH Ordered_By_Quarter AS
(
SELECT YEAR(`date`) AS year_,
	   QUARTER(`date`) AS quarter_, 
       SUM(total_laid_off) as quarterly_total_laid_off
FROM tech_layoffs_dup
GROUP BY YEAR(`date`), QUARTER(`date`) 
)
SELECT year_,
	   quarter_,
       quarterly_total_laid_off,
	   SUM(quarterly_total_laid_off) OVER(ORDER BY year_, quarter_) AS rolling_total_laid_off
FROM Ordered_By_Quarter;

-- 3.1.2. How does each company’s layoff count compare to the industry average?

SELECT t.company, t.industry, t.total_laid_off,  ROUND(Industry_Average_CTE.industry_average, 2)
FROM tech_layoffs_dup t 
JOIN (
	  SELECT industry, AVG(total_laid_off) AS industry_average
	  FROM tech_layoffs_dup
	  GROUP BY industry
     ) AS Industry_Average_CTE
	ON t.industry = Industry_Average_CTE.industry
ORDER BY 4 DESC;

-- SECTION: 3.2. Ranking & Percentiles
-- 3.2.1. Which companies are in the top 10% of layoffs within their industry?

-- Way 1:
WITH Total_Laid_Off AS ( -- Calculating the Total Number of Companies in an Industry
    SELECT 
        company,
        industry,
        total_laid_off,
        ROW_NUMBER() OVER (PARTITION BY industry ORDER BY total_laid_off DESC) AS ranking, -- Adds Rank from 1 going Upwards per Industry with Order From Highest Total Laid Off
        COUNT(*) OVER (PARTITION BY industry) AS total_companies
    FROM tech_layoffs_dup
),
Top_10_Percent AS ( -- Creating the Number of Companies in top 10 of an Industry utilizing Arithmetic on Total Companies Count  
    SELECT 
        company,
        industry,
        total_laid_off,
        ranking,
        total_companies,
        -- Calculate the top 10% cutoff
        CEILING(total_companies * 0.1) AS top_10_threshold -- Ceiling:  to round up fractional values.
    FROM Total_Laid_Off
)
SELECT 
    company,
    industry,
    total_laid_off,
    ranking
FROM Top_10_Percent
WHERE ranking <= top_10_threshold  -- Filter out Companies within the Top 10 by Rank 
ORDER BY industry, total_laid_off DESC;

-- Way 2 utilizing NTILE: The NTILE(n) function divides the result set into n buckets, ranking rows in a percentile-like manner.
WITH RankedCompanies AS (
    SELECT 
        company,
        industry,
        total_laid_off,
        NTILE(10) OVER (PARTITION BY industry ORDER BY total_laid_off DESC) AS percentile_rank
    FROM tech_layoffs_dup
)
SELECT 
    company,
    industry,
    total_laid_off
FROM RankedCompanies
WHERE percentile_rank = 1
ORDER BY industry, total_laid_off DESC;

-- 3.2.2. How do layoffs rank by country when normalized by company size? 

/*
This Query will not Work considering we do not have the Total Company Size just the Total Laid Off and Percentage Laid Off
*/

-- Query to Calculate the Approximate Original Workforce
WITH LayoffCalculations AS (
    SELECT 
        company,
        total_laid_off,
        percentage_laid_off,
        total_laid_off / (percentage_laid_off / 100.0) AS workforce_at_time_of_layoff
    FROM tech_layoffs_dup
),
CompanyWorkforceEstimates AS (
    SELECT 
        company,
        MAX(workforce_at_time_of_layoff) AS estimated_original_workforce
    FROM LayoffCalculations
    GROUP BY company
)
SELECT 
    company,
    estimated_original_workforce
FROM CompanyWorkforceEstimates
ORDER BY estimated_original_workforce DESC;

/*
Still this can not work as there are more that 1 subsequent LayOffs from one company as time progressed
Thus we will include a Query on how to do it but considering if we had the Company Size prior to LayOffs
*/

-- Query to Calculate the Approximate Current Workforce at the stage of Laying Off. This unearths some inconsistencies e.g other undeclared Employee Outage not Layoffs or Layoffs that were not reported.

-- Alternative estimation approach considering multiple layoffs
WITH company_timeline AS (
    SELECT 
        company,
        date,
        total_laid_off,
        percentage_laid_off,
        SUM(total_laid_off) OVER(PARTITION BY company ORDER BY date) AS cumulative_laid_off,
        LAG(date) OVER(PARTITION BY company ORDER BY date) AS prev_layoff_date
    FROM tech_layoffs_dup
)
SELECT 
    company,
    date,
    total_laid_off,
    percentage_laid_off,
    cumulative_laid_off / (percentage_laid_off) AS estimated_current_workforce_at_that_stage
FROM company_timeline
WHERE percentage_laid_off > 0; 

-- Query to have been used to Calculate the Normalized Layoffs
WITH NormalizedLayoffs AS (
    -- Calculate layoffs normalized by company size for each country
    SELECT 
        country,
        SUM(total_laid_off) AS total_layoffs,
        SUM(company_size) AS total_company_size, -- Aggregate company size by country
        CAST(SUM(total_laid_off) AS FLOAT) / NULLIF(SUM(company_size), 0) AS normalized_layoffs -- Prevent division by 0
    FROM tech_layoffs_dup
    GROUP BY country
),
RankedCountries AS (
    -- Rank countries based on normalized layoffs
    SELECT 
        country,
        total_layoffs,
        total_company_size,
        normalized_layoffs,
        RANK() OVER (ORDER BY normalized_layoffs DESC) AS rank_by_layoffs
    FROM NormalizedLayoffs
)
-- Retrieve the final ranked results
SELECT 
    country,
    total_layoffs,
    total_company_size,
    normalized_layoffs,
    rank_by_layoffs
FROM RankedCountries
ORDER BY rank_by_layoffs;

-- SECTION: 3.3. Anomaly Detection
-- 3.3.1. Are there companies that laid off employees despite high funding (funds_raised)?

SELECT company, funds_raised
FROM tech_layoffs_dup
WHERE funds_raised > (
					 SELECT AVG(funds_raised)
                     FROM tech_layoffs_dup
)
ORDER BY funds_raised DESC;

-- 3.3.2. Identify companies with layoffs significantly above/below industry averages.

WITH RankedCompanies AS 
(
SELECT *,
       NTILE(10) OVER(ORDER BY total_laid_off DESC) AS percentile_rank
FROM tech_layoffs_dup
)
SELECT 
    company,
    industry,
    total_laid_off,
    percentile_rank
FROM RankedCompanies
WHERE percentile_rank = 1 OR
	  percentile_rank = 10
ORDER BY percentile_rank DESC;

-- SECTION: 3.4. Temporal Clustering
-- 3.4.1. Are there clusters of layoffs following specific dates (e.g., post-funding rounds)?

-- Confirm there are companies with multiple stages
SELECT t1.company, t1.stage, t1.total_laid_off, t2.stage, t2.total_laid_off
FROM tech_layoffs_dup t1
JOIN tech_layoffs_dup t2
	ON t1.company = t2.company 
    AND t1.stage != t2.stage;
    
-- Query to find availability of clusters in certain specific dates (by funding rounds)
WITH StageClusters AS (
    -- Group layoffs by stage and calculate metrics
    SELECT 
        stage,
        COUNT(*) AS layoffs_count,
        AVG(total_laid_off) AS avg_laid_off, -- Average layoffs for each stage
        AVG(percentage_laid_off) AS avg_percentage_laid_off -- Average percentage layoffs for each stage
    FROM tech_layoffs_dup
    GROUP BY stage
),
ClusteredLayoffsByStage AS (
    -- Dynamically split stages into clusters using a subquery for the average
    SELECT 
        stage,
        layoffs_count,
        avg_laid_off,
        avg_percentage_laid_off,
        CASE 
            WHEN avg_laid_off >= (SELECT AVG(total_laid_off) FROM tech_layoffs_dup) THEN 'High Layoff Cluster'
            WHEN avg_laid_off BETWEEN ((SELECT AVG(total_laid_off) FROM tech_layoffs_dup) * 0.5) AND ((SELECT AVG(total_laid_off) FROM tech_layoffs_dup) - 1) THEN 'Moderate Layoff Cluster'
            ELSE 'Low Layoff Cluster'
        END AS cluster_category
    FROM StageClusters
)
-- Display cluster results
SELECT 
    stage,
    cluster_category,
    layoffs_count,
    ROUND(avg_laid_off, 2),
    avg_percentage_laid_off
FROM ClusteredLayoffsByStage
ORDER BY cluster_category DESC, layoffs_count DESC;

/* Answer: 
Low Layoff Cluster: Unknown, Series B, Series C, Series D, Series A, Series F, Seed, Series H, Series G
Medium Layoff Cluster: Acquired, Series E, Private Equity, Subsidiary, Series I, Series J
High Layoff Cluster: PostIPO
*/

-- 3.4.2. How long after funding do layoffs typically occur?

-- Response: This question is not Answerable with the current information we do not have dates where rounds of funding happened we just have a mention of date of layoff and the stage when that happened.

/*
4. Complex Trends & Predictive Insights
4.1. Segmentation by Company Stage
4.1.1. Do early-stage startups (stage = 'Seed') have different layoff patterns than late-stage companies?

4.2. Impact of Industry
4.2.1. Which industries saw the fastest month-over-month growth in layoffs?
4.2.2. Are certain industries recovering (declining layoffs over time)?

4.3. Correlation Analysis
4.3.1. Is there a correlation between funds_raised and total_laid_off?
4.3.2. How does percentage_laid_off correlate with us_status or country?

4.4. Text Analysis
4.4.1. Are there industries or locations frequently appearing with terms like "Acquired" or "Bankrupt" in stage?
*/


-- SECTION 4. Complex Trends & Predictive Insights
-- 4.1. Segmentation by Company Stage
-- Qstn: 4.1.1. Do early-stage startups (stage = 'Seed') have different layoff patterns than late-stage companies?

-- Understand which stages are included in this Dataset
SELECT distinct(stage)
FROM tech_layoffs_dup;

-- Understand how data has been captured in terms of months
SELECT YEAR(`date`), COUNT(DISTINCT(MONTH(`date`))) AS month_count
FROM tech_layoffs_dup
GROUP BY YEAR(`date`);

-- We have full data for 2023, 2024 then 2025 has data for 3 months, thus for the analysis we can have a group by YEAR too.

-- Compare Early Stages to Mid and Late in terms of Average Layoffs, Average Percentage Layoffs and also Cases of Layoffs for the year 2023 since in the Dataset we have full year data for that year in our Dataset
WITH stage_groups AS (
-- Group the Stages into Early, Mid and Late using CASE STATEMENTS
    SELECT 
        CASE
            WHEN stage IN ('Seed', 'Series A', 'Series B') THEN 'Early' -- Early: Focuses on initial product development, market fit, and first scaling efforts.
            WHEN stage IN ('Private Equity', 'Subsidiary', 'Post-IPO', 'Acquired') THEN 'Late'  -- Late: Focuses on preparing for exit (IPO, acquisition), global expansion, dominance, or becoming part of a larger company (subsidiary, acquisition)
            ELSE 'Mid' -- Mid: Series C, Series D, Series E, Series F, Series G, Series H, Series I, Series J - Focuses on growing user/customer base, entering new markets, building out operations.
        END AS stage_group,
        total_laid_off,
        percentage_laid_off,
        date
    FROM tech_layoffs_dup
)
SELECT YEAR(`date`) AS year_,
       stage_group,
       ROUND(AVG(total_laid_off)) AS avg_layoffs,
       AVG(percentage_laid_off) AS avg_percentage,
       COUNT(*) AS cases,
    -- Trend analysis Quarter to Quarter
       SUM(CASE WHEN QUARTER(`date`) = 1 THEN total_laid_off ELSE 0 END) AS q1_layoffs,
       SUM(CASE WHEN QUARTER(`date`) = 2 THEN total_laid_off ELSE 0 END) AS q2_layoffs,
       SUM(CASE WHEN QUARTER(`date`) = 3 THEN total_laid_off ELSE 0 END) AS q3_layoffs,
       SUM(CASE WHEN QUARTER(`date`) = 4 THEN total_laid_off ELSE 0 END) AS q4_layoffs
FROM stage_groups
GROUP BY year_, stage_group
ORDER BY year_ ASC, avg_percentage DESC;

/* Answer: 
In 2023 Early stage Companies had the highest Average Layoff Percentage, the 2nd Highest Total Number of Layoffs, the Least amount of Layoff Cases, Quarter 2 had the Highest Total Number of Layoffs,
In 2024 Early stage Companies had the highest Average Layoff Percentage, the Lowest Total Number of Layoffs, the Least amount of Layoff Cases, Quarter 2 had the Highest Total Number of Layoffs.
In 2025 we have data for Q1 Only remember: Early stage Companies had the highest Average Layoff Percentage, the Lowest Total Number of Layoffs, the Least amount of Layoff Cases.
*/

-- 4.2. Impact of Industry
-- Qstn: 4.2.1. Which industries saw the fastest month-over-month growth in layoffs?

WITH monthly_trends AS (
    SELECT 
        industry,
        YEAR(`date`) AS year_,
        MONTH(`date`) AS month_,
        SUM(total_laid_off) AS monthly_layoffs,
        LAG(SUM(total_laid_off), 1) OVER (PARTITION BY industry ORDER BY YEAR(`date`), MONTH(`date`)) AS prev_month -- Lag by 1 Month and Group by Industry over Year and Month
    FROM tech_layoffs_dup
    GROUP BY industry, YEAR(`date`), MONTH(`date`)
)
SELECT 
    industry,
    ROUND(AVG((monthly_layoffs - prev_month) / NULLIF(prev_month, 0)), 2) AS avg_growth_rate, -- Prevent Division by Zero
    COUNT(*) AS months_with_growth
FROM monthly_trends
WHERE prev_month IS NOT NULL
GROUP BY industry
ORDER BY avg_growth_rate DESC
LIMIT 10;

/* Answer: 
Average Groth Rate of Month on Month Total Number of People Laid Of Top 10 Starting with the Highest:
Hardware - 15 months with growth
Infrastructure - 11 months with growth
Manufacturing - 6 months with growth
Transportation - 22 months with growth
Media - 17 months with growth
Other - 24 months with growth
Sales - 12 months with growth
Consumer - 21 months with growth
HR - 14 months with growth
Marketing - 18 months with growth
*/

-- Additional Twisted Qstn to Add more Learning Depth: 4.2.1. Which industries saw the fastest Quarter-over-Quarter Growth in Layoffs?

WITH QuarterlyPercentages AS
-- Step 1: Aggregate Layoffs by Quarter Grouped by Year and Industry
(
SELECT industry,
	   YEAR(`date`) AS year_,
	   QUARTER(`date`) AS quarter_,
       AVG(percentage_laid_off) AS avg_quarterly_percentage
FROM tech_layoffs_dup
WHERE percentage_laid_off IS NOT NULL 
GROUP BY year_, quarter_, industry
),
QoQGrowthAnalysis AS
-- Step 2: Calculate Quarter on Quarter Growth for each Industry 
(
SELECT qp1.year_,
       qp1.industry,
       qp1.quarter_ AS current_quarter,
       qp2.quarter_ AS previous_quarter,
       CASE
			WHEN qp2.avg_quarterly_percentage > 0 THEN
            ((qp1.avg_quarterly_percentage - qp2.avg_quarterly_percentage) / qp2.avg_quarterly_percentage)
            ELSE NULL
	   END AS qoq_growth_percentage
FROM QuarterlyPercentages AS qp1 
JOIN QuarterlyPercentages AS qp2
  ON qp1.industry = qp2.industry
  AND (
      -- Same year, sequential quarters
      (qp1.year_ = qp2.year_ AND qp1.quarter_ = qp2.quarter_ + 1)
      OR
      -- Year transition (Q1 vs previous Q4)
      (qp1.year_ = qp2.year_ + 1 AND qp1.quarter_ = 1 AND qp2.quarter_ = 4)
  )
),
RankedIndustries AS 
-- Step 3: Rank industries based on QoQ Growth Percentage
(
SELECT industry,
       year_,
       previous_quarter,
	   current_quarter,
       qoq_growth_percentage,
       ROW_NUMBER() OVER (PARTITION BY year_ ORDER BY qoq_growth_percentage DESC) AS rn -- Useful to Limit results by Year to Get the Top 5 QoQ by Industry
FROM QoQGrowthAnalysis
WHERE qoq_growth_percentage IS NOT NULL -- Exclude cases without previous data
-- ORDER BY year_ ASC,qoq_growth_percentage DESC
)
-- Display top industries with the fastest QoQ growth
SELECT industry,
       year_,
       previous_quarter,
	   current_quarter,
       qoq_growth_percentage
FROM RankedIndustries
WHERE rn <= 5;

/* Answer:
Year: 2023: Top 5 Industries from Highest to Lowest: Sales(Q2 to Q3), Logistics(Q3 to Q4), HR(Q3 to Q4), Logistics(Q2 to Q3), Product(Q2 to Q3)
Year: 2024: Top 5 Industries from Highest to Lowest: Real Eastate(Q3 to Q4), Finance(Q3 to Q4), Sales(Q1 to Q2), Consumer(Q3 to Q4), Security(Q1 to Q2)
Year: 2025: Top 5 Industries from Highest to Lowest considering it has only Q1 Data: Security(Q4 to Q1), Food(Q4 to Q1), Transportation(Q4 to Q1), Other(Q4 to Q1), Support(Q4 to Q1)
*/

-- Qstn: 4.2.2. Are certain industries recovering (declining layoffs over time)?
-- Way 1 of analyzing Declining Layoffs over Time: by Percentage Laid Off)
WITH LayoffsAggregate AS
(
SELECT industry,
       YEAR(`date`) AS year_,
       QUARTER(`date`) AS quarter_,
	   AVG(percentage_laid_off) AS avg_percentage_laid_off
FROM tech_layoffs_dup
GROUP BY year_, industry, quarter_
),
LayOffTrendAnalysis AS
(
SELECT t1.industry,
       t1.year_,
	   t1.quarter_ AS current_quarter,
       t2.quarter_ AS previous_quarter,
       t1.avg_percentage_laid_off AS current_avg_percentage,
       t2.avg_percentage_laid_off AS previous_avg_percentage,
       (t1.avg_percentage_laid_off - t2.avg_percentage_laid_off) AS layoff_delta_percentage
FROM LayoffsAggregate t1
JOIN LayoffsAggregate t2
	ON t1.industry = t2.industry
    AND (
      -- Same year, sequential quarters
      (t1.year_ = t2.year_ AND t1.quarter_ = t2.quarter_ + 1)
      OR
      -- Year transition (Q1 vs previous Q4)
      (t1.year_ = t2.year_ + 1 AND t1.quarter_ = 1 AND t2.quarter_ = 4)
  )
),
RecoveringIndustries AS
(
SELECT industry,
	   AVG(layoff_delta_percentage) AS layoff_avg_delta, -- Average Change per Period
       COUNT(
             CASE 
				WHEN layoff_delta_percentage < 0 THEN 1
			 END
			)  AS declining_periods,
	   COUNT(*) AS total_periods
FROM LayOffTrendAnalysis
GROUP BY industry
HAVING AVG(layoff_delta_percentage) < 0 -- Ensure overall negative trend (decline)
	-- AND  declining_periods = total_periods  -- All periods show decline
)
-- Step 4: Display Recovering Industries 
SELECT industry,
	   layoff_avg_delta AS avg_decline_percentage,
       declining_periods
FROM RecoveringIndustries
ORDER BY declining_periods DESC, avg_decline_percentage ASC; -- Sort by Most Recovery Periods Descending and Steepest decline() or 

/* Answer: 
For a decline for all time periods we have 0 industries.
When we remove the filter that industry must be declining through all periods and sort by Descending Number of Periods it had Recovery 
We end up with the highest number of periods with a decline is 4 and the industry with highest Recovery in order from Highest  
Hardware
Sales
Consumer
Finance
Education
Travel
Marketing
Retail
Energy
Crypto
Aerospace
AI

This would make sense considering the Post COVID-19 Era though for context a Subject Matter Expert is needed
*/

-- Way 2 of implementing a Decline Analysis: Total Number of Layoffs.
-- 4.2.2. Industry recovery analysis using Total Number of Layoffs and not Percentages
WITH industry_quarters AS (
    SELECT 
        industry,
        QUARTER(`date`) AS qtr,
        SUM(total_laid_off) AS qtr_layoffs,
        LAG(SUM(total_laid_off), 1) OVER (PARTITION BY industry ORDER BY QUARTER(`date`)) AS prev_qtr
    FROM tech_layoffs_dup
    GROUP BY industry, QUARTER(date)
)
SELECT 
    industry,
    SUM(CASE WHEN qtr_layoffs < prev_qtr THEN 1 ELSE 0 END) AS qtrs_declining,
    COUNT(*) AS total_qtrs,
    SUM(qtr_layoffs) AS total_layoffs
FROM industry_quarters
WHERE prev_qtr IS NOT NULL
GROUP BY industry
HAVING qtrs_declining >= 2  -- At least 2 quarters of decline
ORDER BY qtrs_declining DESC;

-- 4.3. Correlation Analysis
-- 4.3.1. Is there a correlation between funds_raised and total_laid_off?
-- Calculating the Pearson's Coefficient between funds_raised and total_laid_off 
    
SELECT 
    (COUNT(*) * SUM(funds_raised * total_laid_off) - SUM(funds_raised) * SUM(total_laid_off)) /  -- Numerator:  n(Σxy)−(Σx)(Σy)
    (
        SQRT(
            COUNT(*) * SUM(funds_raised * funds_raised) - SUM(funds_raised) * SUM(funds_raised)
        ) *
        SQRT(
            COUNT(*) * SUM(total_laid_off * total_laid_off) - SUM(total_laid_off) * SUM(total_laid_off) -- Denominator: SQRT([nΣx −(Σx)][nΣy −(Σy)])
        )
    ) AS correlation_coefficient
FROM tech_layoffs_dup
WHERE total_laid_off IS NOT NULL 
    AND funds_raised IS NOT NULL;

-- Answer: The Correlation Coefficient is 0.248 which is a positive correlation which is not strong.

-- 4.3.2. How does percentage_laid_off correlate with us_status or country?
-- For a categorical variable we can look into the average grouped results 
-- starting with us_status

SELECT us_status, AVG(percentage_laid_off)
FROM tech_layoffs_dup
WHERE percentage_laid_off IS NOT NULL
GROUP BY us_status;

-- Answer: U.S.	0.191037; Non-U.S.	0.242199 thus the magnitude of having a layoff is more in Non-US than in US.

-- for country 
-- check how many countries are there first
SELECT COUNT(DISTINCT(country))
FROM tech_layoffs_dup;

-- We have 38 Countries thus we can group and view the Top 10 weighting
SELECT country, AVG(percentage_laid_off)
FROM tech_layoffs_dup
WHERE percentage_laid_off IS NOT NULL
GROUP BY country
ORDER BY 2 DESC;

-- Answer: Highest is Denmark then South Korea, then Nigeria have a more likelihood to Lay Off due to their High Average Percentage Layoff. 

-- Alternative Way to check correlation 

SELECT 
    -- Grouping column must be in GROUP BY
    us_status,
    
    -- Aggregated calculations
    AVG(percentage_laid_off) AS avg_percentage,
    
    -- T-test calculation (modified for MySQL compatibility)
    (
        -- Difference in means
        (SELECT AVG(percentage_laid_off) FROM tech_layoffs_dup WHERE us_status = 'U.S.' AND percentage_laid_off IS NOT NULL) -
        (SELECT AVG(percentage_laid_off) FROM tech_layoffs_dup WHERE us_status = 'Non-U.S.' AND percentage_laid_off IS NOT NULL)
    ) / 
    SQRT(
        -- U.S. variance component
        (SELECT STDDEV_POP(percentage_laid_off)^2 / COUNT(*) 
         FROM tech_layoffs_dup 
         WHERE us_status = 'U.S.' AND percentage_laid_off IS NOT NULL) +
        
        -- Non-U.S. variance component
        (SELECT STDDEV_POP(percentage_laid_off)^2 / COUNT(*) 
         FROM tech_layoffs_dup 
         WHERE us_status = 'Non-U.S.' AND percentage_laid_off IS NOT NULL)
    ) AS t_value
FROM tech_layoffs_dup
WHERE percentage_laid_off IS NOT NULL
GROUP BY us_status;  -- Critical GROUP BY clause

/* Answer:
Understanding the t-value (-0.497)
The t-value measures how different the two group means (U.S. vs. Non-U.S.) are relative to their natural variability.

-Key Interpretation:
- Magnitude (0.497):
- The difference between groups is about 0.5 standard errors.
- This is a small-to-moderate effect size.

-Negative Sign:
- Indicates the first group (U.S. with 0.191) has a lower average than the second group (Non-U.S. with 0.242).

-Statistical Significance:
For a threshold of |t| > 2 (p < 0.05), your result (-0.497) suggests:
- No statistically significant difference between U.S. and Non-U.S. layoff percentages.

-What The Results Show:
Group	   Avg % Laid Off	t-value	Interpretation
U.S.	   19.1%	        -0.497	Lower than Non-U.S., but not significantly so
Non-U.S.   24.2%	        (same t-value)	Higher than U.S., but difference could be random

-Practical Meaning:
Observed Difference:
Non-U.S. companies average 5.1 percentage points higher layoffs (24.2% vs 19.1%).
-Statistical Confidence:
This difference isn't large enough to rule out random chance (p > 0.05).
Need more data or tighter variance to confirm if real.

- Effect Size Context:
- A 5.1% difference may still be practically important for business decisions, even if not statistically significant.
*/

-- 4.4. Text Analysis
-- 4.4.1. Are there industries or locations frequently appearing with terms like "Acquired" in stage?

-- Confirm the presence
SELECT COUNT(*), 
       COUNT(DISTINCT industry),
       COUNT(DISTINCT country)
FROM tech_layoffs_dup
WHERE stage = "Acquired";

-- Displaying the industries with "Aquired" in the stage
SELECT industry, COUNT(industry) AS industry_count
FROM tech_layoffs_dup
WHERE stage = "Acquired"
GROUP BY industry
ORDER BY industry_count DESC;

-- Answer: Retail leads with 17, then Other with 13, Food, Consumer tied with 12 and so on.

-- Displaying countries with "Aquired" in the stage
SELECT country, COUNT(country) AS country_count
FROM tech_layoffs_dup
WHERE stage = "Acquired"
GROUP BY country
ORDER BY country_count DESC;

-- Answer: US lead with 94, then India with 11, then tied at 4 are Germany, Canada, Spain and so on.

-- Alternative Way of Calculating merging Group by Industry and Country
SELECT 
    industry,
    country,
    COUNT(*) AS acquisition_cases
FROM tech_layoffs_dup
WHERE stage LIKE '%Acquired%'
GROUP BY industry, country
ORDER BY acquisition_cases DESC;


/*
5. Bonus: Advanced SQL Techniques
5.1. Pivoting Data
5.1.1. Create a pivot table showing layoffs by industry (rows) and year (columns).

5.2. Time-Series Gaps
5.2.1. Identify periods with no reported layoffs (data completeness check).

5.3. Hypothesis Testing
5.3.1. Do companies in certain countries have statistically significant differences in layoff percentages?

5.4. Forecasting Prep
5.4.1. Calculate rolling averages for layoffs to model future trends.
*/



WITH monthly_trends AS (
    SELECT 
        industry,
        YEAR(date) AS year,
        MONTH(date) AS month,
        SUM(total_laid_off) AS monthly_layoffs,
        LAG(SUM(total_laid_off), 1) OVER (PARTITION BY industry ORDER BY YEAR(date), MONTH(date)) AS prev_month
    FROM tech_layoffs_dup
    GROUP BY industry, YEAR(date), MONTH(date)
)
SELECT 
    industry,
    AVG((monthly_layoffs - prev_month) / NULLIF(prev_month, 0)) AS avg_growth_rate,
    COUNT(*) AS months_with_growth
FROM monthly_trends
WHERE prev_month IS NOT NULL
GROUP BY industry
ORDER BY avg_growth_rate DESC
LIMIT 10;

WITH industry_quarters AS (
    SELECT 
        industry,
        QUARTER(date) AS qtr,
        SUM(total_laid_off) AS qtr_layoffs,
        LAG(SUM(total_laid_off), 1) OVER (PARTITION BY industry ORDER BY QUARTER(date)) AS prev_qtr
    FROM tech_layoffs_dup
    GROUP BY industry, QUARTER(date)
)
SELECT 
    industry,
    SUM(CASE WHEN qtr_layoffs < prev_qtr THEN 1 ELSE 0 END) AS qtrs_declining,
    COUNT(*) AS total_qtrs,
    SUM(qtr_layoffs) AS total_layoffs
FROM industry_quarters
WHERE prev_qtr IS NOT NULL
GROUP BY industry
HAVING qtrs_declining >= 2  -- At least 2 quarters of decline
ORDER BY qtrs_declining DESC;


