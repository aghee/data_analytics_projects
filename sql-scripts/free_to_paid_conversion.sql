show tables;

/*
Insights on the following qns:
What is the free-to-paid conversion rate of students who have watched a lecture on the 365 platform?
What is the average duration between the registration date and when a student has watched a lecture for the first time (date of first-time engagement)?
What is the average duration between the date of first-time engagement and when a student purchases a subscription for the first time (date of first-time purchase)?
How can we interpret these results, and what are their implications?
*/

select * from student_engagement where student_id=255198;

select count(*) from student_info;

select count(*) as no_of_times_visited
from student_engagement
where student_id=255201;

select *
from student_info
order by date_registered limit 50;

select * from student_purchases where student_id is not null;

select *
from student_info si
inner join student_purchases sp
on si.student_id=sp.student_id
where si.student_id=255198;

-- DATEDIFF function in MySQL
-- DATEDIFF(end_date, start_date)
-- DATEDIFF(CURDATE(), birth_date) AS age_in_days -find age
-- join same as inner join
select *,
datediff(date_purchased,date_registered) as date_diff_watch_purch,
datediff(date_watched,date_registered) as date_diff_reg_watch
from student_info si
inner join student_purchases sp
on si.student_id=sp.student_id
inner join student_engagement se
on si.student_id=se.student_id
where si.student_id=255306;

select distinct(count(*))
from student_info s
join student_engagement se
on  s.student_id=se.student_id;

-- Subquery
SELECT 
    COUNT(*)
FROM
    (SELECT 
        s.student_id,
            s.date_registered,
            MIN(se.date_watched) first_date_watched,
            MIN(sp.date_purchased) first_date_purchased,
            DATEDIFF(MIN(se.date_watched), s.date_registered) date_diff_reg_watch,
            CASE
                WHEN MIN(sp.date_purchased) IS NOT NULL THEN DATEDIFF(MIN(sp.date_purchased), MIN(se.date_watched))
                ELSE NULL
            END AS date_diff_watch_purch
    FROM
        student_info s
    JOIN student_engagement se ON s.student_id = se.student_id
    LEFT JOIN student_purchases sp ON s.student_id = sp.student_id
    GROUP BY s.student_id , s.date_registered
    HAVING MIN(se.date_watched) <= MIN(sp.date_purchased)
        OR MIN(sp.date_purchased) IS NULL) AS totalstudrecords;


SELECT
s.student_id,
s.date_registered,min(se.date_watched) first_date_watched,
min(sp.date_purchased) first_date_purchased,
-- ((select count(student_id) from testview where first_date_purchased is not null)/(select count(student_id) from testview where first_date_watched is not null)) *100 as conversion_rate,
datediff(min(se.date_watched),s.date_registered) date_diff_reg_watch,
case when min(sp.date_purchased) is not null then datediff(min(sp.date_purchased),min(se.date_watched))
else null
end as date_diff_watch_purch
FROM  student_info s 
join student_engagement se
on s.student_id=se.student_id
left join student_purchases sp
on s.student_id=sp.student_id
group by s.student_id,s.date_registered
having min(se.date_watched) <= min(sp.date_purchased) or min(sp.date_purchased) is null;


select * from testview;
select count(student_id) from testview where first_date_purchased is not null;
select count(student_id) from testview where first_date_watched is not null;
drop view testview;

-- Conversion rate
select round(count(first_date_purchased)/count(first_date_watched),2)*100 as 'conversion rate'
from testview;

-- Average Duration Between Registration and First-Time Engagement-multiply by 100???
select avg(date_diff_reg_watch) as av_reg_watch from testview;
select round(sum(date_diff_reg_watch)/count(date_diff_reg_watch),2) as av_reg_watch from testview;
select round(sum(date_diff_reg_watch)/count(first_date_watched),2) as av_reg_watch from testview;

-- Average Duration Between First-Time Engagement and First-Time Purchase
select round(avg(date_diff_watch_purch),2) as av_watch_purch from testview;
select round(sum(date_diff_watch_purch)/count(date_diff_watch_purch),2) as av_watch_purch from testview;
select round(sum(date_diff_watch_purch)/count(first_date_purchased),2) as av_watch_purch from testview;

-- Main Query
select 
round(count(first_date_purchased)/count(first_date_watched),2)*100 as 'conversion rate',
round(sum(date_diff_reg_watch)/count(date_diff_reg_watch),2) as av_reg_watch,
round(avg(date_diff_watch_purch),2) as av_watch_purch
from 
(
SELECT
s.student_id,
s.date_registered,min(se.date_watched) first_date_watched,
min(sp.date_purchased) first_date_purchased,
datediff(min(se.date_watched),s.date_registered) date_diff_reg_watch,
case when min(sp.date_purchased) is not null then datediff(min(sp.date_purchased),min(se.date_watched))
else null
end as date_diff_watch_purch
FROM  student_info s 
join student_engagement se
on s.student_id=se.student_id
left join student_purchases sp
on s.student_id=sp.student_id
group by s.student_id,s.date_registered
having min(se.date_watched) <= min(sp.date_purchased) or min(sp.date_purchased) is null
) stud_records;



/*
SELECT
s.student_id,
s.date_registered,
min(se.date_watched) first_date_watched,
min(sp.date_purchased) first_date_purchased,
datediff(min(se.date_watched),s.date_registered) date_diff_reg_watch,
case when min(sp.date_purchased) is not null then datediff(min(sp.date_purchased),min(se.date_watched))
else null
end as date_diff_watch_purch
FROM student_info s
left join student_engagement se
on s.student_id=se.student_id
left join student_purchases sp
on s.student_id=sp.student_id
group by s.student_id,s.date_registered;*/


alter table student_engagement
add column studee int;

alter table student_engagement
add constraint fk_eng_info
foreign key (studee) references student_info(student_id);

desc student_engagement;
explain student_engagement;

-- identify foreign key--not working???
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM 
    INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE 
    TABLE_SCHEMA = 'student_engagement' 
    AND REFERENCED_TABLE_NAME IS NOT NULL;