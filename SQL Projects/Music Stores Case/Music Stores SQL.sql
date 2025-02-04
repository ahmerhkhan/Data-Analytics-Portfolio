select * from album;
select * from artist;
select * from customer;
select * from employee;
select * from genre;
select * from invoice;
select * from invoice_line;
select * from media_type;
select * from playlist;
select * from playlist_track;
select * from track;

-- Question Set 1 - Easy
--1. Who is the senior most employee based on job title?
select *
from employee
order by levels desc
limit 1;

--2. Which countries have the most Invoices?
select billing_country,count(billing_country) as total_invoices
from invoice
group by billing_country
order by 2 desc
limit 5;

-- 3. What are top 3 values of total invoice?
select invoice_id,cast(total as numeric)
from invoice
order by total desc
limit 3;


--4. Which city has the best customers? We would like to throw a promotional Music
--Festival in the city we made the most money. Write a query that returns one city that
--has the highest sum of invoice totals. Return both the city name & sum of all invoice
--totals
select *
from invoice;

select billing_city,cast(sum(total) as numeric) as invoice_total
from invoice
group by billing_city
order by 2 desc;

--5. Who is the best customer? The customer who has spent the most money will be
-- declared the best customer. Write a query that returns the person who has spent the
-- most money'
select i.customer_id,c.first_name,c.last_name,cast(sum(total)as numeric) as money_spent
from invoice i
join customer c on c.customer_id=i.customer_id
group by i.customer_id,c.first_name,c.last_name
order by money_spent desc
limit 1;

-- Question Set 2 – Moderate
-- 1. Write query to return the email, first name, last name, & Genre of all Rock Music
-- listeners. Return your list ordered alphabetically by email starting with A
-- select email,first_name,last_name from customer;
-- select name from genre g join track t on t.genre_id=g.genre_id

select distinct c.email,c.first_name,c.last_name,g.name as genre
from customer c
join invoice i on c.customer_id=i.customer_id
join invoice_line il on il.invoice_id=i.invoice_id
join track t on t.track_id=il.track_id
join genre g on g.genre_id=t.genre_id
where lower(g.name) like '%rock%'
order by email asc;


--2. Let's invite the artists who have written the most rock music in our dataset. Write a
--query that returns the Artist name and total track count of the top 10 rock bands
select *
from artist;

select ar.name,count(t.album_id) as total_track_count
from track t
join album a on a.album_id=t.album_id
join artist ar on ar.artist_id=a.artist_id
where genre_id in (select genre_id
					from genre g
					where lower(g.name) like '%rock%')
group by ar.name
order by count(t.album_id) desc
limit 10;


--3. Return all the track names that have a song length longer than the average song length.
--Return the Name and Milliseconds for each track. Order by the song length with the
--longest songs listed first
select *
from track;

select name,milliseconds,avg(milliseconds) over() as average_length
from track
where milliseconds> 
					(select avg(milliseconds) 
					from track)
order by milliseconds desc


--Question Set 3 – Advance
--1. Find how much amount spent by each customer on artists? Write a query to return
--customer name, artist name and total spent

select c.customer_id,c.first_name,c.last_name,ar.name,
cast(sum(il.unit_price * il.quantity) as numeric) as amount_spent
from invoice_line il
join invoice i on il.invoice_id=i.invoice_id
join customer c on c.customer_id=i.customer_id
join track t on t.track_id=il.track_id
join album a on a.album_id=t.album_id
join artist ar on ar.artist_id=a.artist_id
group by c.customer_id,c.first_name,c.last_name,ar.name
order by customer_id asc;


--2. We want to find out the most popular music Genre for each country. We determine the
--most popular genre as the genre with the highest amount of purchases. Write a query
--that returns each country along with the top Genre. For countries where the maximum
--number of purchases is shared return all Genres


join invoice i on c.customer_id=i.customer_id
join invoice_line il on il.invoice_id=i.invoice_id;

with purchases as(
select c.country,g.name,count(g.genre_id) as purchases,
row_number() over(partition by c.country order by count(g.genre_id) desc) as RowNo
from customer c
join invoice i on i.customer_id=c.customer_id
join invoice_line il on i.invoice_id=il.invoice_id
join track t on t.track_id=il.track_id
join genre g on g.genre_id=t.genre_id
group by c.country,g.name
)
select country,name,purchases
from purchases
where rowno<2;


--3. Write a query that determines the customer that has spent the most on music 
--for each country. Write a query that returns the country along with the top 
--customer and how much they spent. For countries where the top amount spent is 
--shared, provide all customers who spent this amount.

with sales_per_country as (
select c.country,c.first_name,c.last_name,
sum(il.unit_price * il.quantity) as amount_spent,
row_number() over(partition by c.country order by sum(il.unit_price * il.quantity)) as rn
from invoice_line il
join invoice i on il.invoice_id=i.invoice_id
join customer c on c.customer_id=i.customer_id
group by c.customer_id,c.first_name,c.last_name
order by country
)
select *
from sales_per_country
where rn<2;

