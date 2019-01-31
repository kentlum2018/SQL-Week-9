use sakila;
-- 1a. Display the first and last names of all actors from the table `actor`.
SELECT 
    *
FROM
    actor;
-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT CONCAT(first_name, ' ' , last_name) AS 'Actor Name'
FROM actor;


-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select * from actor where first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters `GEN`
select * from actor where last_name like "%GEN%";
-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:

select * from actor where last_name like "%LI%" order by last_name, first_name asc;

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
select * from country where country in ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description,
-- so create a column in the table `actor` named `description` and use the data type `BLOB` 
-- (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
alter table actor
add column description mediumblob;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
alter table actor 
drop column description;


-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name, COUNT(last_name) as "CNT"
from actor
group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name, COUNT(last_name) as "CNT"
from actor
group by last_name
having Count(last_name) >1;

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
update actor
set first_name = 'HARPO' 
where first_name = 'groucho' and last_name = 'williams';

--  4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! 
-- In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
update actor
set first_name = 'GROUCHO' 
where first_name = 'harpo' and last_name = 'williams';

-- 5a
show create table address;

-- 6a join by key address_id DOUBLE CHECK only 2 rows returned
select first_name, last_name 
from staff
join address
using (address_id);


-- 6b
select * from payment;

-- select * from payment where payment_date like 2005-08-%;

select first_name, last_name, sum(amount) as 'Total' 
from staff
join payment
using (staff_id)
where payment_date like ('2005-08-%')
group by (staff_id);

-- 6c

select title, COUNT(actor_id) as 'Actor Cnt'
from film_actor
join film
using (film_id)
group by (title);

-- 6d use the id from the film table and query inventory directly
select title, COUNT(title) as 'CNT'
from film
join inventory 
on film.film_id = inventory.film_id
where title like '%Hunchback Impossible%';
 
-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
select last_name, first_name, sum(amount) as 'Total'
from customer c
join payment p
on p.customer_id = c.customer_id
group by last_name
order by last_name, first_name asc;

-- 7a. films starting with the letters `K` and `Q` 
-- have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.

select title 
from film 
where title 
like ('K%') or title like ('Q%') and language_id in
(
select language_id
from language
where name =('English')
);
-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
select last_name, first_name
from actor
where actor_id in
(select actor_id 
from film_actor
where film_id in
(
select film_id
from film
where title = 'Alone Trip'
)
);
-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.
-- select first_name, last_name, email
-- from customer c
-- join address a
-- using (address_id);

select c.first_name, c.last_name, c.email, co.country
from customer c 
    inner join address a on c.address_id = a.address_id
    inner join city cy on a.city_id= cy.city_id
    inner join country co on cy.country_id=co.country_id
where co.country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.
-- select * from category; name needs to be family
select f.title, ca.name
from film f 
    inner join film_category fc on f.film_id = fc.film_id
    inner join category ca on fc.category_id = ca.category_id
where ca.name = 'Family';

-- 7e. Display the most frequently rented movies in descending order.
select f.title, COUNT(r.inventory_id) as "cnt"
from film f 
    inner join inventory i on i.film_id = f.film_id
    inner join rental r on i.inventory_id = r.inventory_id
group by f.title
order by COUNT(r.inventory_id) desc;
-- select * from film;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select store, concat('$', FORMAT(total_sales,2)) as "dollars" from sales_by_store;
-- 7g. Write a query to display for each store its store ID, city, and country.
-- select * from store; -- has store ID and address ID
-- select * from staff;-- has  staff names
-- select * from staff_list;
-- select * from sales_by_store;
-- select *from address;-- need store to address to city to country 

select store_id, city, country 
from store s
    inner join address a on s.address_id = a.address_id
    inner join city cy on a.city_id = cy.city_id
    inner join country co on co.country_id = cy.country_id
group by country;

-- 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select name, sum(amount) as 'gross revenue'
from category c
    inner join film_category fc on c.category_id = fc.category_id
    inner join inventory i on fc.film_id = i.film_id
    inner join rental r on i.inventory_id = r.inventory_id
    inner join payment p on r.rental_id = p.rental_id
group by (c.name)
order by sum(amount) desc
limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
create or replace view Top as
select name, sum(amount) as 'gross revenue'
from category c
    inner join film_category fc on c.category_id = fc.category_id
    inner join inventory i on fc.film_id = i.film_id
    inner join rental r on i.inventory_id = r.inventory_id
    inner join payment p on r.rental_id = p.rental_id
group by (c.name)
order by sum(amount) desc
limit 5;

-- 8b. How would you display the view that you created in 8a?
select * from Top;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
drop view Top;

