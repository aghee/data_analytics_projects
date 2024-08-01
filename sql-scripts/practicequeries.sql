use practice_queries;
/*  EDA Basic checks
DATA COAT(Consistent, Organized, Accurate,Trustworthy)
1.check for null values-field having >0 shows nulls exist in that field
sum(case when field is null then 1 else 0 end) as field_alias)
2.check for blanks
2.check for duplicate records -row_number()
3.ensure standard format of data eg 
dates, leading and trailing spaces,abbreviations vs fullword,
uppercase vs lowercase,  periods/fullstop/hyphens etc
4. remove unnecessary rows and columns*/

--Q1 fetch all the duplicate records in the table
drop table IF EXISTS users;
create table users
(
user_id int primary key,
user_name varchar(30) not null,
email varchar(50));

insert into users values
(1, 'Sumit', 'sumit@gmail.com'),
(2, 'Reshma', 'reshma@gmail.com'),
(3, 'Farhana', 'farhana@gmail.com'),
(4, 'Robin', 'robin@gmail.com'),
(5, 'Robin', 'robin@gmail.com');

SELECT TOP 5* FROM users;
WITH DUP_RECORDS AS
(
select user_id,user_name,ROW_NUMBER() over(partition by user_name  order by user_id) as row_num
from [dbo].[users]
)
select *
from DUP_RECORDS
where row_num <>1;

select *
from (
select user_id,user_name,ROW_NUMBER() over(partition by user_name  order by user_id) as row_num
from [dbo].[users]
)subquery1
where row_num<>1;

-- Q2 Write a SQL query to fetch the second last record from a employee table.

drop table IF EXISTS employee;
create table employee
( emp_ID int primary key
, emp_NAME varchar(50) not null
, DEPT_NAME varchar(50)
, SALARY int);

insert into employee values(101, 'Mohan', 'Admin', 4000);
insert into employee values(102, 'Rajkumar', 'HR', 3000);
insert into employee values(103, 'Akbar', 'IT', 4000);
insert into employee values(104, 'Dorvin', 'Finance', 6500);
insert into employee values(105, 'Rohit', 'HR', 3000);
insert into employee values(106, 'Rajesh',  'Finance', 5000);
insert into employee values(107, 'Preet', 'HR', 7000);
insert into employee values(108, 'Maryam', 'Admin', 4000);
insert into employee values(109, 'Sanjay', 'IT', 6500);
insert into employee values(110, 'Vasudha', 'IT', 7000);
insert into employee values(111, 'Melinda', 'IT', 8000);
insert into employee values(112, 'Komal', 'IT', 10000);
insert into employee values(113, 'Gautham', 'Admin', 2000);
insert into employee values(114, 'Manisha', 'HR', 3000);
insert into employee values(115, 'Chandni', 'IT', 4500);
insert into employee values(116, 'Satya', 'Finance', 6500);
insert into employee values(117, 'Adarsh', 'HR', 3500);
insert into employee values(118, 'Tejaswi', 'Finance', 5500);
insert into employee values(119, 'Cory', 'HR', 8000);
insert into employee values(120, 'Monica', 'Admin', 5000);
insert into employee values(121, 'Rosalin', 'IT', 6000);
insert into employee values(122, 'Ibrahim', 'IT', 8000);
insert into employee values(123, 'Vikram', 'IT', 8000);
insert into employee values(124, 'Dheeraj', 'IT', 11000);

SELECT TOP 5* FROM employee;
WITH second_last_row  as(
select em.*,ROW_NUMBER() over(order by emp_ID DESC)as row_num
from [dbo].[employee] em
)
select *
from second_last_row
where row_num=2;

select *
from (
select em.*,ROW_NUMBER() over(order by emp_ID DESC)as row_num
from [dbo].[employee] em)AS subq1
where row_num=2;

-- Q3.Write a SQL query to display only the details of employees 
-- who either earn the highest salary or the lowest salary in each
-- department from the employee table.

SELECT em.*, MAX(SALARY) OVER(PARTITION BY DEPT_NAME) as highest_salo,
MIN(SALARY) OVER(PARTITION BY DEPT_NAME) as least_salo
FROM [dbo].[employee] em;

SELECT em.*, DENSE_RANK() OVER(PARTITION BY DEPT_NAME ORDER BY salary desc) as salo_ranking
FROM [dbo].[employee] em;

WITH sal_info as
(
SELECT em.*, MAX(SALARY) OVER(PARTITION BY DEPT_NAME) as highest_salo,
MIN(SALARY) OVER(PARTITION BY DEPT_NAME) as least_salo
FROM [dbo].[employee] em
)
select emp_ID,emp_NAME,DEPT_NAME,SALARY
from sal_info
where SALARY=highest_salo or SALARY=least_salo;

select e.*
from employee e
JOIN
(
SELECT em.*, MAX(SALARY) OVER(PARTITION BY DEPT_NAME) as highest_salo,
MIN(SALARY) OVER(PARTITION BY DEPT_NAME) as least_salo
FROM [dbo].[employee] em
) subq1
on e.emp_ID=subq1.emp_ID
and (e.salary = subq1.highest_salo or e.salary = subq1.least_salo)
order by subq1.dept_name, subq1.salary;

-- Q4 -From the doctors table, fetch the details of doctors who work 
-- in the same hospital but in different speciality.
drop table IF EXISTS doctors;
create table doctors
(
id int primary key,
name varchar(50) not null,
speciality varchar(100),
hospital varchar(50),
city varchar(50),
consultation_fee int
);

insert into doctors values
(1, 'Dr. Shashank', 'Ayurveda', 'Apollo Hospital', 'Bangalore', 2500),
(2, 'Dr. Abdul', 'Homeopathy', 'Fortis Hospital', 'Bangalore', 2000),
(3, 'Dr. Shwetha', 'Homeopathy', 'KMC Hospital', 'Manipal', 1000),
(4, 'Dr. Murphy', 'Dermatology', 'KMC Hospital', 'Manipal', 1500),
(5, 'Dr. Farhana', 'Physician', 'Gleneagles Hospital', 'Bangalore', 1700),
(6, 'Dr. Maryam', 'Physician', 'Gleneagles Hospital', 'Bangalore', 1500);

SELECT * FROM doctors;

SELECT d1.name,d2.speciality,d1.hospital,d1.city
FROM doctors d1
JOIN doctors d2
on d1.hospital=d2.hospital and d1.speciality <>d2.speciality and d1.id<>d2.id;

SELECT d1.name,d2.speciality,d1.hospital,d1.city
FROM doctors d1,doctors d2
WHERE d1.hospital=d2.hospital and d1.speciality <>d2.speciality and d1.id<>d2.id;

-- Write SQL query to fetch the doctors who work in same hospital 
-- irrespective of their specialty.
SELECT d1.name,d2.speciality,d1.hospital,d1.city
FROM doctors d1
JOIN doctors d2
on d1.hospital=d2.hospital and d1.id<>d2.id;

SELECT d1.name,d2.speciality,d1.hospital,d1.city
FROM doctors d1,doctors d2
WHERE (d1.hospital=d2.hospital) and (d1.id<>d2.id);

select em.*,
LAG(salary,2,0) over(partition by dept_name order by emp_id) as prev_salo
from employee em;

select em.*,
case 
when em.salary=LEAD(salary,1) over(partition by dept_name order by emp_id) then 'salary equals the next value'
when em.salary=LEAD(salary,2) over(partition by dept_name order by emp_id) then 'salary equals the next two values'
when em.salary=LEAD(salary,3) over(partition by dept_name order by emp_id) then 'salary equals the next three values'
else 'Salary does not fulfill any conditions' end as 'salaries'
from employee em;

-- Q5 - From the login_details table, fetch the users who logged in consecutively 3 or more times. 
drop table IF EXISTS login_details;
create table login_details(
login_id int primary key,
user_name varchar(50) not null,
login_date date);

delete from login_details;
-- GETDATE() returns current date and time
insert into login_details values
(101, 'Michael', CURRENT_TIMESTAMP),
(102, 'James', CURRENT_TIMESTAMP),
(103, 'Stewart', CAST(GETDATE() AS DATE)),
(104, 'Stewart', CAST(GETDATE() AS DATE)),
(105, 'Stewart', CAST(GETDATE() AS DATE)),
(106, 'Michael', CAST(GETDATE() AS DATE)),
(107, 'Michael', CAST(GETDATE() AS DATE)),
(108, 'Stewart', CAST(GETDATE() AS DATE)),
(109, 'Stewart',CAST(GETDATE() AS DATE)),
(110, 'James', CAST(GETDATE() AS DATE)),
(111, 'James', CAST(GETDATE() AS DATE)),
(112, 'James', CAST(GETDATE() AS DATE)),
(113, 'James', CAST(GETDATE() AS DATE));

select * from login_details;

EXEC sp_help '[dbo].[login_details]';
WITH consec_logins as 
(
select lg.*,
case when user_name=LEAD(user_name) over(order by login_id) 
and user_name=LEAD(user_name,2) OVER(order by login_id) then user_name
else 'Not repeated' end as consecutive_names
from [dbo].[login_details] lg
)
select distinct consecutive_names
from consec_logins
where consecutive_names<>'Not repeated';

WITH consec_logins as 
(
select lg.*,
case when user_name=LEAD(user_name,2) OVER(order by login_id) then user_name
else 'Not repeated' end as consecutive_names
from [dbo].[login_details] lg
)
select distinct consecutive_names
from consec_logins
where consecutive_names<>'Not repeated';

select distinct repeated_names
from (
select *,
case when user_name = lead(user_name) over(order by login_id)
and  user_name = lead(user_name,2) over(order by login_id)
then user_name else null end as repeated_names
from login_details) x
where x.repeated_names is not null;

--Q6 --From the students table, write a SQL query to interchange the adjacent student names.
-- If there are no adjacent student then the student name should stay the same.
-- Assuming id will be a sequential number always. If id is an odd number then fetch the 
-- student name from the following record. If id is an even number then fetch the student name 
-- from the preceding record.

select st.*,
case when (id%2)<>0 then LEAD(student_name,1,student_name) over(order by id)
when (id%2)=0 then LAG(student_name) over(order by id)
else 'NA' end AS 'new_record'
FROM students st;

drop table IF EXISTS students;
create table students
(
id int primary key,
student_name varchar(50) not null
);
insert into students values
(1, 'James'),
(2, 'Michael'),
(3, 'George'),
(4, 'Stewart'),
(5, 'Robin');

select * from students;
select st.*,
case
when (id%2)<>0 then lead(student_name,1,student_name) over(order by id)
when (id%2)=0 then lag(student_name,1,student_name) over(order by id) else 'NA'
END AS 'updated_stud_name'
from students st;

select st.*,
case
when (id%2)<>0 then lead(student_name) over(order by id)
when (id%2)=0 then lag(student_name,1,student_name) over(order by id) else 'NA'
END AS 'updated_stud_name'
from students st;

-- Q7  From the weather table, fetch all the records when London had extremely 
--cold temperature for 3 consecutive days or more
-- Nb:Weather is considered to be extremely cold then its temperature is less than zero.
drop table IF EXISTS weather;
create table weather
(
id int,
city varchar(50),
temperature int,
day date
);
delete from weather;
-- CAST()- directly converts string to date type
-- CONVERT()- Allows for more control over the date format using style codes.
-- Style code 120 is used for the yyyy-mm-dd format.
insert into weather values
(1, 'London', -1, CAST('2021-01-01'AS DATE)),
(2, 'London', -2, CONVERT(DATE,'2021-01-02',120)),
(3, 'London', 4, CONVERT(DATE,'2021-01-03',120)),
(4, 'London', 1, CONVERT(DATE,'2021-01-04',120)),
(5, 'London', -2, CONVERT(DATE,'2021-01-05',120)),
(6, 'London', -5, CAST('2021-01-06' AS DATE)),
(7, 'London', -7, CAST('2021-01-07' AS DATE)),
(8, 'London', 5, CAST('2021-01-08' AS DATE));

select * from weather;
-- LEAD()- comparing current row values with future row values
-- LAG() - comparing current row values with previous row values.
-- LEAD(temperature) fetches the value from the next row in the result set.
-- LEAD(temperature, 2) fetches the value from the row that is two rows ahead.

WITH below_zero as
(
select wt.*,
CASE 
WHEN temperature<0 and LEAD(temperature) OVER(order by day)<0 
and LEAD(temperature,2) over(order by day)<0 then 'Cold' 
WHEN temperature<0 and LAG(temperature) over(order by day)<0
and LAG(temperature,2) over(order by day)<0 then 'Cold'
WHEN temperature<0 and LEAD(temperature) over(order by day)<0
and LAG(temperature) OVER(order by day)<0 then 'Cold'
ELSE 'NA'
end as 'new_record'
from weather wt
)
select id,city,temperature,day 
from below_zero
where new_record <>'NA';

/*
select id, city, temperature, day
from (
    select *,
        case when temperature < 0
              and lead(temperature) over(order by day) < 0
              and lead(temperature,2) over(order by day) < 0
        then 'Y'
        when temperature < 0
              and lead(temperature) over(order by day) < 0
              and lag(temperature) over(order by day) < 0
        then 'Y'
        when temperature < 0
              and lag(temperature) over(order by day) < 0
              and lag(temperature,2) over(order by day) < 0
        then 'Y'
        end as flag
    from weather) x
where x.flag = 'Y';*/

-- Q8 From the following 3 tables (event_category, physician_speciality, patient_treatment),
-- write a SQL query to get the histogram of specialities of the unique physicians
-- who have done the procedures but never did prescribe anything.
drop table IF EXISTS event_category;
create table event_category
(
  event_name varchar(50),
  category varchar(100)
);

drop table IF EXISTS physician_speciality;
create table physician_speciality
(
  physician_id int,
  speciality varchar(50)
);

drop table IF EXISTS patient_treatment;
create table patient_treatment
(
  patient_id int,
  event_name varchar(50),
  physician_id int
);


insert into event_category values ('Chemotherapy','Procedure');
insert into event_category values ('Radiation','Procedure');
insert into event_category values ('Immunosuppressants','Prescription');
insert into event_category values ('BTKI','Prescription');
insert into event_category values ('Biopsy','Test');


insert into physician_speciality values (1000,'Radiologist');
insert into physician_speciality values (2000,'Oncologist');
insert into physician_speciality values (3000,'Hermatologist');
insert into physician_speciality values (4000,'Oncologist');
insert into physician_speciality values (5000,'Pathologist');
insert into physician_speciality values (6000,'Oncologist');


insert into patient_treatment values (1,'Radiation', 1000);
insert into patient_treatment values (2,'Chemotherapy', 2000);
insert into patient_treatment values (1,'Biopsy', 1000);
insert into patient_treatment values (3,'Immunosuppressants', 2000);
insert into patient_treatment values (4,'BTKI', 3000);
insert into patient_treatment values (5,'Radiation', 4000);
insert into patient_treatment values (4,'Chemotherapy', 2000);
insert into patient_treatment values (1,'Biopsy', 5000);
insert into patient_treatment values (6,'Chemotherapy', 6000);


select * from patient_treatment;
select * from event_category;
select * from physician_speciality;

SELECT *
FROM patient_treatment
where physician_id=2000;

-- query below includes physician_id 2000 who also did prescription 
SELECT distinct ps.physician_id,ps.speciality
FROM physician_speciality ps
JOIN (
select ec.event_name,ec.category,pt.physician_id
from event_category ec
join patient_treatment pt
on ec.event_name=pt.event_name
where ec.category='Procedure') subq1
ON ps.physician_id=subq1.physician_id;

select ps.physician_id
from patient_treatment pt
JOIN physician_speciality ps
ON pt.physician_id=ps.physician_id
JOIN event_category ec
ON pt.event_name=ec.event_name
where ec.category='Procedure'
EXCEPT
select pt.physician_id
from event_category ec
join patient_treatment pt
on ec.event_name=pt.event_name
where ec.category='Prescription';

select ps.speciality,COUNT(ps.speciality) AS specialist_count
from patient_treatment pt
JOIN physician_speciality ps
ON pt.physician_id=ps.physician_id
JOIN event_category ec
ON pt.event_name=ec.event_name
where ec.category='Procedure' and ps.physician_id NOT IN
(
select pt.physician_id
from event_category ec
join patient_treatment pt
on ec.event_name=pt.event_name
where ec.category='Prescription')
GROUP BY ps.speciality;
/*
select ps.speciality, count(1) as speciality_count
from patient_treatment pt
join event_category ec on ec.event_name = pt.event_name
join physician_speciality ps on ps.physician_id = pt.physician_id
where ec.category = 'Procedure'
and pt.physician_id not in (select pt2.physician_id
							from patient_treatment pt2
							join event_category ec on ec.event_name = pt2.event_name
							where ec.category in ('Prescription'))
group by ps.speciality;*/

-- Q9 Find the top 2 accounts with the maximum number of unique patients on a monthly basis.
-- Note:Prefer the account if with the least value in case of same number of unique patients
-- CAST() follows yyyy-mm-dd format only
/*Style code for date formats
101: mm/dd/yyyy
103: dd/mm/yyyy
104: dd.mm.yyyy
105: dd-mm-yyyy
106: dd mon yyyy
110: mm-dd-yyyy
111: yyyy/mm/dd
120: yyyy-mm-dd
*/
WITH top_selec as(
SELECT 
COUNT(DISTINCT patient_id) AS patient_cnt,
account_id,
DATENAME(MONTH,date) AS month_of_yr FROM patient_logs
GROUP BY DATENAME(MONTH,date),account_id)
SELECT month_of_yr,account_id,patient_cnt,DENSE_RANK() OVER(PARTITION BY month_of_yr ORDER BY patient_cnt DESC) AS drank
FROM top_selec;

SELECT month_of_yr,account_id,patient_cnt,ROW_NUMBER() OVER(PARTITION BY month_of_yr ORDER BY patient_cnt DESC) AS row_num
FROM(
SELECT 
COUNT(DISTINCT patient_id) AS patient_cnt,
account_id,
DATENAME(MONTH,date) AS month_of_yr FROM patient_logs
GROUP BY DATENAME(MONTH,date),account_id
)subq1;

select a.month_name, a.account_id, a.no_of_unique_patients,rn
from (
select x.month_name, x.account_id, no_of_unique_patients,
row_number() over (partition by x.month_name order by x.no_of_unique_patients desc) as rn
from (select pl.month_name, pl.account_id, count(1) as no_of_unique_patients
from (select distinct DATENAME(month,date) as month_name, account_id, patient_id
from patient_logs) pl
group by pl.month_name, pl.account_id) x
) a
where rn<3;

select *
from patient_logs
where account_id=3;

EXEC sp_help 'patient_logs';
drop table IF EXISTS patient_logs;
create table patient_logs
(
  account_id int,
  date date,
  patient_id int
);

insert into patient_logs values (1, CONVERT(DATE,'02-01-2020',105), 100);
insert into patient_logs values (1, CONVERT(DATE,'27-01-2020',105), 200);
insert into patient_logs values (2, CONVERT(DATE,'01-01-2020',105), 300);
insert into patient_logs values (2, CONVERT(DATE,'21-01-2020',105), 400);
insert into patient_logs values (2, CONVERT(DATE,'21-01-2020',105), 300);
insert into patient_logs values (2, CONVERT(DATE,'01-01-2020',105), 500);
insert into patient_logs values (3, CONVERT(DATE,'20-01-2020',105), 400);
insert into patient_logs values (1, CONVERT(DATE,'04-03-2020',105), 500);
insert into patient_logs values (3, CONVERT(DATE,'20-01-2020',105), 450);

select * from patient_logs;
TRUNCATE TABLE patient_logs;
-- Q10 SQL Query to fetch “N” consecutive records from a table based on a certain condition
-- Scenarios
/*a.when the table has a primary key(Table-weather)
b.When table does not have a primary key(Table- VW weather)
c.Query logic based on data field(Table-Orders)*/
-- Query 10a
-- Finding n consecutive records where temperature is below zero. And table has a primary key.

drop table if exists weather cascade;
create table weather
	(
		id 	int primary key,
		city varchar(50) not null,
		temperature int not null,
		day date not null
	);

delete from weather;
insert into weather values
	(1, 'London', -1, CAST('2021-01-01' as DATE)),
	(2, 'London', -2, CAST('2021-01-02'as DATE)),
	(3, 'London', 4, CAST('2021-01-03'as DATE)),
	(4, 'London', 1, CAST('2021-01-04'as DATE)),
	(5, 'London', -2, CAST('2021-01-05'as DATE)),
	(6, 'London', -5, CAST('2021-01-06'as DATE)),
	(7, 'London', -7, CAST('2021-01-07'as DATE)),
	(8, 'London', 5, CAST('2021-01-08'as DATE)),
	(9, 'London', -20, CAST('2021-01-09'as DATE)),
	(10, 'London', 20, CAST('2021-01-10'as DATE)),
	(11, 'London', 22, CAST('2021-01-11'as DATE)),
	(12, 'London', -1, CAST('2021-01-12'as DATE)),
	(13, 'London', -2, CAST('2021-01-13'as DATE)),
	(14, 'London', -2, CAST('2021-01-14'as DATE)),
	(15, 'London', -4, CAST('2021-01-15'as DATE)),
	(16, 'London', -9, CAST('2021-01-16'as DATE)),
	(17, 'London', 0, CAST('2021-01-17'as DATE)),
	(18, 'London', -10, CAST('2021-01-18'as DATE)),
	(19, 'London', -11, CAST('2021-01-19'as DATE)),
	(20, 'London', -12, CAST('2021-01-20'as DATE)),
	(21, 'London', -11, CAST('2021-01-21'as DATE));
COMMIT;

select * from weather;

WITH
	t1 as
		(select *,	id - row_number() over (order by id) as diff
		from weather w
		where w.temperature < 0),
	t2 as
		(select *,
		count(*) over (partition by diff order by diff) as cnt
		from t1)
select id, city, temperature, day
from t2
where t2.cnt = 3;

-- Query 10b
-- Finding n consecutive records where temperature is below zero. And table does not have primary key.

create or replace view vw_weather as
select city, temperature from weather;
select * from vw_weather ;
with
	w as
		(select *, row_number() over () as id
		from vw_weather),
	t1 as
		(select *,	id - row_number() over (order by id) as diff
		from w
		where w.temperature < 0),
	t2 as
		(select *,
		count(*) over (partition by diff order by diff) as cnt
		from t1)
select city, temperature, id
from t2
where t2.cnt = 5;

-- Query 10c
-- Finding n consecutive records with consecutive date value.

drop table if exists orders cascade;
create table orders
  (
    order_id varchar(20) primary key,
    order_date date not null
);

delete from orders;
insert into orders values
  ('ORD1001', CAST('2021-Jan-01' AS DATE)),
  ('ORD1002', CAST('2021-Feb-01'AS DATE)),
  ('ORD1003', CAST('2021-Feb-02'AS DATE)),
  ('ORD1004', CAST('2021-Feb-03'AS DATE)),
  ('ORD1005', CAST('2021-Mar-01'AS DATE)),
  ('ORD1006', CAST('2021-Jun-01'AS DATE)),
  ('ORD1007', CAST('2021-Dec-25'AS DATE)),
  ('ORD1008', CAST('2021-Dec-26'AS DATE));
COMMIT;
select * from orders;

WITH
  t1 as
		(select *, row_number() over(order by order_date) as rn,
		 order_date - cast(row_number() over(order by order_date)::numeric as int) as diff
		from orders),
	t2 as
		(select *, count(1) over (partition by diff) as cnt
		from t1)
select order_id, order_date
from t2
where cnt >= 3;

-- Null vs empty string vs blank space
-- dirty data
WITH orders as
(
SELECT 1 id,'A' Category UNION
SELECT 2,NULL UNION
SELECT 3,'' UNION
SELECT 4,'   '
)
SELECT *,
DATALENGTH(Category) Categorylen
FROM orders;

-- Data policy
--1.Only use nulls and empty strings,AVOID blank spaces-TRIM()
WITH orders as
(
SELECT 1 id,'A' Category UNION
SELECT 2,NULL UNION
SELECT 3,'' UNION
SELECT 4,'   '
)
SELECT *,
DATALENGTH(Category) Categorylen,
TRIM(Category) Policy1,
DATALENGTH(TRIM(Category)) updatedcat
FROM orders;

--2.Only use NULL and avoid empty strings and blank spaces-NULLIF()
WITH orders as
(
SELECT 1 id,'A' Category UNION
SELECT 2,NULL UNION
SELECT 3,'' UNION
SELECT 4,'   '
)
SELECT *,
TRIM(Category) Policy1,
NULLIF(TRIM(Category),'') Policy2
FROM orders;

--3.Use the default value 'unknown' and avoid using
-- nulls,empty strings and blank spaces-use either ISNULL() or COALESCE()
-- convert everything to NULL then replace null with unknown
WITH orders as
(
SELECT 1 id,'A' Category UNION
SELECT 2,NULL UNION
SELECT 3,'' UNION
SELECT 4,'   '
)
SELECT *,
TRIM(Category) Policy1,
NULLIF(TRIM(Category),'') Policy2,
COALESCE(NULLIF(TRIM(Category),''),'unknown') Policy3
FROM orders;