select * from album
--Q1: Who is the senior most employee based on job title? */
select top 1 * from [dbo].[employee] order by levels desc
--/* Q2: Which countries have the most Invoices? */
select max(billing_state) as country from invoice 
select * from invoice where billing_country=(select max(billing_country) as country from invoice )
or
select count(*),billing_country from invoice group by billing_country order by count(*) desc
--/* Q3: What are top 3 values of total invoice? */
select top 3 * from invoice order by total
--/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
--Write a query that returns one city that has the highest sum of invoice totals. 
--Return both the city name & sum of all invoice totals */
select * from invoice
select top 1 sum(total) as invoice_total,billing_city from invoice 
group by billing_city 
order by invoice_total desc
/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/
select * from customer
select * from invoice
select top 1 c.customer_id,c.first_name,c.last_name,sum(i.total)as total_invoice
from customer as c
join
invoice as i on c.customer_id=i.customer_id
group by c.customer_id,c.first_name,c.last_name
order  by total_invoice

select top 1 c.customer_id,c.(first_name+last_name) as name ,sum(i.total)as total_invoice
from customer as c
join
invoice as i on c.customer_id=i.customer_id
group by c.customer_id,name
order  by total_invoice
--/* Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */
select * from customer
select * from album where title =Rock Music
select * from[dbo].[artist]
select distinct c.email,c.first_name,c.last_name,g.name
from customer as c 
join invoice as i on c.customer_id=i.customer_id
join invoice_line as l on i.invoice_id=l.invoice_id
join track as t on l.track_id=t.track_id
join genre as g on t.genre_id=g.genre_id
where g.name like 'Rock'
order by c.email 
--/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
--Write a query that returns the Artist name and total track count of the top 10 rock bands. */
select * from artist
select  distinct top 10 a.name as artist_name,count(a.artist_id) as total_track_count,g.name
from artist as a
join album as al on a.artist_id=al.artist_id
join track as t on t.album_id= al .album_id
join genre as g on t.genre_id=g.genre_id
where g.name like 'Rock'
group by a.name,g.name
order by total_track_count desc
--/* Q3: Return all the track names that have a song length longer than the average song length. 
--Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */--
select * from track
select name, milliseconds from track where milliseconds >(select AVG(milliseconds)from track)
order by milliseconds desc

--/* Question Set 3 - Advance */



-- We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
--with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
--the maximum number of purchases is shared return all Genres. */

/* Steps to Solve:  There are two parts in question- first most popular music genre and second need data at country level. */

/* Method 1: Using CTE */
with popular_music as (
	select i.billing_country, count(l.quantity)as purchase,g.name,g.genre_id,
	ROW_NUMBER() over(partition by i.billing_country order by count(l.quantity) desc ) as row
	from invoice as i
	join invoice_line as l on i.invoice_id=l.invoice_id
	join track as t on t.track_id=l.track_id
	join genre as g on t.genre_id=g.genre_id
	group by i.billing_country, g.name,g.genre_id
)

select * from popular_music where  row <=1

/* Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

/* Steps to Solve:  Similar to the above question. There are two parts in question- 
first find the most spent on music for each country and second filter the data for respective customers. */

/* Method 1: using CTE */

WITH country_wise as (
	select c.customer_id,c.first_name,c.last_name,i.billing_country, sum(i.total)as total_spend,
	ROW_NUMBER() over(partition by i.billing_country order by sum(i.total) desc) as rowno  ---
	from  invoice as i 
	join   customer as c on c.customer_id=i.customer_id
	group by c.customer_id,c.first_name,c.last_name,i.billing_country)
	
select* from country_wise where rowno<=1 --highest time spend by that contry

