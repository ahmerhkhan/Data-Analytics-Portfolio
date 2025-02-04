CREATE TABLE retail_sales
            (
                transaction_id INT PRIMARY KEY,	
                sale_date DATE,	 
                sale_time TIME,	
                customer_id	INT,
                gender	VARCHAR(15),
                age	INT,
                category VARCHAR(15),	
                quantity	INT,
                price_per_unit FLOAT,	
                cogs	FLOAT,
                total_sale FLOAT
            );

select *
from retail_sales;

-- DATA CLEANING
--1. Total Rows
select count(*)
from retail_sales;

-- 2. Checking discrepancies in categorical data.
select gender
from retail_sales
group by gender;

select  category
from retail_sales
group by category;

-- 3. Checking unique values
select count(distinct customer_id)
from retail_sales;

-- 4. Null values, deleting records with null values
select *
from retail_sales
where sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR age IS NULL OR category IS NULL OR 
    quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL;

delete from retail_sales
where sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR age IS NULL OR category IS NULL OR 
    quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL;


-- DATA ANALYSIS
-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05
select *
from retail_sales
where sale_date= '2022-11-05'

-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022
select *
from retail_sales 
where category='Clothing' and quantity>=4 and to_char(sale_date, 'YYYY-MM') = '2022-11';

-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
select category,sum(total_sale),count(*) as total_orders
from retail_sales
group by category;

-- Q.4 Write a SQL query to calculate the average price of products sold by category.
select category,round((cast(avg(total_sale) as numeric)),2) as average_price
from retail_sales
group by category;

-- Q.5 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
select avg(age)
from retail_sales
where category='Beauty';

-- Q.6 Write a SQL query to find all transactions where the total_sale is greater than 1000.
select *
from retail_sales
where total_sale >1000;


-- Q.7 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
select category,gender,count(transaction_id)
from retail_sales
group by 1,2
order by 1,2;

with cte as (
select extract (year from sale_date)as year, extract(month from sale_date) as month,avg(total_sale) as avg_sale,
rank() over(partition by extract(year from sale_date) order by avg(totaL_sale)desc) as rank
from retail_sales
group by 1,2
)
select year,month,avg_sale,rank
from cte
where rank=1;


-- Q.9 Write a SQL query to find the top 5 customers based on the highest total sales 

select customer_id,sum(total_sale)
from retail_sales
group by customer_id
order by sum(total_sale) desc
limit 5;

-- Q.10 Write a SQL query to find the number of unique customers who purchased items from each category.

select count(distinct customer_id),category
from retail_sales
group by category;

-- Q.11 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)
with shifts as(
select case when extract(hour from sale_time)<=12 then 'Morning'
when extract(hour from sale_time)>=17 then 'Evening'
else 'Afternoon' end as shift
from retail_sales
)
select shift,count(*)
from shifts
group by shift;