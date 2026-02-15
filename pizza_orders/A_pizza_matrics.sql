CREATE DATABASE IF NOT EXISTS pizza_runner;
SET search_path = pizza_runner;
USE PIZZA_RUNNER;

show tables;

-- 1. Runners Table
DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  runner_id INTEGER,
  registration_date DATE
);

INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');

-- 2. Customer Orders Table
DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  (1, 101, 1, '', '', '2020-01-01 18:05:02'),
  (2, 101, 1, '', '', '2020-01-01 19:00:52'),
  (3, 102, 1, '', '', '2020-01-02 23:51:23'),
  (3, 102, 2, '', NULL, '2020-01-02 23:51:23'),
  (4, 103, 1, '4', '', '2020-01-04 13:23:46'),
  (4, 103, 1, '4', '', '2020-01-04 13:23:46'),
  (4, 103, 2, '4', '', '2020-01-04 13:23:46'),
  (5, 104, 1, 'null', '1', '2020-01-08 21:00:29'),
  (6, 101, 2, 'null', 'null', '2020-01-08 21:03:13'),
  (7, 105, 2, 'null', '1', '2020-01-08 21:20:29'),
  (8, 102, 1, 'null', 'null', '2020-01-09 23:54:33'),
  (9, 103, 1, '4', '1, 5', '2020-01-10 11:22:59'),
  (10, 104, 1, 'null', 'null', '2020-01-11 18:34:49'),
  (10, 104, 1, '2, 6', '1, 4', '2020-01-11 18:34:49');

-- 3. Runner Orders Table
DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  (1, 1, '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  (2, 1, '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  (3, 1, '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  (4, 2, '2020-01-04 13:53:03', '23.4', '40', NULL),
  (5, 3, '2020-01-08 21:10:57', '10', '15', NULL),
  (6, 3, 'null', 'null', 'null', 'Restaurant Cancellation'),
  (7, 2, '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  (8, 2, '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  (9, 2, 'null', 'null', 'null', 'Customer Cancellation'),
  (10, 1, '2020-01-11 18:50:20', '10km', '10minutes', 'null');

-- 4. Pizza Names Table
DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name TEXT
);

INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');

-- 5. Pizza Recipes Table
DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);

INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');

-- 6. Pizza Toppings Table
DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);

INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  
  --
USE PIZZA_RUNNER;
  
SHOW TABLES;
  
SELECT * FROM PIZZA_NAMES;
SELECT * FROM CUSTOMER_ORDERS;
SELECT * FROM PIZZA_RECIPES;
SELECT * FROM PIZZA_TOPPINGS;
SELECT * FROM RUNNER_ORDERS;
SELECT * FROM RUNNERS;

-- CREATE TEMPORARY TABLE TO DEAL WITH NULL VALUES
CREATE TEMPORARY TABLE customer_orders_temp AS
SELECT
	order_id,
	customer_id,
	pizza_id,
    order_time,
	CASE
		WHEN exclusions IS null OR exclusions LIKE 'null' THEN ' '
		ELSE exclusions
	END AS exclusions,
	CASE
		WHEN extras IS NULL or extras LIKE 'null' THEN ' '
		ELSE extras
	END AS extras
FROM pizza_runner.customer_orders;

SELECT * FROM customer_orders_temp;

-- CREATE TEMPORARY TABLE "RUNNER_ORDERS_TEMP" 
CREATE TEMPORARY TABLE RUNNER_ORDERS_TEMP AS 
SELECT 
	ORDER_ID,
    RUNNER_ID,
	CASE
		WHEN PICKUP_TIME IS NULL OR PICKUP_TIME LIKE 'NULL' THEN ' '
        ELSE PICKUP_TIME
	END AS PICKUP_TIME,
	CASE 
		WHEN DISTANCE IS NULL OR DISTANCE LIKE 'NULL' THEN ' '
        WHEN DISTANCE LIKE '%km' THEN TRIM('km' FROM DISTANCE)
        ELSE DISTANCE
	END AS DISTANCE,
    CASE
		WHEN DURATION IS NULL OR DURATION LIKE 'NULL' THEN ' '
        WHEN DURATION LIKE '%minutes' THEN TRIM('minutes' FROM DURATION)
        WHEN DURATION LIKE '%mins' THEN TRIM('mins' FROM DURATION)
        WHEN DURATION LIKE '%minute' THEN TRIM('minute' from DURATION)
        ELSE DURATION
	END AS DURATION,
    CASE
		WHEN CANCELLATION IS NULL OR CANCELLATION LIKE 'NULL' THEN ' '
        ELSE CANCELLATION 
	END AS CANCELLATION
FROM PIZZA_RUNNER.RUNNER_ORDERS;

SELECT * FROM RUNNER_ORDERS_TEMP;

-- UPDATE DATA TYPE OF 'RUNNER_ORDERS_TEMP'
ALTER TABLE RUNNER_ORDERS_TEMP 
    MODIFY COLUMN PICKUP_TIME DATE,
    MODIFY COLUMN DISTANCE FLOAT, 
    MODIFY COLUMN DURATION INT,
    MODIFY COLUMN CANCELLATION TEXT,
    MODIFY COLUMN ORDER_ID INT,
    MODIFY COLUMN RUNNER_ID INT;
    
-- ## QUERY 1: How many pizzas were ordered?
SELECT COUNT(ORDER_ID) FROM CUSTOMER_ORDERS;

-- ## QUERY 2: How many unique customer orders were made?
SELECT COUNT(DISTINCT(ORDER_ID)) FROM CUSTOMER_ORDERS;

-- ## QUERY 3: How many successful orders were delivered by each runner?
UPDATE RUNNER_ORDERS 
SET DURATION = NULL WHERE DURATION LIKE '%null'; -- UPDATE THE NULL VALUES WHERE WRITTEN IN TEXT

UPDATE RUNNER_ORDERS 
SET DISTANCE = NULL WHERE DURATION LIKE '%null'; -- UPDATE THE NULL VALUES WHERE WRITTEN IN TEXT

UPDATE RUNNER_ORDERS 
SET CANCELLATION = NULL WHERE CANCELLATION LIKE '%null'; -- UPDATE THE NULL VALUES WHERE WRITTEN IN TEXT

UPDATE RUNNER_ORDERS 
SET CANCELLATION = NULL WHERE CANCELLATION  = ""; -- UPDATE THE NULL VALUES WHERE CELL IS EMPTY

SELECT * FROM RUNNER_ORDERS;

SELECT 
	RUNNER_ID,
    COUNT(ORDER_ID)
FROM RUNNER_ORDERS
WHERE CANCELLATION IS NULL
GROUP BY RUNNER_ID; -- TOTAL SUCCESSFULL DELIVERED

-- (some ALTERNATIVE questions and answers)
SELECT * FROM runner_orders WHERE duration IS NOT NULL; -- ORDERS THAT DOES NOT CANCELLED AND DELIVERED SUCCESSFULLY
SELECT * FROM RUNNER_ORDERS WHERE CANCELLATION IS NULL; -- ORDERS THAT SUCCESSFULLY DELIVERED
SELECT * FROM RUNNER_ORDERS WHERE CANCELLATION IS NOT NULL; -- ORDERS THAT DOES NOT DELIVERED SUCCESSFULLY.

-- ## 4. How many of each type of pizza was delivered?
SELECT
	PIZZA_NAME,
    COUNT(C.PIZZA_ID) AS TOTAL_PIZZAS -- TOTAL ORDERED PIZZAS
FROM PIZZA_NAMES AS PN
JOIN CUSTOMER_ORDERS AS C
ON PN.PIZZA_ID = C.PIZZA_ID
JOIN RUNNER_ORDERS AS RO
ON RO.ORDER_ID = C.ORDER_ID
WHERE RO.DURATION IS NOT NULL -- SUCCESS DELIVERIES
GROUP BY PN.PIZZA_NAME;

-- ## QUERY 5: How many Vegetarian and Meatlovers were ordered by each customer?**
SELECT
	C.CUSTOMER_ID,
    PN.PIZZA_NAME,
    COUNT(C.PIZZA_ID) AS ORDER_COUNT
FROM CUSTOMER_ORDERS AS C
JOIN PIZZA_NAMES AS PN
ON PN.PIZZA_ID = C.PIZZA_ID
GROUP BY C.CUSTOMER_ID,PN.PIZZA_NAME
ORDER BY C.CUSTOMER_ID;



-- information
SHOW TABLES;

SELECT * FROM PIZZA_NAMES;
SELECT * FROM CUSTOMER_ORDERS;
SELECT * FROM PIZZA_RECIPES;
SELECT * FROM PIZZA_TOPPINGS;
SELECT * FROM RUNNER_ORDERS;
SELECT * FROM RUNNERS;



