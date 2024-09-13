-- Netflix Project 
DROP TABLE IF EXISTS netflix;

CREATE TABLE netflix
(
show_id VARCHAR(10) PRIMARY KEY,
type VARCHAR(150),
title VARCHAR(150),
director VARCHAR(220),
casts VARCHAR(1000),
country	VARCHAR(150),
date_added VARCHAR(30),
release_year INT,
rating VARCHAR(30),
duration VARCHAR(30),
listed_in VARCHAR(100),
description VARCHAR(250)
);

-- see table 
SELECT * FROM netflix;

-- create a new table 
select * from netflix 
;
create table netflix_new as
select show_id, type, title, date_added,release_year,rating,duration, description
from netflix ;

select * from netflix_new;

-- data-type conversion of date column 

ALTER TABLE netflix_new
ALTER COLUMN date_added TYPE DATE
USING to_date(date_added, 'Month DD, YYYY');

select date_added from netflix_new

-- Total number of rows

SELECT COUNT(*) FROM netflix;

-- handling duplicates if any
SELECT title, COUNT(*)
FROM netflix 
GROUP BY title
HAVING COUNT(*)>1
;

SELECT show_id, COUNT(*)
FROM netflix 
GROUP BY show_id
HAVING COUNT(*)>1
;
-- types of format

SELECT type 
FROM netflix
GROUP BY type;

-- new table for director names

create table netflix_director as 
select show_id, trim(unnest(string_to_array(director,','))) as director
from netflix;

select * from netflix_director;

-- new table for listed_in 
create table netflix_listed_in as 
select show_id , trim(unnest(string_to_array(listed_in,','))) as listed_in
from netflix;

select * from netflix_listed_in;

-- new table for country
create table netflix_country as
select show_id, trim(unnest(string_to_array(country,','))) as country
from netflix

select * from netflix_country;


-- new table for cast
create table netflix_cast as 
select show_id, trim(unnest(string_to_array(casts,','))) as casts
from netflix;

select * from netflix_cast;

-- impute the null values in country column
select show_id, country from netflix 
where country is null;


-- Handling null values in duration column
select * from netflix 
where duration is null;
		--we can observe that the rating column has duration which
		---needs to be inserted back to duration column 

/*1 for each director count the number of movies and tv shows created by them in separate columns
for airectors who have created tv shows and movies both */

select nd.director, 
count(distinct case when n.type = 'Movie' then n.show_id end) as no_of_movies,
count(distinct case when n.type = 'TV Show'  then n.show_id end) as np_of_tvshows
from netflix_new n
inner join netflix_director nd
on n.show_id = nd.show_id
group by nd.director
having count(distinct n.type ) > 1;


/*2 for each year which director has the maximum number of movies released on netflix */
with cte as (
select nd.director, extract(year from n.date_added) as date_year, count(n.show_id) as number_shows from netflix_new n
inner join netflix_director nd
on n.show_id = nd.show_id
where type = 'Movie'
group by nd.director, date_year
order by date_year asc)
,cte2 as(
select *, row_number()over(partition by date_year order by number_shows desc, director) as rn
from cte 
)
select * from cte2 where rn =1;

/*3 what is the average duration of all the Movies */

select avg(cast(replace(duration,'min','') as int)) as avg_duration_int
from netflix_new 
where type = 'Movie';


/*4 Count the number of Movies vs TV shows */

select type, count(*) as total_content
from netflix_new 
group by type;


/*5 Find the most common rating for movies and TV shows */

select type, count(rating)
from netflix_new
group by type

select 

/*6 list all movies released in a specific year eg.2020 */ 

select * from netflix_new
where 
type = 'Movie'
and 
release_year = 2020;


/*7 find top 5 countries with most content on Netflix */

select country, count(*) as total_number from netflix_country nc
inner join netflix_new n
on nc.show_id = n.show_id
group by country
order by total_number desc
limit 5;


/*8 identify the longest movie */

select max(duration) as longest_movie
from netflix_new
where type = 'Movie';

/*9 find the content added in the last 5 years */

select *,
date_added from netflix_new
where
date_added >= current_date - interval '5 years'
order by date_added asc;


/*10 find all the movies directed by 'Rajiv ChilakF'*/

select title 
from netflix_new n
right join netflix_director nd
on n.show_id = nd.show_id
where n.type = 'Movie' and 
nd.director = 'Rajiv Chilaka'
;

/*11 list all TV shows with more than 5 seasons */
SELECT * 
FROM netflix_new
WHERE type = 'TV Show'
AND CAST(TRIM(REPLACE(REPLACE(duration, 'Seasons', ''), 'Season', '')) AS INT) > 5;

/*12 top 10 actors who have appeared in the highest number of movies produced in india */

SELECT nc.casts, COUNT(*) AS movie_counts
FROM netflix_new n
INNER JOIN netflix_cast nc
    ON n.show_id = nc.show_id
INNER JOIN netflix_country c
    ON n.show_id = c.show_id
WHERE c.country = 'India'
GROUP BY nc.casts
ORDER BY movie_counts DESC
LIMIT 5;











 N