
CREATE TABLE MISSION_LAUNCHES
(
launch_id INT PRIMARY KEY,
organization VARCHAR(50),
location varchar(150),
Date TIMESTAMP,
Rockets_Mission VARCHAR(200),
Rocket_Status varchar(50),
Price DECIMAL(50),
Mission_Status varchar(50)
)

COPY MISSION_LAUNCHES
FROM 'C:\Users\Saksh\Downloads\mission_launchess.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
\copy MISSION_LAUNCHES FROM 'C:\Users\Saksh\Downloads\mission_launchess.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');


ALTER TABLE mission_launches
ALTER COLUMN Price TYPE DECIMAL(10,4);

select * from mission_launches LIMIT 20;

--Count of missions launched by organizations

select
organization,
COUNT(rockets_mission) as max_missions,
extract(YEAR from date) as year_d
FROM
mission_launches
GROUP BY extract(YEAR from date), organization
ORDER BY year_d DESC;


--Max mission launches by year:
select
year_d,
MAX(rockets_missions) as maX
FROM
(select
COUNT(rockets_mission) as rockets_missions,
extract(YEAR from date) as year_d
FROM
mission_launches
GROUP bY extract(Year from date))
mission_launches
GROUP BY year_d
ORDER BY max DESC;

/*WITH cte_name AS (
    SELECT 
        column1, column2, 
        window_function() OVER (PARTITION BY column_name ORDER BY column_name) AS alias
    FROM table_name
)

SELECT * FROM cte_name;
*/



--max mission launches of organizations by year 

WITH yearly_missions AS (
    SELECT  
        EXTRACT(YEAR FROM date) AS year_d, 
        organization,
        COUNT(rockets_mission) AS mission_count
    FROM mission_launches
    GROUP BY year_d, organization
),
ranked_missions AS (
    SELECT 
        year_d, 
        organization, 
        mission_count,
        ROW_NUMBER() OVER (PARTITION BY year_d ORDER BY mission_count DESC) AS rnk
    FROM yearly_missions
)
SELECT year_d, organization, mission_count 
FROM ranked_missions
WHERE rnk = 1
ORDER BY year_d DESC;


--How has the cost of space missions varied over time?

WITH am AS(
    SELECT 
        organization,
        MAX(price::DECIMAL(10,2)) AS max_price,
        EXTRACT(YEAR FROM date) AS year_d   
    FROM mission_launches
    WHERE price IS NOT NULL
    GROUP BY organization, year_d
),
max_prices AS(
    select
    organization,
    max_price,
    year_d,
    ROW_NUMBER () OVER(PARTITION BY year_d ORDER BY max_price DESC) as rn
FROM am
)
select
    organization, year_d, max_price
FROM
max_prices
where rn = 1
order by year_d DESC

--Which organization had the most successful missions

WITH status_count AS(
    select
    organization,
    EXTRACT(YEAR FROM date) AS year_d,
    COUNT(Mission_Status) as num_status
    FROM
    mission_launches
    where Mission_Status LIKE '%Success%'
    GROUP BY organization, year_d
),
Ranking_status AS(
    select
    organization,
    year_d,
    num_status,
    ROW_NUMBER() OVER(PARTITION BY year_d ORDER BY num_status DESC) as rp
    FROM status_count
) 
select
organization,
year_d,
num_status
FROM Ranking_status
where rp =1
order by year_d DESC

---without year:

WITH status_count AS(
    select
    organization,
    COUNT(Mission_Status) as num_status
    FROM
    mission_launches
    where Mission_Status LIKE '%Success%'
    GROUP BY organization
),
Ranking_status AS(
    select
    organization,
    num_status,
    ROW_NUMBER() OVER(PARTITION BY organization ORDER BY num_status DESC) as rp
    FROM status_count
) 
select
organization,
num_status
FROM Ranking_status
where rp =1


----Which organization had the most failure missions

WITH status_count AS(
    select
    organization,
    COUNT(Mission_Status) as num_status
    FROM
    mission_launches
    where Mission_Status LIKE '%Failure%'
    GROUP BY organization
),
Ranking_status AS(
    select
    organization,
    num_status,
    ROW_NUMBER() OVER(PARTITION BY organization ORDER BY num_status DESC) as rp
    FROM status_count
) 
select
organization,
num_status
FROM Ranking_status
where rp =1

--Most launches by country
WITH country_launches AS(
SELECT substring( location FROM '[^ ]+$') AS country,
COUNT(mission_launches) as count_launches
from mission_launches
where substring( location FROM '[^ ]+$') not LIKE '%Facility%' AND
substring( location FROM '[^ ]+$') not LIKE '%Site%' AND
substring( location FROM '[^ ]+$') not LIKE '%Sea%' AND
substring( location FROM '[^ ]+$') not LIKE '%Ocean'
GROUP BY country),
ranked_launch AS(
select
country,
count_launches,
ROW_NUMBER() OVER(PARTITION BY country ORDER BY count_launches DESC) as rank_count
FROM country_launches)
select
country,
count_launches
from
ranked_launch
where rank_count = 1
