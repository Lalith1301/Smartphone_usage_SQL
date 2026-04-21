
CREATE TABLE smartphone_usage (
    transaction_id VARCHAR(10) PRIMARY KEY,
    user_id VARCHAR(10),
    age INT,
    gender VARCHAR(10),
    
    daily_screen_time_hours DECIMAL(5,2),
    social_media_hours DECIMAL(5,2),
    gaming_hours DECIMAL(5,2),
    work_study_hours DECIMAL(5,2),
    sleep_hours DECIMAL(5,2),
    
    notifications_per_day INT,
    app_opens_per_day INT,
    
    weekend_screen_time DECIMAL(5,2),
    stress_level VARCHAR(20),
    academic_work_impact VARCHAR(20),
    addiction_level VARCHAR(20),
    addicted_label VARCHAR(10)
);

-----

select * from smartphone_usage

-------

-- Creating seperate tables from the existing table

-- 1.User Table

CREATE TABLE users (
    user_id VARCHAR(10) PRIMARY KEY,
    age INT,
    gender VARCHAR(10)
);

INSERT INTO users (user_id, age, gender)
SELECT DISTINCT user_id, age, gender
FROM smartphone_usage;

select *
from users
---------------------

-- 2. Usage Table

CREATE TABLE usage_stats (
    usage_id SERIAL PRIMARY KEY,
    user_id VARCHAR(10),
    
    daily_screen_time_hours DECIMAL(5,2),
    social_media_hours DECIMAL(5,2),
    gaming_hours DECIMAL(5,2),
    work_study_hours DECIMAL(5,2),
    sleep_hours DECIMAL(5,2),
    weekend_screen_time DECIMAL(5,2),
    
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- data 

INSERT INTO usage_stats (
    user_id, daily_screen_time_hours, social_media_hours,
    gaming_hours, work_study_hours, sleep_hours, weekend_screen_time
)
SELECT 
    user_id, daily_screen_time_hours, social_media_hours,
    gaming_hours, work_study_hours, sleep_hours, weekend_screen_time
FROM smartphone_usage;


------------------

-- 3.Activity Table
Drop table  if exists activity

CREATE TABLE activity (
	activity_id SERIAL PRIMARY KEY,
	user_id VARCHAR(10),
	
	notifications_per_day INT,
	app_opens_per_day INT,
	
	FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- data

INSERT INTO activity (
    user_id, notifications_per_day, app_opens_per_day
)
SELECT 
    user_id, notifications_per_day, app_opens_per_day
FROM smartphone_usage;

-------------------

-- 4.Health Table

drop table if exists health

CREATE TABLE health (
    health_id SERIAL PRIMARY KEY,
    user_id VARCHAR(10),
    
    stress_level VARCHAR(20),
    academic_work_impact VARCHAR(20),
    addiction_level VARCHAR(20),
    addicted_label VARCHAR(10),
    
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);


-- data

INSERT INTO health (
    user_id, stress_level, academic_work_impact,
    addiction_level, addicted_label
)
SELECT 
    user_id, stress_level, academic_work_impact,
    addiction_level, addicted_label
FROM smartphone_usage;


---------------------
---------------------
00000000000000000000000
---------------------
---------------------

-- Questions --


-- 1.Retrieve all users along with their age and gender sorted by age (descending).
-- 2.Count number of users grouped by gender (male vs female).
-- 3.Display all users with High stress level. 
-- 4.Find average daily screen time of all users.
-- 5.Show all users with age greater than 25.
-- 6.List users whose screen time is above overall average screen time.
-- 7.Display gender-wise average daily screen time.
-- 8.Calculate average sleep hours of users.
-- 9.Count number of users in each addiction level.
-- 10.Find the average daily screen time and sleep hours for each addiction level.
-- 11.List top 5 users with highest daily screen time along with their addiction level and stress level
-- 12.Find users whose gaming hours are greater than their work/study hours
-- 13.Find users whose daily screen time is above average screen time of all users
-- 14.Calculate average screen time for each gender and addiction level
-- 15.Find users whose screen time is higher than the average screen time of their gender
-- 16.Rank users based on daily screen time in descending order
-- 17.Find users whose notifications are above average AND sleep is below average
-- 18.Find users whose sleep hours are below average BUT gaming hours are above average.




--------------------------------------------



-- Solutions --
================

-- 1.Retrieve all users along with their age and gender sorted by age (descending).

select 	user_id , age , gender from users
order by age desc

----------------------------

-- 2.Count number of users grouped by gender (male vs female).

SELECT 
    gender,
    COUNT(*) AS total_users
FROM users
GROUP BY gender
order by gender;

----------------------------

-- 3.Display all users with High stress level. 

SELECT 
    u.user_id,
    u.age,
    u.gender,
    h.stress_level
FROM users as u
JOIN health as h ON u.user_id = h.user_id
WHERE h.stress_level = 'High';

----------------------------

-- 4.Find average daily screen time of all users.

SELECT 
    AVG(daily_screen_time_hours) AS avg_screen_time
FROM usage_stats;

-----------------------------

-- 5.Show all users with age greater than 25.

SELECT 
    user_id,
    age,
    gender
FROM users
WHERE age > 25;

-----------------------------

-- 6.List users whose screen time is above overall average screen time.

SELECT 
    u.user_id,
    u.age,
    u.gender,
    us.daily_screen_time_hours
FROM users as u
JOIN usage_stats as us ON u.user_id = us.user_id
WHERE us.daily_screen_time_hours > (
    SELECT AVG(daily_screen_time_hours) 
    FROM usage_stats
);

-----------------------------

-- 7.Display gender-wise average daily screen time.

SELECT 
    u.gender,
    Round(AVG(us.daily_screen_time_hours), 2)AS avg_screen_time
FROM users as u
JOIN usage_stats as us ON u.user_id = us.user_id
GROUP BY u.gender;

-----------------------------

-- 8.Calculate average sleep hours of users.


SELECT 
    ROUND(AVG(sleep_hours), 2) AS avg_sleep_hours
FROM usage_stats;

-----------------------------

-- 9.Count number of users in each addiction level.

SELECT 
    addiction_level,
    COUNT(*) AS total_users
FROM health
GROUP BY addiction_level;

-----------------------------

-- 10.Find the average daily screen time and sleep hours for each addiction level.
	
SELECT 
    h.addiction_level,
    ROUND(AVG(us.daily_screen_time_hours), 2) AS avg_screen_time,
    ROUND(AVG(us.sleep_hours), 2) AS avg_sleep_hours
FROM usage_stats as us
JOIN health as h ON us.user_id = h.user_id
GROUP BY h.addiction_level
ORDER BY h.addiction_level;

-----------------------------

-- 11.List top 5 users with highest daily screen time along with their addiction level and stress level

SELECT 
    u.user_id,
    round(us.daily_screen_time_hours,2) as screen_time,
    h.addiction_level,
    h.stress_level
FROM users as u
JOIN usage_stats as us ON u.user_id = us.user_id
JOIN health as h ON u.user_id = h.user_id
ORDER BY us.daily_screen_time_hours DESC
LIMIT 5;

-----------------------------

-- 12.Find users whose gaming hours are greater than their work/study hours

SELECT 
    user_id,
    gaming_hours,
    work_study_hours,
    (gaming_hours - work_study_hours) AS extra_gaming_time
FROM usage_stats
WHERE gaming_hours > work_study_hours
ORDER BY extra_gaming_time DESC;

-----------------------------

-- 13.Find users whose daily screen time is above average screen time of all users

SELECT 
    user_id,
    daily_screen_time_hours as Screen_time
FROM usage_stats
WHERE daily_screen_time_hours > (
    SELECT AVG(daily_screen_time_hours)
    FROM usage_stats
);


select * from usage_stats

-----------------------------

-- 14.Calculate average screen time for each gender and addiction level

SELECT 
    u.gender,
    h.addiction_level,
    ROUND(AVG(us.daily_screen_time_hours), 2) AS avg_screen_time
FROM users as u
JOIN usage_stats as us ON u.user_id = us.user_id
JOIN health as h ON u.user_id = h.user_id
GROUP BY u.gender, h.addiction_level
ORDER BY u.gender, h.addiction_level
limit 10;

-----------------------------

-- 15.Find users whose screen time is higher than the average screen time of their gender


WITH gender_avg AS (
    SELECT 
        u.gender,
        AVG(us.daily_screen_time_hours) AS avg_screen_time
    FROM users as u
    JOIN usage_stats as us ON u.user_id = us.user_id
    GROUP BY u.gender
)
SELECT 
    u.user_id,
    u.gender,
    us.daily_screen_time_hours
FROM users as u
JOIN usage_stats as us ON u.user_id = us.user_id
JOIN gender_avg as g ON u.gender = g.gender
WHERE us.daily_screen_time_hours > g.avg_screen_time
order by daily_screen_time_hours
limit 10;

-----------------------------

-- 16.Rank users based on daily screen time in descending order

SELECT 
    u.user_id,
    us.daily_screen_time_hours,
    RANK() OVER (ORDER BY us.daily_screen_time_hours DESC) AS rank
FROM users as u
JOIN usage_stats as us ON u.user_id = us.user_id
limit 10;

-----------------------------

-- 17.Find users whose weekend screen time is higher than their weekday (daily) screen time, and show their addiction level

SELECT 
    u.user_id,
    us.daily_screen_time_hours,
    us.weekend_screen_time,
    h.addiction_level
FROM users as u
JOIN usage_stats as us ON u.user_id = us.user_id
JOIN health as h ON u.user_id = h.user_id
WHERE us.weekend_screen_time > us.daily_screen_time_hours
limit 10;

-----------------------------

-- 18.Find users whose sleep hours are below average BUT gaming hours are above average, along with their addiction level

SELECT 
    u.user_id,
    us.sleep_hours,
    us.gaming_hours,
    h.addiction_level
FROM users as u
JOIN usage_stats as us ON u.user_id = us.user_id
JOIN health as h ON u.user_id = h.user_id
WHERE us.sleep_hours < (
    SELECT AVG(sleep_hours) FROM usage_stats
)
AND us.gaming_hours > (
    SELECT AVG(gaming_hours) FROM usage_stats
)

limit 15;





