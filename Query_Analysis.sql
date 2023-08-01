-- Exploratory Data Analysis

-- check the number of unique apps in both tables

SELECT COUNT(DISTINCT id) AS UniqueAppIDs
FROM AppleStore

SELECT COUNT(DISTINCT id) AS UniqueAppIDs
FROM appleStore_description

-- the results are the same amount (7197), so there is no missing data between two tables

-- check for any missing values in key fields

SELECT COUNT(*) AS MissingValues
FROM AppleStore
WHERE track_name IS null OR user_rating IS null OR prime_genre IS NULL

SELECT COUNT(*) AS MissingValues
FROM appleStore_description
WHERE app_desc IS NULL

-- the results are zero, no missing values

-- find out the number of apps per genre

SELECT prime_genre, COUNT(*) AS NumApps
FROM AppleStore
GROUP BY prime_genre
ORDER BY NumApps DESC

-- Games and Entertainment are leading

-- Get an overview of apps' ratings

SELECT min(user_rating) AS MinRating,
       max(user_rating) AS MaxRating,
       avg(user_rating) AS AvgRating
FROM AppleStore

-- Min is 0, Max is 5, and Average is 3.52

-- ENDING EXPLORATORY


-- DATA ANALYSIS, Finding the insights

-- Determine whether paid apps have higher ratings than free apps

SELECT CASE
	   WHEN price > 0 THEN 'Paid'
	   ELSE 'Free'
	   END AS App_Type,
	   avg(user_rating) AS Avg_Rating
FROM AppleStore
GROUP BY App_Type

-- the average rating of paid apps is slightly higher than free apps (3.72>3.37)

-- Check if apps with more supported languages have higher ratings

SELECT CASE
           WHEN lang_num < 10 THEN '<10 languages'
	   WHEN lang_num BETWEEN 10 AND 30 THEN '10-30 languages'
	   ELSE '>30 languages'
           END AS language_bucket,
	   avg(user_rating) AS Avg_Rating
FROM AppleStore
GROUP BY language_bucket
ORDER BY Avg_Rating DESC

/*
the middle bucket has highest user average rating
So, we don't necessarily need to work on so many languages
Focus effort on other aspects of the app
*/

-- Check genre with low ratings

SELECT prime_genre,
       avg(user_rating) AS Avg_Rating
FROM AppleStore
GROUP BY prime_genre
ORDER BY Avg_Rating ASC
LIMIT 10 

-- There might be good opportunity to create an app in this space

-- Check if there is correlation between the length of the app description and the user rating_count_tot

SELECT CASE
           WHEN length(b.app_desc) < 500 THEN 'Short'
	   WHEN length(b.app_desc) BETWEEN 500 AND 1000 THEN 'Medium'
	   ELSE 'Long'
           END AS description_length_bucket,
	   avg(a.user_rating) AS Average_Rating
FROM AppleStore a
JOIN appleStore_description b
ON a.id = b.id
GROUP BY description_length_bucket
ORDER BY Average_Rating DESC
/*
the longer the description, the higher is the user rating on average
*/	

-- Check the top-rated apps for each genre

SELECT prime_genre,
	   track_name,
	   user_rating
FROM (
	  SELECT prime_genre,
	   track_name,
	   user_rating,
	   rating_count_tot DESC,
	   rank() OVER (PARTITION BY prime_genre ORDER BY user_rating DESC, rating_count_tot DESC) AS rank
	  FROM AppleStore
	 ) AS a

WHERE a.rank = 1

-- in case there are ties, second order by rating count will solve the problems
-- top-rated apps for each genre represent the ideal apps to emulate
