/*
Project: Data Cleaning with SQL on a Tech Layoffs Dataset by Dumisani Mukuchura
By: Dumisani Maxwell Mukuchura
Email: dumisanimukuchura@gmail.com
Dataset: https://www.kaggle.com/datasets/swaptr/layoffs-2022

Goals: 
1. Understand Dataset: the Columns, Rows and setup.
2. Check for Duplicates and Remove them if any.
3. Standardize the Data considering understanding from Step 1.
4. Check for NULL/Blank values and decide how to deal with them.
5. Remove Columns/Rows that do not have value to the Dataset.
*/

-- 0. Import the CSV File via the Craetion of New Schema, name it and via Table import Wizard

-- Inspection shows there are 9 columns and all of them are of variable type: text except 'total_laid_off' which is a double
-- 9 Columns: company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised

-- 1 Understand Dataset: the Columns, Rows and setup.
-- 1.1 Preview the Dataset and view Columns and Rows to have a sense of the Dataset.

SELECT *
FROM tech_layoffs;

-- Example Row Returned 'Brightcove', '[\'Boston\']', 'Marketing', '198', '0.33', '2025-03-19T00:00:00.000Z', 'Acquired', 'United States', '145.0'

-- 1.2 Understand the Total number of Rows in the Dataset

SELECT COUNT(*) AS Total_Rows
FROM tech_layoffs;

-- Answer: 1288 Rows

-- 1.3 Make a copy of the Table and Work on the Copy

CREATE TABLE tech_layoffs_dup
LIKE tech_layoffs; -- this creates the tables only but does not have the data so we need to include the data by an INSERT

INSERT tech_layoffs_dup
SELECT *
FROM tech_layoffs;

SELECT *
FROM tech_layoffs_dup; -- Confirm new Duplicate table.

-- 2. Check for Duplicates and Remove them if any.

-- There is no identifier so use row_num to act as the identifier and assign rank 
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised) AS row_num
FROM tech_layoffs_dup;

-- Package it as a CTE and then use it to find if there is a row_num greater than 1

WITH Tech_Layoffs_Duplicate_CTE AS
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised) AS row_num
FROM tech_layoffs_dup
)
SELECT *
FROM Tech_Layoffs_Duplicate_CTE
WHERE row_num > 1;

-- Response: 0 Rows returned thus there are no duplicates according to the set criteria

/* If there was Duplicates we would have created another table insert Data from the CTE then DELETE those greater than 1 in row_num

DROP TABLE IF EXISTS tech_layoffs_dup1;

CREATE TABLE `tech_layoffs_dup1` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` double DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised` text,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Confirm the creation of the Table, though it won't have Data yet
SELECT *
FROM tech_layoffs_dup1;

-- Insert Data into the created tech_layoffs_dup1 Table with that row number column
INSERT INTO layoffs_staging_3
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging_2;

-- Confirm Data addition and also existence of Duplicates 
SELECT *
FROM layoffs_staging_3
WHERE row_num > 1;

-- Action a DELETE of these row_num greater than 1 i.e the Duplicates
DELETE
FROM layoffs_staging_3
WHERE row_num > 1;

*/

-- 3. Standardize the Data considering understanding from Step 1.

-- Check issues with Standard 

SELECT *
FROM tech_layoffs_dup;

-- check for inconsistencies across all the columns  
SELECT DISTINCT company
FROM tech_layoffs_dup
ORDER BY 1;

SELECT DISTINCT location
FROM tech_layoffs_dup
ORDER BY 1;

SELECT DISTINCT industry
FROM tech_layoffs_dup
ORDER BY 1;

SELECT DISTINCT stage
FROM tech_layoffs_dup
ORDER BY 1;

SELECT DISTINCT country
FROM tech_layoffs_dup
ORDER BY 1;

/*
1. company there are some with whitespaces e.g F-Secure
2. location has encasulation of sort with [''] that will need to be removed and add new column 'us status' when location when outside US it has a Non-U.S. component
3. date has a text data type but need to have it as datetime
4. correct data types: percentage_laid_off, funds_raised from text
5. remove redundant columns
*/

-- 3.1 Deal with Whitespaces in company 

SELECT company, TRIM(company)
FROM tech_layoffs_dup
ORDER BY 1;

-- Remove Whitespaces
UPDATE tech_layoffs_dup
SET company = TRIM(company);

-- Confirm Removal of Whitespaces
SELECT DISTINCT company
FROM tech_layoffs_dup
ORDER BY 1;

-- 3.2. location has encasulation of sort with [','] that will need to be removed

-- 3.2.1 Remove [','] Test
SELECT location,
		REPLACE(
			REPLACE(
				REPLACE
					(REPLACE(location, 
						'[', ''),  -- Remove [
							']', '' ), -- Remove ]
								'''', ''), -- Remove Single Quotes
									',', '') AS clean_location -- Remove the ,
FROM tech_layoffs_dup;

-- 3.2.2 Test the Split to Add U.S. Status

WITH Test_Split_US_Status_CTE AS
(
SELECT location,
		REPLACE(
			REPLACE(
				REPLACE
					(REPLACE(location, 
						'[', ''),  -- Remove [
							']', '' ), -- Remove ]
								'''', ''), -- Remove Single Quotes
									',', '') AS clean_location -- Remove the ,
FROM tech_layoffs_dup
)
SELECT *,
	CASE
		WHEN clean_location LIKE "%Non-U.S.%" THEN "Non-U.S."
        ELSE "U.S." 
END AS us_status
FROM Test_Split_US_Status_CTE;

-- Now Update the Table with addition of New US State Column and then updating the location column with new clean column 

ALTER TABLE tech_layoffs_dup ADD COLUMN us_status VARCHAR(15);

UPDATE tech_layoffs_dup
SET 
	location = REPLACE(
				 REPLACE(
					REPLACE
						(REPLACE(location, 
							'[', ''),  -- Remove [
								']', '' ), -- Remove ]
									'''', ''), -- Remove Single Quotes
										',', ''), -- Remove the ,
	us_status = CASE
					WHEN location LIKE "%Non-U.S.%" THEN "Non-U.S."
					ELSE "U.S."
				END;

-- Check the New Table
SELECT *
FROM tech_layoffs_dup;
                
UPDATE tech_layoffs_dup
SET location = TRIM(REPLACE(location, "Non-U.S.", "")) -- Remove the Non-U.S. part from the location and the White Space
WHERE location LIKE "%Non-U.S.%";

-- Check the New Table 
SELECT *
FROM tech_layoffs_dup;

-- 3.3. date has a text data type but need to have it as datetime

SELECT `date`,
		STR_TO_DATE(`date`, "%Y-%m-%dT%T.%fZ") AS new_date
FROM tech_layoffs_dup;

-- But there is no information beyond the date, the Time component does not change thus we can drop it 

/* NOTES
Specifier - Meaning            -           Example
%Y	        4-digit year	               2025
%y	        2-digit year	               25
%m	        Month (01-12)	               03
%c	        Month (1-12)	               3
%d	        Day of month (01-31)           19
%H	        Hour (00-23)	               15
%i	        Minutes (00-59)	               30
%s	        Seconds (00-59)	               45
%f	        Microseconds (000000-999999)   000
%T	        Shortcut for %H:%i:%s	       15:30:45
*/

SELECT `date`,
		STR_TO_DATE(`date`, "%Y-%m-%d") AS new_date
FROM tech_layoffs_dup;

-- UPDATE the `date` column with the formatted date, but not you can not truncate or trim as it expects same length of `date` 

UPDATE tech_layoffs_dup
SET `date` = STR_TO_DATE(`date`, "%Y-%m-%dT%T.%fZ");

-- But the `date` column is still text so do a DATETIME modification

ALTER TABLE tech_layoffs_dup
MODIFY COLUMN `date` DATETIME;

SELECT *
FROM tech_layoffs_dup;

-- 3.4. correct data types: percentage_laid_off, funds_raised from text 

ALTER TABLE tech_layoffs_dup
MODIFY COLUMN percentage_laid_off DOUBLE NULL,    -- decimal(5,2) - means from -999.99 to 999.99
MODIFY COLUMN funds_raised DOUBLE NULL;

-- HAVE TO HOLD OFF UNTIL I DEAL WITH Blanks

-- 4. Check for NULL/Blank values and decide how to deal with them.

-- Check for NULLs/Blanks: 
-- They appear on "percentage_laid_off" and we also note instances that have High Decimal Places we will need to deal with 

-- Check Blanks/NULLs in percentage_laid_off
SELECT DISTINCT percentage_laid_off
FROM tech_layoffs_dup;

SELECT *
FROM tech_layoffs_dup
WHERE percentage_laid_off = "" OR percentage_laid_off IS NULL;

SELECT COUNT(*) AS percentage_laid_off_missing
FROM tech_layoffs_dup
WHERE percentage_laid_off = "" OR percentage_laid_off IS NULL;

-- 457 rows with missing percentage_laid_off

-- Check Blanks/NULLs in funds_raised
SELECT DISTINCT funds_raised
FROM tech_layoffs_dup;

SELECT *
FROM tech_layoffs_dup
WHERE funds_raised = "" OR funds_raised IS NULL;

SELECT COUNT(*) AS funds_raised_missing
FROM tech_layoffs_dup
WHERE funds_raised = "" OR funds_raised IS NULL;

-- 165 rows with Missing funds_raised

-- Check how many Rows have both percentage_laid_off and funds_raised as Blanks/NULLs
SELECT *
FROM tech_layoffs_dup
WHERE (funds_raised = "" OR funds_raised IS NULL)
AND (percentage_laid_off = "" OR percentage_laid_off IS NULL);

SELECT COUNT(*) AS missing_percentage_laid_off_and_funds_raised
FROM tech_layoffs_dup
WHERE (funds_raised = "" OR funds_raised IS NULL)
AND (percentage_laid_off = "" OR percentage_laid_off IS NULL);

-- 66 rows with both missing. 

/*
Suppose when there was a missing industry we would do a SELF JOIN and when Company and Location are the same we would then check if there is an instance where one record has Industry and another does not have Industry

-----------
SELECT t1.industry, t2.industry
FROM tech_layoffs_dup t1
JOIN tech_layoffs_dup t2 
	ON t1.company = t2.company AND  t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '') AND t2.industry IS NOT NULL;
-----------

CONVERT all Blanks to NULLs 
DELETE rows where percentage_laid_off and funds_raised are Blank/NULL
*/

-- Set ALL Blanks to NULLs
UPDATE tech_layoffs_dup
SET percentage_laid_off = NULL
WHERE percentage_laid_off = "";

UPDATE tech_layoffs_dup
SET funds_raised = NULL
WHERE funds_raised = "";

-- Confirm how many rows have both percentage_laid_off and funds_raised IS NULL
SELECT COUNT(*)
FROM tech_layoffs_dup
WHERE percentage_laid_off IS NULL
AND funds_raised IS NULL;

-- Delete those Rows
DELETE
FROM tech_layoffs_dup
WHERE percentage_laid_off IS NULL
AND funds_raised IS NULL;

-- Confirm Deletion
SELECT 
    SUM(CASE 
			WHEN percentage_laid_off IS NULL THEN 1 
            ELSE 0 END) AS remaining_null_percentages,
    SUM(CASE 
			WHEN funds_raised IS NULL THEN 1 
            ELSE 0 END) AS remaining_null_funds
FROM tech_layoffs_dup;

-- Expecting 457 - 66 for Remaining NULL percentage_laid_off and 165 - 66 for Remaining NULL funds_raised

-- 5: Remove redundant Columns

SELECT *
FROM tech_layoffs_dup;

-- There are no columns to be removed as all we ci=urrently have valuable information that can be valuable.



 




    
