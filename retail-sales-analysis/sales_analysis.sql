-- Number of sales made in each time of the day per weekday*
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

-- monetary worth/value of sales made during each time of day*
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

-- Which of the customer types brings the most revenue?*
select sum(total) as total_revenue,customer_type
from sales
group by customer_type
order by total_revenue desc;

-- Which city has the largest tax percent/ VAT (Value Added Tax)*
select city,round(avg(VAT),1) as highest_tax
from sales
group by city
order by highest_tax desc;

-- customer type that pays the most in VAT
select customer_type,avg(VAT) as highest_tax
from sales
group by customer_type
order by highest_tax desc;