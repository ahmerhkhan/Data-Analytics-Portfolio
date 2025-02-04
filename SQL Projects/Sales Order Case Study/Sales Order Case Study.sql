create table products
(
	id				int generated always as identity primary key,
	name			varchar(100),
	price			float,
	release_date 	date
);
insert into products values(default,'iPhone 15', 800, to_date('22-08-2023','dd-mm-yyyy'));
insert into products values(default,'Macbook Pro', 2100, to_date('12-10-2022','dd-mm-yyyy'));
insert into products values(default,'Apple Watch 9', 550, to_date('04-09-2022','dd-mm-yyyy'));
insert into products values(default,'iPad', 400, to_date('25-08-2020','dd-mm-yyyy'));
insert into products values(default,'AirPods', 420, to_date('30-03-2024','dd-mm-yyyy'));


drop table if exists customers;
create table customers
(
    id         int generated always as identity primary key,
    name       varchar(100),
    email      varchar(30)
);
insert into customers values(default,'Meghan Harley', 'mharley@demo.com');
insert into customers values(default,'Rosa Chan', 'rchan@demo.com');
insert into customers values(default,'Logan Short', 'lshort@demo.com');
insert into customers values(default,'Zaria Duke', 'zduke@demo.com');


drop table if exists employees;
create table employees
(
    id         int generated always as identity primary key,
    name       varchar(100)
);
insert into employees values(default,'Nina Kumari');
insert into employees values(default,'Abrar Khan');
insert into employees values(default,'Irene Costa');



drop table if exists sales_order;
create table sales_order
(
	order_id		int generated always as identity primary key,
	order_date		date,
	quantity		int,
	prod_id			int references products(id),
	status			varchar(20),
	customer_id		int references customers(id),
	emp_id			int,
	constraint fk_so_emp foreign key (emp_id) references employees(id)
);
insert into sales_order values(default,to_date('01-01-2024','dd-mm-yyyy'),2,1,'Completed',1,1);
insert into sales_order values(default,to_date('01-01-2024','dd-mm-yyyy'),3,1,'Pending',2,2);
insert into sales_order values(default,to_date('02-01-2024','dd-mm-yyyy'),3,2,'Completed',3,2);
insert into sales_order values(default,to_date('03-01-2024','dd-mm-yyyy'),3,3,'Completed',3,2);
insert into sales_order values(default,to_date('04-01-2024','dd-mm-yyyy'),1,1,'Completed',3,2);
insert into sales_order values(default,to_date('04-01-2024','dd-mm-yyyy'),1,3,'Completed',2,1);
insert into sales_order values(default,to_date('04-01-2024','dd-mm-yyyy'),1,2,'On Hold',2,1);
insert into sales_order values(default,to_date('05-01-2024','dd-mm-yyyy'),4,2,'Rejected',1,2);
insert into sales_order values(default,to_date('06-01-2024','dd-mm-yyyy'),5,5,'Completed',1,2);
insert into sales_order values(default,to_date('06-01-2024','dd-mm-yyyy'),1,1,'Cancelled',1,1);


SELECT * FROM products;
SELECT * FROM customers;
SELECT * FROM employees;
SELECT * FROM sales_order;


-- Q1. Identify the total no of products sold
select sum(quantity) as total_products_sold
from sales_order;

 -- Q2. Other than Completed, display the available delivery status's
select status
from sales_order
where status != 'Completed';

-- Q3. Display the order id, order_date and product_name for all the completed orders.
 select so.order_id,so.order_date,p.name
 from sales_order so
 join products p on p.id=so.prod_id
 where status='Completed';
 
-- Q4. Sort the above query to show the earliest orders at the top. Also display the customer who purchased these orders.
 select so.order_id,so.order_date,p.name as product_name,c.name as customer_name
 from sales_order so
 join products p on p.id=so.prod_id
 join customers c on c.id=so.customer_id
 where status='Completed'
 order by order_date asc;
 
 -- Q5. Display the total no of orders corresponding to each delivery status
 select count(order_id) as total_orders,status
 from sales_order
 group by status;

 -- Q6. For orders purchasing more than 1 item, how many are still not completed?

select count(order_id) as total_orders
from (
select *
from sales_order
where quantity>1
) 
where status!='Completed';


-- Q7. Find the total no of orders corresponding to each delivery status by ignoring
-- the case in delivery status. Status with highest no of orders should be at the top.
select count(order_id) as total_orders,status
from sales_order
group by status
order by total_orders desc;

-- Q8. Write a query to identify the total products purchased by each customer

select c.name,so.customer_id,sum(quantity) as total_products_purchased
from sales_order so
join customers c on so.customer_id=c.id
group by so.customer_id,c.name;


-- Q9. Display the total sales and average sales done for each day.


select order_date,sum(p.price*so.quantity) as total_sales,avg(p.price*so.quantity)
from sales_order so
join products p on p.id=so.prod_id
group by order_date
order by order_date asc;

-- Q10. Display the customer name, employee name and total sale amount of all orders which are either on hold or pending.
 select c.name as customer_name,e.name as employee_name,sum(so.quantity*p.price) as total_sales
 from sales_order so
 join employees e on so.emp_id=e.id
 join customers c on so.customer_id=c.id
 join products p on p.id=so.prod_id
 group by c.name,e.name,so.status
 having status in('On Hold','Pending');



 -- Q11. Fetch all the orders which were neither completed/pending or were handled by the employee Abrar. Display employee name and all details of order.
 select e.name as employee_name,*
 from sales_order so
 join employees e on e.id=so.emp_id
 where status in ('Completed','Pending') or e.name like '%abrar%'
;

-- Q12.  Fetch the orders which cost more than 2000 but did not include the macbook pro. Print the total sale amount as well.
select (p.price*so.quantity) as total_amount,so.*
from sales_order so
join products p on p.id=so.prod_id
where p.name not like ('%macbook%') and (so.quantity*p.price>2000)
;

 -- Q13. Identify the customers who have not purchased any product yet.
 select c.id as customer_id,c.name as customer_name,so.order_id as purchased
 from customers c
 left join sales_order so on c.id=so.customer_id
 where so.order_id is null;

-- Q14. Write a query to identify the total products purchased by each customer. Return all customers irrespective of wether they have made a purchase or not. Sort the result with highest no of orders at the top.
select c.name as customer_name,coalesce(sum(so.quantity),0) as quantity
from customers c
left join sales_order so on c.id=so.customer_id
group by c.id
order by quantity desc;


--Q15. Corresponding to each employee, display the total sales they made of all the completed orders. Display total sales as 0 if an employee made no sales yet.
select e.name,coalesce(sum(p.price*so.quantity),0) as total_sales
from sales_order so
join products p on p.id=so.prod_id
right join employees e on e.id=so.emp_id and so.status='Completed'
group by e.id;

-- Q16. Re-write the above query so as to display the total sales made by each employee corresponding to each customer. If an employee has not served a customer yet then display "-" under the customer.
select e.name as employee_name,coalesce(c.name,'-') as customer_name,
coalesce(sum(p.price * so.quantity),0) as total_sales
from sales_order so
join products p on p.id=so.prod_id
join customers c on so.customer_id=c.id
right join employees e on e.id=so.emp_id and so.status='Completed'
group by c.name,e.id
order by total_sales desc;

--Q17. Re-write above query so as to display only those records where the total sales is above 1000

select e.name as employee_name,coalesce(c.name,'-') as customer_name,
coalesce(sum(p.price * so.quantity),0) as total_sales
from sales_order so
join products p on p.id=so.prod_id
join customers c on so.customer_id=c.id
right join employees e on e.id=so.emp_id and so.status='Completed'
group by c.name,e.id
having sum(p.price * so.quantity)>1000
order by total_sales desc;

--Q18. Identify employees who have served more than 2 customer.
select e.name as employee_name,count(distinct customer_id) as served_customers
from sales_order so
join employees e on e.id=so.emp_id
group by emp_id,e.name
having count(distinct customer_id)>2;


-- Q19. Identify the customers who have purchased more than 5 products
select c.name as customer_name, sum(so.quantity) as total_products
from customers c
join sales_order so on c.id=so.customer_id
group by c.name
having sum(so.quantity)>5;


-- Q20. Identify customers whose average purchase cost exceeds the average sale of all the orders.
select c.name as customer_name, avg(so.quantity * p.price)as avg_purchase_cost
from customers c
join sales_order so on so.customer_id=c.id
join products p on p.id=so.prod_id
group by c.name
having avg(so.quantity*p.price)>
(select avg(p.price*so.quantity)
from sales_order so
join products p on p.id=so.prod_id);