# Staff Distribution Analysis

## Table of Contents

- [Project Overview](#project-overview)
- [Data Sources](#data-sources)
- [Tools used](#tools-used)
- [Data Cleaning/Preparation](#data-cleaning-or-preparation)
- [Exploratory Data Analysis](#exploratory-data-analysis)
- [Data Analysis](#data-analysis)
- [Findings](#findings)
- [Recommendations](#recommendations)
- [Limitations](#limitations)
- [References](#references)

## Project Overview
This project aims to understand the distribution of staff across different departments,locations and roles within an organization. This analysis helps in identifying staffing imbalances, organization turnover rate, optimizing resource allocation, and planning for future hiring needs.

### Data Visualization Report


### Data Sources
Human Resources Data: The primary data set used for the analysis is "Staffdata.csv" that contains sufficient information about each employee.

### Tools used
- Data cleaning and analysis - MySQL Workbench
  - [Download here](https://www.mysql.com/products/workbench/)
- Data Visualization/ Creating reports - PowerBI
  - [Download here](powerbi.microsoft.com)

### Data Cleaning or Preparation
This involved tasks to transform the data into a format appropriate for the tools that will be used to analyze and present the data.
- Data loading and inspection
- Removing duplicate values
- Handling missing values(replaced missing values with null in termdate field)
- Standardizing data formats for example, date to be consistent with YYYY-M-D format
- Removing unwanted characters from textfields for exmple using TRIM, REPLACE
- Filtering outliers for example excluding age less than 18 years in the analysis
- Feature engineering for example extracting day,month,year from a date

### Exploratory Data Analysis
This involved exploring the staff/employee data to answer key questions such as:
- What is the race/ethnicity breakdown of employees in the company?
- What is the age distribution of employees in the company?
- What is the gender breakdown of employees in the company?
- How does the gender distribution vary across departments and job titles?
- What is the tenure distribution for each department?
- What is the average length of employment for employees who have been terminated?
- How has the company's employee count changed over time based on hire and term dates?
- What is the distribution of employees across locations state?
- How does the gender distribution vary across departments and job titles?
- How many employees work at headquarters versus remote locations?

### Data Analysis
```sql
# categorize employees into age-groups and return total number in each group based on gender
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
```
```sql
# How has the company's employee count changed over time based on hire and term dates?
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
```
```sql
# What is the tenure distribution for each department?
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
```
```sql
# Which department has the highest turnover rate?
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
```
```sql
# gender breakdown of employees in the company
SELECT 
    gender, COUNT(gender) AS count_by_gender
FROM
    human_rs
WHERE
    age >= 18 AND termdate IS NULL
GROUP BY gender;
```
### Findings
- The age groups created are GEN Z(18-29), Thirty plus_Millennials(30-39), Forty plus_GEN X(40-49) and Fifty plus_Baby Boomers(Over 50). The highest number of staff in the company are millennials aged between 30 and 40 years, and the least are the baby boomers aged over 50 years.
- The company has more male than female staff.
- There are significantly more staff working at headquarters compared to those working remotely.
- Legal department has the highest turnover rate while Marketing has the lowest. This means that the company may have to invest more resources to hire replacements in the Legal department.
- In terms of race, the highest number of employees are white and the least are Native Hawaiian or other Pacific Islander.
- The net change of staff has increased per year as seen in the period analyzed.
- The average length of employment for staff at the company is 8 years.

### Recommendations
- The company may provide flexible retirement planning and phased retirement options for Baby Boomers to leverage their experience and knowledge. This may also foster knowledge management by ensuring more experienced staff pass down knowledge to junior staff before their retirement.
- The company may introduce policies that support work-life balance, such as remote work options, and parental leave policies, to make the workplace more attractive to female employees.
- The company may consider implementing a hybrid work model that allows employees to split their time between working from headquarters and remotely, to cater for diverse preferences and improve work-life balance.
- The company may conduct a detailed analysis of the causes of high turnover in the Legal department and implement targeted retention strategies such as competitive compensation and career advancement opportunities.It may be useful to conduct exit interviews to understand the reason employees exit in this department.
- The company may implement targeted recruitment programs to increase the representation of underrepresented racial and ethnic groups.
- The company may implement scalable HR practices and systems to manage the increasing workforce efficiently, such as employee self-service portals.

### Limitations
- Termdates used are less than or equal to current date.(As at 03.07.2024 ,1395 records are excluded)
```sql
# excluded termdates
SELECT count(*)
FROM human_rs
WHERE termdate>curdate();
```
- Given that the legal age of working in most countries across the world is 18 years and above, the ages used in the analysis excluded ages less than 18 years.(967 records excluded)
```sql
# excluded ages
SELECT count(*)
FROM human_rs
WHERE age<18;
```
### References
- Stackoverflow [Visit](https://stackoverflow.com/questions/tagged/window-functions#:~:text=A%20window%20function%20is%20a,partition%20of%20the%20result%20set.)
