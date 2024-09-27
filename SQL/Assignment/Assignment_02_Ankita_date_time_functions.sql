Create database Date_Time;
use Date_Time;

Drop table orders;
CREATE TABLE swiggy_orders (
    order_id INT PRIMARY KEY,                  -- Unique identifier for each order
    customer_name VARCHAR(100),                -- Name of the customer
    restaurant_name VARCHAR (100),             -- Name of the restaurant
    order_date DATE,                           -- Date when the order was placed
    delivery_time TIME,                        -- Date and time when the order was delivered
    delivery_address VARCHAR(100),             -- Address to which the order is delivered
    city VARCHAR(50),                          -- city in which the order is delivered
    delivery_status VARCHAR(50),               -- current status of the order
    order_amount DECIMAL(3, 2),                -- Total amount of the order
    delivery_agent VARCHAR(30)                 -- Name of the delivery agent who is handling the order
    );
    
    
    -- Loading data in local file
load data local infile "C:/Users/ankit/Desktop/Data_Analytics/SQL/Assignment/Swiggy_Orders.csv"
into table  swiggy_orders
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;
 
 
show global variables like 'local_infile';
set global local_infile = 1;


SELECT count(*) FROM swiggy_orders;
Select * from swiggy_orders;

-- Problem Statement 
 -- 4.Orders Placed in Specific Months: Find all orders placed in September of any year.

-- 1.Extract the year, month, and day from the order_date column in the Swiggy dataset.
 
SELECT
EXTRACT(YEAR FROM order_date) AS order_year,
EXTRACT(MONTH FROM order_date) AS order_month,
EXTRACT(DAY FROM order_date) AS order_day
FROM swiggy_orders;

SELECT order_date FROM swiggy_orders;


-- 2.Current Timestamp: Get the current timestamp and compare it with the delivery_time.

SELECT CURRENT_TIMESTAMP;   -- 2024-09-24 17:04:45
SELECT NOW();    -- 2024-09-24 17:04:45
SELECT CURRENT_DATE;   -- 2024-09-24


SELECT
    delivery_time,
    CASE
        WHEN CURRENT_TIMESTAMP > delivery_time THEN 'Delivery time has passed.'
        WHEN CURRENT_TIMESTAMP < delivery_time THEN 'Delivery time is in the future.'
        ELSE 'Delivery time is now.'
    END AS delivery_status
FROM swiggy_orders
WHERE order_id = 2;

SELECT delivery_time FROM swiggy_orders;


-- 3.Date & Time Difference: Calculate the number of days, hours, minutes, etc between the order_date and delivery_time and store it in respective 
-- columns.
Alter Table swiggy_orders
ADD COLUMN days_diff  INT,
ADD COLUMN hours_diff INT,
ADD COLUMN minutes_diff INT,
ADD COLUMN seconds_diff INT;  

UPDATE swiggy_orders
SET 
    days_diff = TIMESTAMPDIFF(day, order_date, delivery_time),
    hours_diff = TIMESTAMPDIFF(hour, order_date, delivery_time) % 24,
    minutes_diff = (TIMESTAMPDIFF(minute, order_date, delivery_time) % 60),
    seconds_diff = (TIMESTAMPDIFF(second, order_date, delivery_time) % 60);

SELECT * FROM swiggy_orders;
    
-- Add 45 minutes to the delivery_time and show the updated time.
SELECT
    delivery_time,
DATE_ADD(delivery_time, INTERVAL 45 MINUTE) AS updated_delivery_time
FROM swiggy_orders;  

SELECT 
    delivery_time,
    delivery_time + INTERVAL 45 MINUTE AS updated_delivery_time   -- error 
FROM swiggy_orders;

-- 4.Orders Placed in Specific Months:
-- Find all orders placed in September of any year.
SELECT * FROM swiggy_orders
WHERE EXTRACT(MONTH FROM order_date)= 9;

-- 4.Time Zone Conversion:
-- Convert the delivery_time from UTC to a specific time zone (e.g., 'Asia/Kolkata').
SELECT 
    delivery_time,
    CONVERT_TZ(delivery_time, 'UTC', 'Asia/Kolkata', delivery_time) AS India_delivery_time
FROM swiggy_orders;

-- 5.	Orders on Specific Weekends:
-- •	Find all orders placed on a weekend (Saturday or Sunday).
SELECT order_id, order_date FROM swiggy_orders
WHERE DAYOFWEEK(order_date) IN (1, 7); -- 1 = Sunday, 7 = Saturday

-- Identify the peak delivery hours by extracting the hours from delivery_time and grouping by hour..
SELECT
EXTRACT(HOUR FROM delivery_time) as delivery_hour,
COUNT(*) AS total_deliveries
FROM swiggy_orders
GROUP BY delivery_hour
ORDER BY total_deliveries DESC;

-- Identify which day of the week has the most deliveries.
SELECT
DAYOFWEEK (order_date) AS day_of_week,
COUNT(*) AS total_deliveries
FROM swiggy_orders
GROUP BY DAYOFWEEK (order_date)
ORDER BY total_deliveries DESC
LIMIT 1;  -- This limits the result to the day with the most deliveries

-- 7.Handling Daylight Saving Time:
-- Convert the delivery_time into a time zone that observes daylight saving time (e.g., 'America/New_York') and check if any orders fall during the daylight saving 
 --  adjustment period.
SELECT 
delivery_time,
CONVERT_TZ(delivery_time, 'UTC', 'America/New_York', delivery_time) AS ny_delivery_time
FROM swiggy_orders;

-- -- 8.Identify Late Deliveries: 
-- Find orders where the delivery took more than 1 hour.
SELECT * FROM swiggy_orders
WHERE TIMESTAMPDIFF(HOUR,delivery_time,order_date)>1;

-- 9. Filtering Orders Between Two Date-Times:
-- Find all orders placed between specific date ranges, e.g., between '2023-09-01' and '2023-09-05' and orders placed between 5 PM and 7 PM both for those dates included and without those date too irrespective of dates.
SELECT *
FROM swiggy_orders
WHERE order_date >= '2023-09-01'
  AND order_date <= '2023-09-05'
  AND EXTRACT(HOUR FROM delivery_time) >= 17 -- 5 PM
  AND EXTRACT(HOUR FROM delivery_time) < 19;

-- Find Orders Placed Between 5 PM and 7 PM for Specific Dates
SELECT 
order_id, order_date
FROM swiggy_orders
GROUP BY order_id,order_date
HAVING order_date BETWEEN '2023-09-01' AND '2023-09-05'
AND HOUR(order_date) BETWEEN 17 AND 19;

-- Find Orders Placed between Specific Dates
SELECT * FROM swiggy_orders
WHERE order_date BETWEEN '2023-09-01' AND '2023-09-05';

-- Orders Placed Between 5 PM and 7 PM Irrespective of Dates
SELECT * FROM swiggy_orders
GROUP BY order_id,order_date
HAVING HOUR(order_date) BETWEEN 17 AND 19;

-- 10.Handling Leap Years:
-- Find orders placed on February 29th (during leap years).
SELECT * FROM swiggy_orders
WHERE MONTH(order_date) = 2
  AND DAY(order_date) = 29
  AND MOD(YEAR(order_date), 4) = 0
  AND (MOD(YEAR(order_date), 100) != 0 OR MOD(YEAR(order_date), 400) = 0);

SELECT order_id,order_date FROM swiggy_orders 
WHERE (YEAR(order_date) % 4 = 0 OR YEAR(order_date) % 100 != 0 AND YEAR(order_date) % 400 = 0)
GROUP BY order_id,order_date HAVING DAY(order_date) = 29 AND MONTH(order_date) = 2 ;

SELECT * FROM swiggy_orders
WHERE EXTRACT(MONTH FROM order_date) = 2
AND EXTRACT(DAY FROM order_date) = 29;

-- 11.Timestamp Arithmetic with Time Zones:
-- Calculate the time difference between the order time in 'Asia/Kolkata' and 'America/Los_Angeles'.

SELECT 
order_id, order_date,
CONVERT_TZ(order_date, 'Asia/Kolkata', 'America/Los_Angeles') AS LA_order_time,
TIMESTAMPDIFF(HOUR, order_date, CONVERT_TZ(order_date, 'Asia/Kolkata', 'America/Los_Angeles')) AS time_diff_hours
FROM swiggy_orders;

-- other way to calculate time difference between the order time in 'Asia/Kolkata' and 'America/Los_Angeles'.
SELECT 
order_id, order_date,
CONVERT_TZ(order_date, 'Asia/Kolkata', 'America/Los_Angeles') AS order_time_LA,
TIMESTAMPDIFF(HOUR, order_date, CONVERT_TZ('Asia/Kolkata', 'America/Los_Angeles',order_date)) AS time_diff_hours
FROM swiggy_orders;

-- another way to calculate time difference between the order time in 'Asia/Kolkata' and 'America/Los_Angeles'.
SELECT 
convert_tz('Asia/Kolkata','America/Los_Angeles',delivery_time) AS LA_order_time,
order_date AS order_time_TZ,
TIMESTAMPDIFF(HOUR, order_date,convert_tz('Asia/Kolkata','America/Los_Angeles',order_date)) AS order_time_diff
FROM swiggy_orders;

-- 12.Finding the Most Recent Order:
-- Retrieve the most recent order placed in the last 7 days.
SELECT * FROM swiggy_orders
WHERE order_date >=  NOW() - INTERVAL 7 DAY  -- Filter for the last 7 days
ORDER BY order_date DESC  
LIMIT 1;  -- Get the most recent order

-- 13.Calculate Average Delivery Time per City:
-- Calculate the average delivery time for each city.
-- average delivery in minutes
SELECT 
city,
AVG(TIMESTAMPDIFF(MINUTE, order_date, delivery_time)) AS avg_delivery_time_minutes
FROM swiggy_orders
GROUP BY city;

-- average delivery in hours
SELECT 
city, 
AVG(TIMESTAMPDIFF(hour, order_date, delivery_time)) AS average_delivery_time
FROM swiggy_orders
GROUP BY city
ORDER BY average_delivery_time; 

-- 14.Finding Busiest Days by City:
-- Identify which day of the week has the highest number of orders for each city.
SELECT city,
DAYNAME(order_date) AS day_of_week,
COUNT(*) AS order_count
FROM swiggy_orders
GROUP BY city, day_of_week
ORDER BY city, order_count DESC;

SELECT city,
WEEKDAY(order_date) AS day_of_week,  -- 1=Monday, 2=Tuesday, 3=wednesday, 4=thursday, 5=friday, 6=saturday, 7=sunday
COUNT(*) AS order_count
FROM swiggy_orders
GROUP BY city, day_of_week
ORDER BY city, order_count DESC;

-- 15.Delayed Deliveries Based on Peak Hours:
-- Identify orders that took longer during peak hours (5 PM - 8 PM).

SELECT 
    order_id,
    order_date,
    delivery_time,
EXTRACT(HOUR FROM delivery_time) AS Peak_delivery_hours
FROM swiggy_orders
WHERE EXTRACT(HOUR FROM delivery_time) BETWEEN 17 AND 20
GROUP BY order_id , order_date , delivery_time , Peak_delivery_hours
HAVING TIMESTAMPDIFF(MINUTE, order_date, delivery_time) AND Peak_Delivery_Hours < 20
ORDER BY delivery_time DESC;

-- 16.Orders with Week-to-Week Growth:
-- Calculate week-on-week growth of orders.
SELECT 
    YEAR(order_date) AS order_year,
    WEEK(order_date) AS order_week,
    COUNT(*) AS order_count
FROM swiggy_orders
GROUP BY order_year, order_week
ORDER BY order_year, order_week;

-- 17.Finding Orders Affected by Public Holidays:
-- Identify orders placed on specific public holidays (e.g., New Year's Day, Diwali).

SELECT order_id, order_date
FROM swiggy_orders
WHERE Day (order_date) = 1 AND MONTH(order_date) = 1  
OR Day (order_date) = 25 AND MONTH(order_date) = 12  
OR Day (order_date) = 15 AND MONTH(order_date) = 8 
GROUP BY order_id,order_date
ORDER BY order_id ASC;

