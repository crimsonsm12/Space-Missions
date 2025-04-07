
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

SELECT
organization,
DATE,
COUNT(rockets_mission) as max_missions
FROM
mission_launches
GROUP BY organization, DATE
ORDER BY max_missions DESC


Select
    extract(MONTH from date) as month_d
from
mission_launches

--COUNT missions flown by an organization by year

select
organization,
COUNT(rockets_mission) as max_missions,
extract(YEAR from date) as year_d
FROM
mission_launches
GROUP BY extract(YEAR from date), organization
ORDER BY year_d DESC, max_missions DESC;

--Max mission launches in a year by organization:
select
organization,
year_d,
MAX(rockets_missions) as max_mission
FROM
(select
organization,
COUNT(rockets_mission) as rockets_missions,
extract(YEAR from date) as year_d
FROM
mission_launches
GROUP bY extract(Year from date), organization)
mission_launches
GROUP BY organization, year_d
ORDER by year_d DESC

--How has the cost of space missions varied over time?

select
