# SQL Project - Data Cleaning

## Dataset
- Source: [Kaggle Layoffs Dataset 2022](https://www.kaggle.com/datasets/swaptr/layoffs-2022)
- Table: `world_layoffs.layoffs`

Overview
--------
This project focuses on cleaning a dataset of tech layoffs from 2022, sourced from Kaggle (https://www.kaggle.com/datasets/swaptr/layoffs-2022). The SQL script performs several data cleaning steps to prepare the data for further analysis.


Steps Performed
--------------
1. **Create Staging Table:** A copy of the raw data is created in a new table (`world_layoffs.layoffs_staging`) to preserve the original data.

2. **Remove Duplicate Rows:** Duplicate entries are identified and removed from the staging table based on all key identifying columns (company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions). Only the first occurrence of each unique record is retained.

3. **Standardize Data and Correct Errors:**
   - **Industry:** Empty strings in the `industry` column are converted to NULL. Missing `industry` values are attempted to be populated by referencing other rows with the same company name. Inconsistent entries for "Crypto" (e.g., "Crypto Currency", "CryptoCurrency") are standardized to "Crypto".
   - **Country:** Trailing periods are removed from values in the `country` column to ensure consistency (e.g., "United States." becomes "United States").
   - **Date:** The `date` column, initially in text format ('%m/%d/%Y'), is converted to the DATE data type for proper date handling.

4. **Investigate and Handle Null Values:** Rows where both `total_laid_off` and `percentage_laid_off` are NULL are removed as they provide minimal analytical value. Other NULL values in columns like `total_laid_off`, `percentage_laid_off`, and `funds_raised_millions` are retained as they may be meaningful for analysis.

5. **Remove Unnecessary Columns:** A temporary `row_num` column, if created during the duplicate removal process, is dropped from the final cleaned staging table.

Output
------
The cleaned dataset is stored in the `world_layoffs.layoffs_staging` table, ready for further exploratory data analysis (EDA) or other analytical tasks.

Note
----
This README provides a summary of the data cleaning process implemented in the SQL script. For detailed steps and the specific SQL queries, please refer to the SQL script itself.
