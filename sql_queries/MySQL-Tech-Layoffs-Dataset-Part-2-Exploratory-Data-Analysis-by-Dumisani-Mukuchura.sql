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


