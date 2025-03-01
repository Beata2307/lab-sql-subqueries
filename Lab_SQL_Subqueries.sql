/*
1. Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.
2. List all films whose length is longer than the average length of all the films in the Sakila database.
3. Use a subquery to display all actors who appear in the film "Alone Trip".
*/

-- 1. Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.

select movie.film_id, movie.title, count(*) as nr_of_copies
from (
	select film_id, title 
    from film 
    where title = "Hunchback Impossible"
    ) as movie
inner join inventory as inv
	on movie.film_id = inv.film_id
group by movie.film_id, movie.title;
    
-- 2. List all films whose length is longer than the average length of all the films in the Sakila database.
select avg(length) from film;

select film_id, length, title
from film
where length > (select avg(length) from film);

-- 3. Use a subquery to display all actors who appear in the film "Alone Trip".

select concat(ac.first_name, " ", ac.last_name) as Actor_names
from (
	select film_id, title 
	from film
	where title = 'ALONE TRIP') as alt
inner join film_actor as fa
	on alt.film_id = fa.film_id
inner join actor as ac
	on fa.actor_id = ac.actor_id ;
    
/* Bonus: */
-- 4. Sales have been lagging among young families, and you want to target family movies for a promotion. 
-- Identify all movies categorized as family films.

select film.film_id, film.title, cat.name as movie_category
from film
inner join film_category as fcat
	using (film_id)
inner join (
	select category_id, name
    from category 
    where name = 'Family') as cat
	on fcat.category_id = cat.category_id;

-- 5. Retrieve the name and email of customers from Canada using both subqueries and joins. To use joins, you will need to identify the relevant tables and their primary and foreign keys.

select concat(first_name, ' ', last_name) as name, email, cc.country as Country
from customer
inner join ( 
	select address.address_id, address.city_id, c.city, co.country_id, co.country
	from address
    inner join city as c
		on address.city_id = c.city_id
	inner join country as co
		on c.country_id = co.country_id
	where co.country = 'Canada') as cc
    on customer.address_id = cc.address_id;

-- 6. Determine which films were starred by the most prolific actor in the Sakila database. A prolific actor is defined as the actor who has acted in the most number of films. 
-- First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or she starred in.

select fa.actor_id, count_roles, fa.film_id, f.title
from (
	select actor_id, count(*) as count_roles
	from film_actor
	group by actor_id
	having count_roles = (
		select max(cnt_roles) 
        from ( 
			select actor_id, count(actor_id) as cnt_roles
			from film_actor
			group by actor_id) as roles)
) as max_actor
inner join film_actor as fa
	on max_actor.actor_id = fa.actor_id
inner join film as f
	on fa.film_id = f.film_id;
    
-- 7. Find the films rented by the most profitable customer in the Sakila database. 
-- You can use the customer and payment tables to find the most profitable customer, i.e., the customer who has made the largest sum of payments.

select distinct tab.first_name, tab.last_name, tab.total, f.film_id, f.title 
from 
(
	select p.customer_id, c.first_name, c.last_name, sum(amount) as total
	from payment as p
	inner join customer as c
		on p.customer_id = c.customer_id
	group by customer_id
	having total = (select max(total) 
					from (
						select customer_id, sum(amount) as total
						from payment
						group by customer_id
						) as max_tot
					)
) as tab
inner join rental as r
	on tab.customer_id = r.customer_id
inner join inventory as inv
	on r.inventory_id = inv.inventory_id
inner join film as f
	on inv.film_id = f.film_id;

-- 8. Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client.
-- You can use subqueries to accomplish this.

select customer_id, sum(amount) as total_amount_spent
from payment
group by customer_id 
having total_amount_spent > (select avg(tot_amount) 
							from (
								select customer_id, sum(amount) as tot_amount
								from payment
								group by customer_id
                                ) as avg_amount
                            );	