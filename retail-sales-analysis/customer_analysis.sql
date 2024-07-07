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

-- what is the distribution of customers in the use of payment methods*
select * from sales;

select count(*) as cnt,gender,payment_method
from sales
group by payment_method,gender
order by gender,payment_method asc;

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

-- What is the gender distribution per branch?*
select distinct branch,count(gender) as cnt,gender
from sales
group by branch,gender
order by branch asc,cnt desc;

-- Which time of the day do customers give most ratings?*
select count(rating) as cnt,time_of_day
from sales
group by time_of_day
order by cnt desc;

-- Which time of the day do customers give most ratings per branch?
select count(rating) as cnt,time_of_day,branch
from sales
group by time_of_day,branch
order by branch asc,cnt desc;

-- Which time of the day do customers give highest ratings?*
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

-- Which day of the week has the best avg ratings?*
select avg(rating) as avg_rating, day_name
from sales
group by day_name
order by avg_rating desc;

-- Which day of the week has the best average ratings per branch*
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