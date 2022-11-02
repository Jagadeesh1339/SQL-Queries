/* creating database in mysql */
CREATE DATABASE fifa19

/* creating table players in fifa19 database*/
CREATE TABLE Players(
  ID int,
  Name varchar(255),
  Age int,
  Nationality varchar(255),
  Overallrating int,
  Potentialrating int,
  club varchar(255),
  value int,
  wage int,
  preferredfoot enum('Left','Right'),
  jerseynumber int,
  joined date,
  height varchar(10),
  weight int,
  penalities int
);


/* Importing csv file into the dataset
 I had to run few commands before entering the load data command*/

 mysql --local-infile=1 -u root -p

 SET GLOBAL local_infile=1

 LOAD DATA LOCAL INFILE
 "C:/Users/HP/Desktop/Analytics Vidhya/Projects/Descreptive analytics of FIFA19 players/fifa19.csv"
 INTO TABLE Players
 CHARACTER SET latin1
 COLUMNS TERMINATED BY ","
 OPTIONALLY ENCLOSED BY "'"
 IGNORE 1 LINES;


--Questions and answers?

 -- 1. How many players are there in the fifa19 dataset?
SELECT COUNT(Name) AS count_of_players FROM players;

-- 2. How many nationalities do these players belong to ?
SELECT COUNT(DISTINCT(Nationality)) FROM players;

-- 3. What is the total wage given to all players? What's the average and standard deviation?
SELECT SUM(wage) AS total_wage, AVG(wage) AS avg_wage, STDDEV(wage) AS std_wage FROM PLAYERS;

/* 4. Which nationality has the highest number of players,
      what are the top 3 nationalities by the no of players,
      How many players they have ? */
SELECT Nationality, COUNT(Name) AS no_of_players
FROM players
GROUP BY nationality
ORDER BY no_of_players DESC
LIMIT 3;

-- 5. Which player has the highest wage? Who has the lowest?
SELECT Name FROM players ORDER BY wage DESC LIMIT 1;
SELECT Name FROM players ORDER BY wage LIMIT 1;

      -- Doing above quries using SUBQUERY
SELECT Name FROM Players WHERE wage = (SELECT MAX(wage) FROM players);
SELECT Name FROM Players WHERE wage = (SELECT MIN(wage) FROM players) LIMIT 1;

-- 6. The player having the – best overall rating? Worst overall rating?
SELECT Name FROM Players WHERE Overallrating = (SELECT MAX(Overallrating) FROM Players);
SELECT Name FROM Players WHERE Overallrating = (SELECT MIN(Overallrating) FROM Players);

-- 7. Club having the highest total of overall rating? Highest Average of overall rating?
SELECT club, SUM(Overallrating)
FROM Players
GROUP BY club
ORDER BY SUM(Overallrating) DESC LIMIT 1;

SELECT club, AVG(Overallrating)
FROM Players
GROUP BY club
ORDER BY AVG(Overallrating) DESC LIMIT 1;

-- 8. What are the top 5 clubs based on the average ratings of their players and their corresponding averages?
SELECT club, AVG(Overallrating) AS average_rating
FROM Players
GROUP BY club
ORDER BY average_rating DESC LIMIT 5;

-- 9. What is the distribution of players whose preferred foot is left vs right?
SELECT preferredfoot, COUNT(Name) AS no_of_players FROM Players GROUP BY preferredfoot;
                               -- OR
SELECT preferredfoot, COUNT(Name) AS freq FROM Players GROUP BY 1 ORDER BY 2 DESC;

-- 10. Which jersey number is the luckiest?
-- I have assumed that LUCKY means the jersy number which have the highest total wage.
SELECT SUM(wage), jerseynumber FROM Players GROUP BY jerseynumber ORDER BY 1 DESC LIMIT 1;

-- 11. What is the frequency distribution of nationalities among players whose club name starts with M?
SELECT Nationality, COUNT(Nationality) AS freq
FROM Players
WHERE Club LIKE "M%"
GROUP BY Nationality
ORDER BY 2;

/* 12. How many players have joined their respective clubs
in the date range 20 May 2018 to 10 April 2019 (both
inclusive)? */
SELECT COUNT(*) AS no_of_players
FROM players
WHERE joined BETWEEN "2018-05-20" AND "2019-04-10";

-- 13. How many players have joined their respective clubs date wise?
SELECT joined, COUNT(*) AS no_of_players
FROM Players
GROUP BY 1
ORDER BY 1;

-- 14. How many players have joined their respective clubs yearly ?
SELECT year(joined), COUNT(*) AS no_of_players
FROM Players
GROUP BY 1
ORDER BY 1;
