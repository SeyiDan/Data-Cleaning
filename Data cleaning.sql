-- SQL Project - Data Cleaning

-- https://www.kaggle.com/datasets/swaptr/layoffs-2022


select * 
from layoffs;


-- 1. REMOVE DUPLICATES
-- i) we create (copy/duplicate) another table so we dont work directly on the raw data.
Create table layoffs_staging like layoffs;

Select*
from layoffs_staging;

insert layoffs_staging 
select * from layoffs;

-- removing duplicate
select *, row_number() over(partition by industry, total_laid_off,percentage_laid_off, `date`) as row_num
from layoffs_staging;

-- filter where row number > 1
with duplicate_cte as
(
select *, row_number() over(partition by company, industry, total_laid_off,percentage_laid_off, `date`, stage,country, funds_raised_millions) as row_num
from layoffs_staging)
delete from duplicate_cte where row_num > 1;



-- Delete duplicate rows
-- delete from duplicate_cte where row_num > 1;

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


Select*
from layoffs_staging2 where row_num >1;

insert layoffs_staging2
select *, row_number() over(partition by company, industry, total_laid_off,percentage_laid_off, `date`, stage,country, funds_raised_millions) as row_num
from layoffs_staging;

Select*
from layoffs_staging2 where row_num >1;

delete from layoffs_staging2 where row_num >1;

Select*
from layoffs_staging2;



-- 2. Standardize the Data
select company, trim(company) from layoffs_staging2;
update layoffs_staging2 set company = TRIM(company);

select distinct country from layoffs_staging2 order by 1;

-- we want to remove data repitition
select * from  layoffs_staging2 where industry like 'crypto%';

update layoffs_staging2 set industry = 'Crypto' where industry like 'crypto%';

select distinct country, trim(trailing '.' from country) from layoffs_staging2 order by 1;

update layoffs_staging2 set country = trim(trailing '.' from country) where country like 'United States%';

select `date`, str_to_date(`date`, '%m/%d/%Y') from layoffs_staging2;

update layoffs_staging2 set `date` =  str_to_date(`date`, '%m/%d/%Y');

alter table layoffs_staging2 modify column `date` DATE;


-- 3. Null or Blank Values
select * from layoffs_staging2 where total_laid_off is null and percentage_laid_off is null;

update layoffs_staging2 set industry = null where industry = '';

select * from layoffs_staging2 where industry is null or industry = '';

select * from layoffs_staging2 where company = 'Airbnb';

select * from layoffs_staging2 t1 
join layoffs_staging2 t2 
	on t1.company = t2.company
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;


update layoffs_staging2 t1
join layoffs_staging2  t2
on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null 
and t2.industry is not null;


-- 4. Remove unnecessary rows and columns

select * from layoffs_staging2 where total_laid_off is null and percentage_laid_off is null;

delete from layoffs_staging2 where total_laid_off is null and percentage_laid_off is null;

alter table layoffs_staging2 drop column row_num;