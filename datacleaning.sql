SELECT*
FROM layoffs;
SELECT*
FROM layoffs_staging;


-- 1.Remove Duplicate
--  2.Standardize the data
-- 3. Null Values or blank values
WITH duplicate_ls AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY company, location, industry, total_laid_off, 
                            percentage_laid_off, "date", stage, country, 
                            funds_raised_millions
           ) AS row_num
    FROM layoffs_staging
)
SELECT*
FROM duplicate_ls
WHERE row_num  > 1;


CREATE TABLE `layoffs_staging2` (
    `company` TEXT,
    `location` TEXT,
    `industry` TEXT,
    `total_laid_off` INT DEFAULT NULL,
    `percentage_laid_off` TEXT,
    `date` TEXT,
    `stage` TEXT,
    `country` TEXT,
    `funds_raised_millions` TEXT,
    `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT*
FROM layoffs_staging2
;


INSERT INTO layoffs_staging2
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
    ROW_NUMBER() OVER (
        PARTITION BY company, location, industry, total_laid_off, 
                     percentage_laid_off, `date`, stage, country, 
                     funds_raised_millions
    ) AS row_num
FROM layoffs_staging;

SELECT * FROM layoffs_staging2
 LIMIT 10;
 
 SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

SET SQL_SAFE_UPDATES = 0;

DELETE 
FROM layoffs_staging2
WHERE row_num > 1;



SELECT*
FROM layoffs_staging2;

-- Step2:Standardize the data means finding data and fixing the issue

SELECT company,
TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company =  TRIM(company)
;

SELECT*
FROM layoffs_staging;

SELECT*
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';


UPDATE layoffs_staging2
SET industry= 'Crypto'
WHERE industry LIKE 'Crypto%'
;

SELECT distinct 
industry
FROM layoffs_staging2
;

SELECT DISTINCT  country,TRIM(TRAILING '-' FROM country)
FROM layoffs_staging2
WHERE country LIKE 'United States%'
;
UPDATE layoffs_staging2
SET country=TRIM(TRAILING '-' FROM country)
WHERE country LIKE 'United States%'
;
SELECT*FROM layoffs_staging2;


SELECT 'date',
    STR_TO_DATE(`date`, '%m/%d/%Y') AS formatted_date
FROM layoffs_staging2;


UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');



ALTER TABLE layoffs_staging2
MODIFY COLUMN `date`  DATE;

SELECT*FROM layoffs_staging2;


-- STEP 3:NULL VAlUES
SELECT*
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT*
FROM layoffs_staging
WHERE INDUSTRY IS NULL
OR industry=' ' ;


SELECT w1.industry, w2.industry
FROM layoffs_staging2 w1
JOIN layoffs_staging2 w2
ON w1.company = w2.company
AND w1.location = w2.location
WHERE (w1.industry IS NULL OR w1.industry = w2.industry);

UPDATE layoffs_staging2 w1
JOIN layoffs_staging w2
ON w1.company=w2.company
SET w1.industry=w2.industry
WHERE (w1.industry IS NULL OR w1.industry='  ' )
AND w2.industry IS NOT NULL;

SELECT*
from layoffs_staging2
ORDER BY 1;


SELECT*
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT*
FROM layoffs_staging2;


ALTER TABLE layoffs_staging2
DROP COLUMN row_num;


SELECT*
FROM layoffs_staging2;

