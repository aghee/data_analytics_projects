-- INSIGHTS/QNS TO ANSWER
-- 1. What is the gender breakdown of employees in the company?
SELECT 
    gender, COUNT(gender) AS count_by_gender
FROM
    human_rs
WHERE
    age >= 18 AND termdate IS NULL
GROUP BY gender;

-- 2. What is the race/ethnicity breakdown of employees in the company?
SELECT 
    race, COUNT(*) AS count_by_ethnicity
FROM
    human_rs
WHERE
    age >= 18 AND termdate IS NULL
GROUP BY race
ORDER BY count_by_ethnicity DESC;

-- 3. What is the age distribution of employees in the company?
SELECT 
    MIN(age) AS youngest, MAX(age) AS oldest
FROM
    human_rs
WHERE
    age >= 18 AND termdate IS NULL;

SELECT 
    COUNT(age) AS no_of_employees,
    age,
    CASE
        WHEN age >= 50 THEN 'Fifty plus_Baby Boomers'
        WHEN age >= 40 THEN 'Forty plus_GEN X'
        WHEN age >= 30 THEN 'Thirty plus_Milenials'
        WHEN age BETWEEN 18 AND 29 THEN 'GEN Z'
        ELSE 'NA'
    END AS distr_by_age
FROM
    human_rs
WHERE
    age >= 18 AND termdate IS NULL
GROUP BY age;

SELECT 
    CASE
        WHEN age >= 18 AND age <= 24 THEN '18-24'
        WHEN age >= 25 AND age <= 34 THEN '25-34'
        WHEN age >= 35 AND age <= 44 THEN '35-44'
        WHEN age >= 45 AND age <= 54 THEN '45-54'
        WHEN age >= 55 AND age <= 64 THEN '55-64'
        ELSE 'Over 65'
    END AS age_group,
    gender,
    COUNT(*) AS no_of_employees
FROM
    human_rs
WHERE
    age >= 18 AND termdate IS NULL
GROUP BY age_group , gender
ORDER BY age_group , gender;

-- categorize employees into age-groups and return total number in each group based on gender
WITH agedistribution AS (
SELECT 
    COUNT(age) AS no_of_employees,
    gender,
    CASE
        WHEN age >= 50 THEN 'Fifty plus_Baby Boomers'
        WHEN age >= 40 AND age <50 THEN 'Forty plus_GEN X'
        WHEN age >= 30 AND age <40 THEN 'Thirty plus_Milenials'
        WHEN age BETWEEN 18 AND 29 THEN 'GEN Z'
        ELSE 'NA'
    END AS distr_by_age
FROM human_rs
WHERE age>=18 and termdate IS NULL
GROUP BY age,gender
)
SELECT 
    distr_by_age,
    gender,
    SUM(no_of_employees) AS 'Total Employees'
FROM
    agedistribution
GROUP BY distr_by_age , gender
ORDER BY distr_by_age , gender;


SELECT 
    age AS employee_age, COUNT(age) AS distr_by_age
FROM
    human_rs
WHERE
    age >= 18 AND termdate IS NULL
GROUP BY age
ORDER BY employee_age DESC;

CREATE VIEW view_one AS
    SELECT 
        age AS employee_age, COUNT(age) AS distr_by_age
    FROM
        human_rs
    WHERE
        age >= 18 AND termdate IS NULL
    GROUP BY age
    ORDER BY employee_age DESC;

SELECT 
    SUM(distr_by_age)
FROM
    view_one
WHERE
    employee_age BETWEEN 55 AND 64;

SELECT 
    SUM(distr_by_age)
FROM
    view_one
WHERE
    employee_age >= 50;

-- 4. How many employees work at headquarters versus remote locations?
SELECT 
    location, COUNT(*) AS emp_location
FROM
    human_rs
WHERE
    age >= 18 AND termdate IS NULL
GROUP BY location;

-- 5. What is the average length of employment for employees who have been terminated? 
SELECT 
    *
FROM
    human_rs
LIMIT 50;

-- if termdate is null--employee still employed
SELECT 
    ROUND(AVG(DATEDIFF(termdate, hire_date)) / 365,
            0) AS avg_length_yrs
FROM
    human_rs
WHERE
    termdate <= CURDATE()
        AND termdate IS NOT NULL
        AND age >= 18;

-- 6. How does the gender distribution vary across departments and job titles?
SELECT 
    gender, department, jobtitle, COUNT(*)
FROM
    human_rs
WHERE
    age >= 18 AND termdate IS NULL
GROUP BY gender , department , jobtitle
ORDER BY gender , department;

SELECT 
    gender, department, COUNT(*) AS cnt
FROM
    human_rs
WHERE
    age >= 18 AND termdate IS NULL
GROUP BY gender , department
ORDER BY gender , department;

-- 7. What is the distribution of job titles across the company?
SELECT 
    COUNT(*) AS count_by_jobtitle, jobtitle
FROM
    human_rs
WHERE
    age >= 18 AND termdate IS NULL
GROUP BY jobtitle
ORDER BY jobtitle DESC;

-- 8.Which department has the highest turnover rate?
/*with turnover as(
select department,count(termdate) as highest_turnover
from human_rs
where termdate is not null
group by department
order by highest_turnover desc
)
select max(highest_turnover) as dept_exits
from turnover;*/
SELECT 
    department,
    total_count,
    terminated_count,
    (terminated_count / total_count) AS termination_rate
FROM
    (SELECT 
        department,
            COUNT(*) AS total_count,
            SUM(CASE
                WHEN
                    termdate IS NOT NULL
                        AND termdate <= CURDATE()
                THEN
                    1
                ELSE 0
            END) AS terminated_count
    FROM
        human_rs
    WHERE
        age >= 18
    GROUP BY department) AS emp_turnover
ORDER BY termination_rate DESC;

-- 9. What is the distribution of employees across locations state?
SELECT 
    COUNT(emp_id) AS emp_count, location_state
FROM
    human_rs
WHERE
    age >= 18 AND termdate IS NULL
GROUP BY location_state
ORDER BY emp_count DESC;

-- 10. How has the company's employee count changed over time based on hire and term dates?
SELECT 
    `year`,
    emp_hired,
    emp_fired,
    emp_hired - emp_fired AS net_change,
    ROUND((emp_hired - emp_fired) / emp_hired * 100,
            2) AS net_percent_change
FROM
    (SELECT 
        YEAR(hire_date) AS `year`,
            COUNT(*) AS emp_hired,
            SUM(CASE
                WHEN
                    termdate IS NOT NULL
                        AND termdate <= CURDATE()
                THEN
                    1
                ELSE 0
            END) AS emp_fired
    FROM
        human_rs
    WHERE
        age >= 18
    GROUP BY `year`) AS employee_status
ORDER BY `year`;

-- 11. What is the tenure distribution for each department?
SELECT 
    department,
    ROUND(AVG(DATEDIFF(termdate, hire_date) / 365),
            0) AS average_tenure
FROM
    human_rs
WHERE
    termdate <= CURDATE()
        AND termdate IS NOT NULL
        AND age >= 18
GROUP BY department;

create database human_resources;
drop database if exists human_resources;

SELECT 
    COUNT(*)
FROM
    human_rs;
drop table human_rs;
SELECT 
    *
FROM
    human_rs
LIMIT 50;
-- MODIFY COLUMN -Used to change the properties of a column without renaming it. Can change data type, constraints, etc.
-- CHANGE COLUMN-Used to rename a column and optionally change its properties. Requires you to specify the new column definition.

-- data cleaning
alter table human_rs 
change column ï»¿id emp_id varchar(25) null;
explain human_rs;
select birthdate from human_rs;
select hire_date from human_rs;
select termdate from human_rs;

-- set sql_safe_updates=0; turn off safe update security measure- you can make updates to tables without where clause
-- convert birthdate to date format
UPDATE human_rs 
SET 
    birthdate = CASE
        WHEN
            birthdate LIKE '%/%'
        THEN
            DATE_FORMAT(STR_TO_DATE(birthdate, '%m/%d/%Y'),
                    '%Y-%m-%d')
        WHEN
            birthdate LIKE '%-%'
        THEN
            DATE_FORMAT(STR_TO_DATE(birthdate, '%m-%d-%Y'),
                    '%Y-%m-%d')
        ELSE NULL
    END;

-- convert birthdate datatype from text to date
alter table human_rs
modify column birthdate date;

-- convert hire_date to date format
UPDATE human_rs 
SET 
    hire_date = CASE
        WHEN
            hire_date LIKE '%/%'
        THEN
            DATE_FORMAT(STR_TO_DATE(hire_date, '%m/%d/%Y'),
                    '%Y-%m-%d')
        WHEN
            birthdate LIKE '%-%'
        THEN
            DATE_FORMAT(STR_TO_DATE(hire_date, '%m-%d-%Y'),
                    '%Y-%m-%d')
        ELSE NULL
    END;

-- convert hire_date datatype from text to date
alter table human_rs
modify column hire_date date;

update human_rs
set termdate=date(str_to_date(termdate,'%Y-%m-%d %H:%i:%s UTC'))
where termdate is not null and termdate <>'';

update human_rs
set termdate=str_to_date(nullif(termdate,''),'%Y-%m-%d')
where termdate is null or termdate='';

-- convert termdate datatype from text to date
alter table human_rs
modify column termdate date;

-- identify outliers in the dataset
alter table human_rs
add column age int;

select birthdate,age from human_rs limit 50;
-- update human_rs
-- set age=datediff(curdate(),birthdate)/366;

update human_rs
set age=timestampdiff(YEAR,birthdate,curdate());

SELECT 
    MIN(age) AS youngest, MAX(age) AS oldest
FROM
    human_rs;

-- exclude data in reports
SELECT count(*)
FROM human_rs
WHERE age<18;

-- excluded termdates
SELECT count(*)
FROM human_rs
WHERE termdate>curdate();





