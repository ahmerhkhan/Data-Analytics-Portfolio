-- create table
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

-- Exploratory Data Analysis
select count(distinct artist)
from spotify;

select count(distinct album)
from spotify;

select distinct album_type
from spotify;

-- Top 5 Liked Songs
with cte as (
select track,artist,likes,row_number() over(partition by track)
from spotify
order by likes desc
)
select track,artist,likes
from cte
where row_number=1
limit 5;

select max(duration_min)
from spotify
;

select min(duration_min)
from spotify;

delete from spotify
where duration_min=0;

-- Easy Level
/* Q1. Retrieve the names of all tracks that have more than 1 billion streams.*/
select track,stream
from spotify
where stream>1000000000;

/* Q2. List all albums along with their respective artists.*/
select distinct artist,album
from spotify
order by 1;

/* Q3. Get the total number of comments for tracks where licensed = TRUE. */
select sum(comments) as total_comments
from spotify
where licensed=true;


/* Q4. Find all tracks that belong to the album type single. */
select track
from spotify
where album_type='single';

/* Q5. Count the total number of tracks by each artist.*/
select artist,count(track)
from spotify
group by artist
order by 2 desc;



-- Intermediate Level

/* Q6.Calculate the average danceability of tracks in each album. */
select album,avg(danceability) as album_danceability
from spotify
group by album
order by 2 desc;

/* Q7.Find the top tracks with the highest energy values.*/
select distinct track,energy
from spotify
where energy = ( select max(energy) from spotify)
order by energy desc
;

/* Q8.List all tracks along with their views and likes where official_video = TRUE.*/
select track,views,likes
from spotify
where official_video='true';

/* Q9.For each album, calculate the total views of all associated tracks.*/
select track,album, sum(views)
from spotify
group by 1,2
order by 2,1;

/* Q10. Retrieve the track names that have been streamed on Spotify more than YouTube.*/
select *
from spotify
where most_played_on='Spotify';

-- Advanced Level
/* Q11. Find the top 3 most-viewed tracks for each artist using window functions. */
with cte as (
select artist,track,sum(views) as views,
dense_rank() over(partition by artist order by sum(views) desc) as row_number
from spotify
group by 1,2
order by 1,3 desc
)
select artist,track,views
from cte
where row_number<4
order by artist;

/* Q12. Write a query to find tracks where the liveness score is above the average.*/
select track,liveness
from spotify
where liveness> (select avg(liveness) from spotify);

/* Q13.Use a WITH clause to calculate the difference between the 
highest and lowest energy values for tracks in each album. */
with energy as(
select album,max(energy),min(energy)
from spotify
group by album
)
select album,max-min as difference
from energy
order by difference desc;

/* Q14.Find tracks where the energy-to-liveness ratio is greater than 1.2.*/

select track,energy/liveness as energy_to_liveness_ratio
from spotify
where energy/liveness>1.2
order by 2 desc;

/* Q15.Calculate the cumulative sum of likes for tracks ordered by 
the number of views, using window functions.*/

with RankedTracks as (
select track,artist,views,likes,row_number() over(partition by track order by views desc) as rn
from spotify
)
select track,artist,views,likes,sum(likes)over(order by views desc) as cumulative_likes
from RankedTracks
where rn=1;


