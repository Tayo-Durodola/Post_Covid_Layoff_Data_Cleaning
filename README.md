# SQL Project - Data Cleaning

## Dataset
- Source: [Kaggle Layoffs Dataset 2022](https://www.kaggle.com/datasets/swaptr/layoffs-2022)
- Table: `world_layoffs.layoffs`

## Objective
The project focuses on cleaning the layoffs dataset using SQL to ensure data accuracy and consistency by:
1. Removing duplicates.
2. Standardizing and correcting data.
3. Handling null values.
4. Dropping unnecessary rows and columns.

## Steps Taken

### 1. Creating a Staging Table
- A staging table `layoffs_staging` was created as a working copy.
```sql
CREATE TABLE world_layoffs.layoffs_staging
LIKE world_layoffs.layoffs;
INSERT INTO world_layoffs.layoffs_staging
SELECT * FROM world_layoffs.layoffs;
```

### 2. Removing Duplicates
- Identified duplicates using `ROW_NUMBER()` partitioned by key columns.
- Verified duplicate entries before deletion.
- Used a CTE (`DELETE_CTE`) to delete duplicate rows.
```sql
WITH DELETE_CTE AS (
    SELECT *, ROW_NUMBER() OVER (
        PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions
    ) AS row_num
    FROM world_layoffs.layoffs_staging
)
DELETE FROM world_layoffs.layoffs_staging
WHERE row_num > 1;
```

### 3. Standardizing Data
- Handled missing and inconsistent values.
- Populated `industry` column based on existing company data.
- Standardized inconsistent industry names (e.g., "CryptoCurrency" → "Crypto").
- Fixed country name inconsistencies (e.g., "United States." → "United States").
```sql
UPDATE world_layoffs.layoffs_staging
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency', 'CryptoCurrency');

UPDATE world_layoffs.layoffs_staging
SET country = TRIM(TRAILING '.' FROM country);
```
- Converted `date` column to a proper `DATE` format.
```sql
UPDATE layoffs_staging
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
ALTER TABLE layoffs_staging MODIFY COLUMN `date` DATE;
```

### 4. Handling Null Values
- Checked for null values in key columns.
- Retained null values in numeric columns to preserve data integrity.
```sql
SELECT * FROM world_layoffs.layoffs_staging WHERE total_laid_off IS NULL;
```

### 5. Removing Unnecessary Data
- Deleted rows where both `total_laid_off` and `percentage_laid_off` were null.
```sql
DELETE FROM world_layoffs.layoffs_staging
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;
```
- Dropped the `row_num` column after deduplication.
```sql
ALTER TABLE world_layoffs.layoffs_staging DROP COLUMN row_num;
```

## Final Output
- The cleaned dataset is stored in `world_layoffs.layoffs_staging2`.
- Ready for exploratory data analysis (EDA) and further insights.


