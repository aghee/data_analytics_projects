CREATE DATABASE if not exists shopsales;
create table if not exists  sales(
invoice_id varchar(30) not null primary key,
branch varchar(30) not null,
city varchar(20) not null,
customer_type varchar(30) not null,
gender varchar(20) not null,
product_line varchar(80) not null,
unit_price decimal(10,2) not null,
quantity integer not null,
VAT float(6,4) not null,
total decimal(12,4) not null,
date datetime not null,
time time not null,
payment_method varchar(15) not null,
cogs decimal(10,2) not null,
gross_margin_percent float(11,9),
gross_income decimal(12,4) not null,
rating float(2,1)
);

-- **********product analysis***********
SELECT 
    *
FROM
    sales;
-- feature engineering
-- add new column-time_of_day to sales
select time,
(case when `time` between '00:00:00' and '12:00:00' then 'Morning'
when `time` between '12:01:00' and '16:00:00' then 'Afternoon'
else 'Evening' end) as time_of_day
from sales;

alter table sales
add column time_of_day varchar(20);

update sales
set time_of_day=(case when `time` between '00:00:00' and '12:00:00' then 'Morning'
when `time` between '12:01:00' and '16:00:00' then 'Afternoon'
else 'Evening' end);

-- add new column-day_name to sales
select dayname(date) as day_name
from sales;

alter table sales
add column day_name varchar(20);

update sales
set day_name=dayname(date);

-- add new column-month_name to sales
select date,monthname(date)
from sales;

alter table sales
add column month_name varchar(20);

update sales
set month_name=monthname(date);

-- unique cities
select count(distinct(city))
from sales;

-- in which city is each branch
select distinct city,branch
from sales;

-- unique product lines
select count(distinct product_line)
from sales;

-- most common payment method
select count(payment_method) as payment_cnt,payment_method
from sales
group by payment_method
order by count(payment_method) desc;

-- most selling productline
select product_line,count(product_line) as prd_cnt
from sales
group by product_line
order by prd_cnt desc ;

-- total revenue by month
select month_name as `Month`,
sum(total) as total_revenue
from sales
group by `Month`
order by total_revenue desc;

-- largest cogs
select month_name as `Month`,
sum(cogs) as Total_COGS
from sales
group by `Month`
order by Total_COGS desc;

-- productline with largest revenue
select product_line,
sum(total) as total_revenue
from sales
group by product_line
order by total_revenue desc;

-- city with largest revenue
select city,branch,
sum(total) as total_revenue
from sales
group by city,branch
order by total_revenue desc;

-- product with largest VAT
select product_line,
avg(VAT) as avg_tax
from sales
group by product_line
order by avg_tax desc;

-- select sum(total)/count(total) as avg_sales,
-- case when 
-- from sales;

-- branch that sold more products than average product sold
select branch,
sum(quantity) as qty
from sales
group by branch
having sum(quantity)>(select avg(quantity) from sales);

-- most common product line by gender
select count(product_line) as prod_popularity,gender,product_line
from sales
group by gender,product_line
order by prod_popularity desc;

-- average rating of each product line
select round(avg(rating), 2) as prod_avg_rating,
product_line
from sales
group by product_line
order by prod_avg_rating desc ;

-- ***********sales analysis**********
-- Number of sales made in each time of the day per weekday
select distinct day_name
from sales
where weekday(date) between 0 and 4;

select time_of_day,
day_name,
count(*) as total_sales
from sales
where weekday(date) between 0 and 4
group by time_of_day,day_name
order by time_of_day asc,total_sales desc;

-- monetary worth/value of sales made in each time of the day per weekday
-- note-weekday means monday to friday
select sum(total) as total_sales,time_of_day,day_name
from sales
where weekday(date) between 0 and 4
group by time_of_day,day_name
order by time_of_day asc,total_sales desc;

-- monetary worth/value of sales made during each time of day
with highest_sales as (
select sum(total) as total_sales,
time_of_day,
day_name,
RANK() OVER(PARTITION BY time_of_day order by sum(total) desc) as `rank`
from sales
where weekday(date) between 0 and 4
group by time_of_day,day_name
order by total_sales
)
select time_of_day,total_sales
from highest_sales
where `rank`=1
order by total_sales desc;

-- monetary worth/value of sales made during each time of day
with highest_sales as(
select sum(total) as total_sales,
time_of_day,
day_name
from sales
where weekday(date) between 0 and 4
group by time_of_day,day_name
order by total_sales
),
salessummary as(
select total_sales,
time_of_day,
day_name,
RANK() OVER(PARTITION BY time_of_day ORDER BY total_sales desc) as `rank`
from highest_sales
)
select time_of_day,total_sales
from salessummary
where `rank`=1
order by total_sales desc;

-- Which of the customer types brings the most revenue?
select sum(total) as total_revenue,customer_type
from sales
group by customer_type
order by total_revenue desc;

-- Which city has the largest tax percent/ VAT (Value Added Tax)
select city,avg(VAT) as highest_tax
from sales
group by city
order by highest_tax desc;

-- customer type that pays the most in VAT
select customer_type,avg(VAT) as highest_tax
from sales
group by customer_type
order by highest_tax desc;

-- ***********Customer analysis**********
-- How many unique customer types does the data have
select count(distinct customer_type) as unique_cust_cnt
from sales;

-- how many customers are in each customer type
select count(*)as cnt,
customer_type
from sales
group by customer_type;

select count(*) from sales;

-- How many unique payment methods does the data have?
select count(distinct payment_method)
from sales;

-- what is the distribution of customers in the use of payment methods
select count(*) as cnt,
payment_method
from sales
group by payment_method;

-- What is the most common customer type?
select count(customer_type) as cnt,customer_type
from sales
group by customer_type
order by cnt desc;

--  customer type that buys the most -get the frequency of purchase as opposed to the worth of the purchase
select *
from sales
where total is null or total ='';

select count(customer_type) as cnt,customer_type
from sales
group by customer_type
order by cnt desc;

-- What is the gender of most of the customers?
select count(gender) as cnt,gender
from sales
group by gender;

-- What is the gender distribution per branch?
select distinct branch,count(gender) as cnt,gender
from sales
group by branch,gender
order by branch asc,cnt desc;

-- Which time of the day do customers give most ratings?
select count(rating) as cnt,time_of_day
from sales
group by time_of_day
order by cnt desc;

-- Which time of the day do customers give most ratings per branch?
select count(rating) as cnt,time_of_day,branch
from sales
group by time_of_day,branch
order by branch asc,cnt desc;

-- Which time of the day do customers give highest ratings?
-- may reflect the quality of service at different times of the day
select avg(rating) as avg_rating,time_of_day
from sales
group by time_of_day
order by avg_rating desc;

-- Which time of the day do customers give highest ratings per branch?
select avg(rating) as avg_rating,time_of_day,branch
from sales
group by time_of_day,branch
order by branch asc,avg_rating desc;

-- Which day of the week has the best avg ratings?
select avg(rating) as avg_rating, day_name
from sales
group by day_name
order by avg_rating desc;

-- Which day of the week has the best average ratings per branch
with best_rating as(
select avg(rating) as avg_rating,
day_name,
branch,
RANK() OVER(PARTITION BY branch order by avg(rating) desc) as `rank`
from sales
group by day_name,branch
order by branch asc,avg_rating desc
)
select day_name,avg_rating,branch
from best_rating
where `rank`=1;

-- CTEs and window functions-rank the entries by their average rating 
-- within each branch and then filter to get only the highest-rated entries per branch.
WITH avg_branch_ratings AS (
    SELECT 
        day_name, 
        branch, 
        AVG(rating) AS avg_rating,
        RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) desc) AS `rank`
    FROM sales
    GROUP BY day_name, branch
)
SELECT 
    day_name, 
    branch, 
    avg_rating
    `rank`
FROM avg_branch_ratings
WHERE `rank` = 1
ORDER BY branch;

-- In case there is a tie in the avg_rating for multiple days in a branch, and you only want to retrieve one record,
-- use ROW_NUMBER() instead of RANK()
WITH avg_branch_ratings AS (
    SELECT 
        day_name, 
        branch, 
        AVG(rating) AS avg_rating,
        ROW_NUMBER() OVER (PARTITION BY branch ORDER BY AVG(rating) desc) AS row_num
    FROM sales
    GROUP BY day_name, branch
)
SELECT 
    day_name, 
    branch, 
    avg_rating,
    row_num
FROM avg_branch_ratings
WHERE row_num = 1
ORDER BY branch;






















