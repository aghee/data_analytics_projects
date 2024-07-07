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

-- most common payment method*
select count(payment_method) as payment_cnt,payment_method
from sales
group by payment_method
order by count(payment_method) desc;

-- most selling productline*
select product_line,count(product_line) as prd_cnt
from sales
group by product_line
order by prd_cnt desc ;

-- total revenue by month*
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

-- productline with largest revenue*
select product_line,
sum(total) as total_revenue
from sales
group by product_line
order by total_revenue desc;

-- city with largest revenue*
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

-- branch that sold more products than average product sold*
select branch,
sum(quantity) as qty
from sales
group by branch
having sum(quantity)>(select avg(quantity) from sales);

-- most common product line by gender*
select count(product_line) as prod_popularity,gender,product_line
from sales
group by gender,product_line
order by prod_popularity desc;

-- average rating of each product line*
select round(avg(rating), 2) as prod_avg_rating,
product_line
from sales
group by product_line
order by prod_avg_rating desc ;