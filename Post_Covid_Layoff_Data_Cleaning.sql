-- SQL Project - Data Cleaning


-- Source: https://www.kaggle.com/datasets/swaptr/layoffs-2022

-- Create a staging table to hold the raw data for cleaning.
CREATE TABLE world_layoffs.layoffs_staging
LIKE world_layoffs.layoffs;

-- Populate the staging table with data from the original table.
INSERT INTO world_layoffs.layoffs_staging
SELECT * FROM world_layoffs.layoffs;

-- Data Cleaning Steps:
-- 1. Remove Duplicate Rows
-- 2. Standardize Data and Correct Errors
-- 3. Investigate and Handle Null Values

-- 1. Remove Duplicate Rows

-- Identify duplicate rows based on all relevant columns.
SELECT
    company,
    location,
    industry,
    total_laid_off,
    percentage_laid_off,
    `date`,
    stage,
    country,
    funds_raised_millions,
    ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM
    world_layoffs.layoffs_staging;

-- Delete duplicate rows, keeping only the first occurrence.
DELETE FROM world_layoffs.layoffs_staging
WHERE (company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) IN (
    SELECT
        company,
        location,
        industry,
        total_laid_off,
        percentage_laid_off,
        `date`,
        stage,
        country,
        funds_raised_millions
    FROM (
        SELECT
            company,
            location,
            industry,
            total_laid_off,
            percentage_laid_off,
            `date`,
            stage,
            country,
            funds_raised_millions,
            ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
        FROM
            world_layoffs.layoffs_staging
    ) AS duplicates
    WHERE
        row_num > 1
);

-- Verify the removal of duplicates.
SELECT *
FROM world_layoffs.layoffs_staging;

-- 2. Standardize Data and Correct Errors

-- Inspect the 'industry' column for inconsistencies.
SELECT DISTINCT industry
FROM world_layoffs.layoffs_staging
ORDER BY industry;

-- Identify rows with missing or empty 'industry' values.
SELECT *
FROM world_layoffs.layoffs_staging
WHERE industry IS NULL OR industry = ''
ORDER BY industry;

-- Standardize empty 'industry' values to NULL for consistency.
UPDATE world_layoffs.layoffs_staging
SET industry = NULL
WHERE industry = '';

-- Attempt to populate missing 'industry' values based on other entries for the same company.
UPDATE layoffs_staging t1
JOIN layoffs_staging t2 ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;

-- Verify the result of the 'industry' standardization.
SELECT *
FROM world_layoffs.layoffs_staging
WHERE industry IS NULL
ORDER BY industry;

-- Standardize variations of 'Crypto' in the 'industry' column.
UPDATE layoffs_staging
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency', 'CryptoCurrency');

-- Verify the standardization of 'Crypto' values.
SELECT DISTINCT industry
FROM world_layoffs.layoffs_staging
ORDER BY industry;

-- Inspect the 'country' column for inconsistencies.
SELECT DISTINCT country
FROM world_layoffs.layoffs_staging
ORDER BY country;

-- Remove trailing periods from the 'country' values for standardization.
UPDATE layoffs_staging
SET country = TRIM(TRAILING '.' FROM country);

-- Verify the standardization of 'country' values.
SELECT DISTINCT country
FROM world_layoffs.layoffs_staging
ORDER BY country;

-- Inspect the 'date' column.
SELECT *
FROM world_layoffs.layoffs_staging;

-- Convert the 'date' column to the DATE data type.
UPDATE layoffs_staging
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Modify the 'date' column's data type to DATE.
ALTER TABLE layoffs_staging
MODIFY COLUMN `date` DATE;

-- Verify the data type change for the 'date' column.
SELECT *
FROM world_layoffs.layoffs_staging;

-- 3. Investigate and Handle Null Values

-- Examine rows with null values in 'total_laid_off'.
SELECT *
FROM world_layoffs.layoffs_staging
WHERE total_laid_off IS NULL;

-- Examine rows with null values in both 'total_laid_off' and 'percentage_laid_off'.
SELECT *
FROM world_layoffs.layoffs_staging
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Remove rows where both 'total_laid_off' and 'percentage_laid_off' are NULL, as these entries provide minimal information.
DELETE FROM world_layoffs.layoffs_staging
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Verify the removal of rows with both NULL values.
SELECT *
FROM world_layoffs.layoffs_staging;

-- Final cleaned data in the 'world_layoffs.layoffs_staging' table.
SELECT *
FROM world_layoffs.layoffs_staging;
