CREATE DATABASE IF NOT EXISTS Assign4;

USE Assign4;

--creating movies table

Create table IF NOT EXISTS movies (movie_id int, movie_title string, genres ARRAY<String>)
row format delimited
fields terminated by '#'
collection items terminated by '|';

--creating ratings table

Create table IF NOT EXISTS ratings (user_id int, movie_id int, rating int, tstamp String)
row format delimited
fields terminated by '#';


Load data local inpath 'movies(1).dat' into table  movies;

Load data local inpath 'ratings(1).dat' into table  ratings;

--creating a view which contains the exploded genres of the movies.

Create view IF NOT EXISTS genres_explode as
Select movie_id, movie_title,seperate_genre
from  movies lateral view explode(genres) exploded AS seperate_genre;

--creating a table with join condition

create table if not exists  join_table  as
select r.user_id as userid,
e.movie_id as movieid,e.seperate_genre as genre,r.rating as rating from  genres_explode e JOIN ratings r on(r.movie_id=e.movie_id);

--creating a table with average of ratings as one of the column

create table IF NOT EXISTS avg_rating_table as
select userid,genre,avg(rating) as avg from  join_table group by userid,genre;


--getting the top 5 genre and the average rating given by the user for each genre

insert overwrite local directory 'Downloads/avgRating_each_genre'
row format delimited
fields terminated by '\t'
select userid,genre,avg from
(select userid,genre,avg,rank() over (partition by userid order by avg desc) as rank  from  avg_rating_table) innertable where innertable.rank<6 group by userid,genre,avg;


