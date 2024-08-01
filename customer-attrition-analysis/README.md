# Retail Sales Analysis

## Table of Contents

- [Project Overview](#project-overview)
- [Data Visualization Report](#data-visualization-report)
- [Data Sources](#data-sources)
- [Tools used](#tools-used)
- [Data Cleaning/Preparation](#data-cleaning-or-preparation)
- [Exploratory Data Analysis](#exploratory-data-analysis)
- [Data Analysis](#data-analysis)
- [Findings](#findings)
- [Recommendations](#recommendations)
- [References](#references)

## Project Overview
This project analyzes Walmart sales data to identify top-performing branches and products, understand sales trends, and study customer behavior. It aims to enhance and optimize sales strategies using data from the Kaggle Walmart Sales Forecasting Competition, which includes historical sales data for 45 stores and the impact of holiday markdown events.

### Data Visualization Report
---
![rpt1](https://github.com/aghee/data_analytics_projects/assets/19945989/5b492634-19a9-4faa-aa31-310850d5047b)
![rpt3](https://github.com/aghee/data_analytics_projects/assets/19945989/bd3bc028-877c-495c-83ab-6d4104fbffe5)
![rpt2](https://github.com/aghee/data_analytics_projects/assets/19945989/19e037fc-478e-4f96-8b63-1364c372c2ee)


### Data Sources
---
Sales Data: The primary data set used for the analysis is "walmartsales.csv" that contains sufficient information about the sales from target stores.This dataset contains sales transactions from three different branches of Walmart,located in Mandalay, Yangon and Naypyitaw. The data contains 17 columns and 1000 rows.

### Tools used
---
- Data cleaning and analysis - MySQL Workbench
  - [Download here](https://www.mysql.com/products/workbench/)
- Data Visualization/ Creating reports - PowerBI
  - [Download here](powerbi.microsoft.com)

### Data Cleaning or Preparation
---
This involved tasks to transform the data into a format appropriate for the tools that will be used to analyze and present the data.
- Data loading and inspection
- Removing duplicate values
- Handling missing values
- Standardizing data formats for example, date to be consistent with YYYY-M-D format
- Removing unwanted characters from textfields for exmple using TRIM, REPLACE
- Feature engineering for example adding new columns month_name,day_name,time_of_day

### Exploratory Data Analysis
---
This involved exploring the sales data to answer key questions such as:  
**Customer analysis**
- What is the most common customer type?
- Which customer type buys the most?
- What is the gender of most of the customers?
- How many unique customer types does the data have?
- How many unique payment methods does the data have?
- What is the gender distribution per branch?
- Which time of the day do customers give most ratings?
- Which time of the day do customers give most ratings per branch?
- Which day of the week has the best average ratings?
- Which day of the week has the best average ratings per branch?

**Sales analysis**
- Number of sales made in each time of the day per weekday
- Monetary worth/value of sales made in each time of the day per weekday(**NB:weekday means monday to friday**)
- Monetary worth/value of sales made during each time of day
- Which of the customer types brings the most revenue?
- Which city has the largest tax percent/ VAT (Value Added Tax)
- Customer type that pays the most in VAT

**Product analysis**
- What is the most selling product line?
- What is the most common payment method?
- What is the total revenue by month?
- How many unique product lines does the data have?
- What month had the largest COGS?
- What product line had the largest revenue?
- What is the city with the largest revenue?
- What product line had the largest VAT?
- Which branch sold more products than average product sold?
- What is the most common product line by gender?
- What is the average rating of each product line?

### Data Analysis
```sql
# monetary worth/value of sales made during each time of day
WITH highest_sales AS(
SELECT sum(total) as total_sales,
time_of_day,
day_name
FROM sales
WHERE weekday(DATE) BETWEEN 0 AND 4
GROUP BY time_of_day,day_name
ORDER BY total_sales
),
salessummary AS(
SELECT total_sales,
time_of_day,
day_name,
RANK() OVER(PARTITION BY time_of_day ORDER BY total_sales DESC) AS `rank`
FROM highest_sales
)
SELECT time_of_day,total_sales
FROM salessummary
WHERE `rank`=1
ORDER BY total_sales DESC;
```
```sql
# monetary worth/value of sales made in each time of the day per weekday
# note-weekday means monday to friday
SELECT 
    SUM(total) AS total_sales, time_of_day, day_name
FROM
    sales
WHERE
    WEEKDAY(date) BETWEEN 0 AND 4
GROUP BY time_of_day , day_name
ORDER BY time_of_day ASC , total_sales DESC;
```
```sql
# productline with largest revenue*
SELECT 
    product_line, SUM(total) AS total_revenue
FROM
    sales
GROUP BY product_line
ORDER BY total_revenue DESC;
```
```sql
# Which day of the week has the best average ratings per branch*
WITH best_rating AS(
SELECT AVG(rating) AS avg_rating,
day_name,
branch,
RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS `rank`
FROM sales
GROUP BY day_name,branch
ORDER BY branch ASC,avg_rating DESC
)
SELECT day_name,avg_rating,branch
FROM best_rating
WHERE `rank`=1;
```
### Findings
---
- Total revenue from member customers (164k) is more than that from normal customers (157k)
- January had the highest revenue (116k) while February had the least revenue (96k) for Q1
- A big number of sales were made during the evening hours
- In terms of the number of products sold, fashion accessories were the highest in number but food and beverages brought in the highest revenue. This shows that selling more products in a particular product line does not necessarily translate to that product bringing in the highest revenue.
- Food and beverages had the highest rating, while home and lifestyle had the lowest.
- Male clients prefer E-wallet payment method while female clients prefer cash payment.
- Each of the branches have good ratings with highest branches having a rating of 7.3 followed closely by the next having 7.2


### Recommendations
---
- The company may re-organize placement of its products at the store such that the products bringing the least revenue are located in close proximity to the fast-moving products to increase their visibility to the customers.
- Given that member customers generate higher revenue, the company may consider enhancing membership benefits and promoting memberships to attract normal customers to convert.
- The company may analyze why January is the highest revenue month and replicate successful strategies in other months.
- The company introduce evening-specific promotions to capitalize on the high sales volume during these hours.
- The company may adjust staff schedules to ensure adequate coverage during peak evening hours to enhance customer service and sales efficiency.
- The company should ensure stock prioritizes high-revenue items like food and beverages.
- The company should investigate and address issues in the home and lifestyle category to improve product ratings, for example through better customer service.
- Given that all the branches have good ratings, the company should regularly gather and act on customer feedback to maintain and improve these ratings, ensuring consistent high-quality service across all locations.

### References
---
- Stackoverflow [Visit](https://stackoverflow.com/questions/tagged/window-functions#:~:text=A%20window%20function%20is%20a,partition%20of%20the%20result%20set.)
