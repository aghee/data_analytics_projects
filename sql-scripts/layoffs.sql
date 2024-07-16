select count(*) from layoffs_raw;
select * from layoffs_raw;
-- data cleaning
-- get data in a more usable format ready for use in visualization,EDA
/*
1.Remove duplicates if any
2.Standardize data
3.Handling null or blank values
4.Remove unnecessary columns or rows
*/
/*DROP TABLE IF exists layoffs_staging;
DROP TABLE IF exists layoffs_staging2;
DROP TABLE IF exists layoffs_staging3;
DROP TABLE IF exists layoffs_staging4;*/

RENAME table layoffs TO layoffs_raw;
#creates table columns
create table layoffs_staging
like layoffs_raw;

#insert data 
insert into layoffs_staging
select * from layoffs_raw;

#check for duplicates
select *,
row_number() OVER(partition by company,industry,total_laid_off,percentage_laid_off,`date`) as row_num
from layoffs_staging;

-- if row_num >1 means duplicate exists
WITH duplicate_value_cte as 
(
select *,
row_number() OVER(partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
from layoffs_staging
)
select *
from duplicate_value_cte
where row_num>1;

#create table that youll use to delete duplicates
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
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_staging2
select *,
row_number() OVER(partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
from layoffs_staging;

#remove duplicates
DELETE
from layoffs_staging2
where row_num>1;

select *
from layoffs_staging2;

select *
from layoffs_staging
where company ='Oda';

select *
from layoffs_staging
where company ='Wildlife Studios';

select *
from layoffs_staging
where company ='Casper';

INSERT INTO layoffs_staging values('Casper', 'New York City', 'Wholesale', NULL, NULL, '9/14/2023', 'Stage A', 'USA', '339');
delete from layoffs_staging
where date='9/14/2021' and company='Casper';

INSERT INTO layoffs_staging values('Casper', 'New York City', 'Retail', NULL, NULL, '9/14/2021', 'Post-IPO', 'United States', '339');

select count(*) from layoffs_staging;

# standardizing data -done per column
-- company column
select company,TRIM(company) 
from layoffs_staging2;

UPDATE layoffs_staging2
SET company=TRIM(company);

-- industry
select distinct industry 
from layoffs_staging2
order by 1;

select *
from layoffs_staging2
WHERE industry like 'Crypto%';

update layoffs_staging2
set industry='Crypto'
WHERE industry like 'Crypto%';

select distinct industry
from layoffs_staging2;

-- location
select distinct location
from layoffs_staging2
order by 1;

-- country
select distinct country
from layoffs_staging2
order by 1;

select *
from layoffs_staging2
where country like 'United States%';

select distinct country,trim(TRAILING '.' FROM country)
from layoffs_staging2
order by 1;

update  layoffs_staging2
set country=trim(TRAILING '.' FROM country)
where country like 'United States%';

update  layoffs_staging2
set country='United States'
where country='USA';

-- date column
-- date must be of type DATE to be suitable for EDA,time-series, visualizations
-- convert str_to_date first, then convert datatype to DATE
select `date`,str_to_date(`date`,'%m/%d/%Y')
from layoffs_staging2;

update layoffs_staging2
set `date`=str_to_date(`date`,'%m/%d/%Y');

alter table layoffs_staging2
modify column `date` DATE;

select *
from layoffs_staging2;

# handling null or blank values
select *
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

select *
from layoffs_staging2
where industry is null or industry='';

-- Try to populate industry column by checking if any of the industries is populated using company name
select *
from layoffs_staging2
where company='Airbnb';

SELECT t1.industry as selfjoin1,t2.industry as selfjoin2
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
on t1.company=t2.company
AND t1.location=t2.location
where (t1.industry is null or t1.industry='')
AND t2.industry is not null;

update layoffs_staging2 t1
JOIN layoffs_staging2 t2
on t1.company=t2.company
set t1.industry=t2.industry
where t1.industry is null
AND t2.industry is not null;

update layoffs_staging2
set industry=null
where industry='';

select *
from layoffs_staging2
where company='Bally\'s Interactive';

select *
from layoffs_staging2
where company like'Bally%';

select *
from layoffs_staging2;

# Remove unnecessary columns
-- You can delete this rows  as they have no data on employees laid off --make the judgement call
select *
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

DELETE 
FROM layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

-- check for blanks
select *
from layoffs_staging2
where total_laid_off=''
or percentage_laid_off='';

alter table layoffs_staging2
drop column row_num;

-- Exploratory Data Analysis - identify patterns, trends, answer business questions
select *
from layoffs_staging2;

select max(total_laid_off),max(percentage_laid_off),company
from layoffs_staging2
where total_laid_off=12000
group by company;

select *
from layoffs_staging2
where percentage_laid_off=1
order by total_laid_off desc ;

select company,sum(total_laid_off) as total_staff_sacked
from layoffs_staging2
group by company
order by total_staff_sacked DESC ;

select min(`date`) as earliest_date,max(`date`) as latest_date
from layoffs_staging2;

select industry,sum(total_laid_off)
from layoffs_staging2
group by industry
order by 2 desc; 

select country,sum(total_laid_off)
from layoffs_staging2
group by country
order by 2 desc;

select MONTH(`date`),sum(total_laid_off)
from layoffs_staging2
group by MONTH(`date`)
order by 1 desc;

select YEAR(`date`),sum(total_laid_off)
from layoffs_staging2
group by YEAR(`date`)
order by 1 desc;

select *
from layoffs_staging
WHERE `date` is null;

select stage,sum(total_laid_off)
from layoffs_staging2
group by stage
order by 1 desc;

-- rolling total of layoffs per month
SELECT SUBSTRING(`date`,1,7) as themonth,sum(total_laid_off) as total_staff_sacked
from layoffs_staging2
where SUBSTRING(`date`,1,7) is not null
group by themonth
order by 1 asc;

WITH rolling_staff_total as
(
SELECT SUBSTRING(`date`,1,7) as themonth,sum(total_laid_off) as total_staff_sacked
from layoffs_staging2
where SUBSTRING(`date`,1,7) is not null
group by themonth
order by 1 asc
)
select themonth, total_staff_sacked,sum(total_staff_sacked) over(order by themonth)as rolling_total
from rolling_staff_total
group by themonth,total_staff_sacked;

select YEAR(`date`),company,sum(total_laid_off) as total_staff_sacked
from layoffs_staging2
group by company,YEAR(`date`)
order by total_staff_sacked DESC;
-- total staff sacked per company per year
WITH company_year_sacking(theyear,company,total_letgo) as
(
select YEAR(`date`),company,sum(total_laid_off) as total_staff_sacked
from layoffs_staging2
group by company,YEAR(`date`)
)
select *,DENSE_RANK() OVER(PARTITION BY theyear ORDER BY total_letgo DESC) as ranks
from company_year_sacking
WHERE theyear is not null
order by ranks;

# Top ten sackings per year by company/Year over year sacking by company
WITH company_year_sacking(theyear,company,total_letgo) as
(
select YEAR(`date`),company,sum(total_laid_off) as total_staff_sacked
from layoffs_staging2
group by company,YEAR(`date`)
),
company_year_rank as
(
select *,DENSE_RANK() OVER(PARTITION BY theyear ORDER BY total_letgo DESC) as ranks
from company_year_sacking
WHERE theyear is not null
)
select *
from company_year_rank
where ranks <=10;

# Top 5 sackings per month by industry/Month over month sacking by industry
WITH industry_year_sacking(theyear,industry,total_letgo) as
(
select YEAR(`date`),industry,sum(total_laid_off) as total_staff_sacked
from layoffs_staging2
group by industry,YEAR(`date`)
),
industry_year_rank as
(
select *,DENSE_RANK() OVER(PARTITION BY theyear ORDER BY total_letgo DESC) as ranks
from industry_year_sacking
WHERE theyear is not null
)
select *
from industry_year_rank
where ranks <=5;

# Top 5 sackings per month by industry/Month over month sacking by industry
WITH industry_month_sacking(themonth,theyear,industry,total_letgo) as
(
select MONTH(`date`),YEAR(`date`),industry,sum(total_laid_off) as total_staff_sacked
from layoffs_staging2
group by industry,MONTH(`date`),YEAR(`date`)
),
industry_month_rank as
(
select *,DENSE_RANK() OVER(PARTITION BY themonth,theyear ORDER BY total_letgo DESC) as ranks
from industry_month_sacking
WHERE themonth is not null
)
select *
from industry_month_rank
where ranks <=5;

#No employees fired in may 2021 as shown in the query above
select *
from layoffs_staging2
where substring(`date`,1,7) ='2021-05';

