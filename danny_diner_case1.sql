CREATE DATABASE dannys_diner;
-- SET search_path = dannys_diner;
USE dannys_diner;

show tables;

CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 
select * from sales;
CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

--
show tables;
select * from sales;
select * from menu;
select * from members;

-- query 1: What is the total amount each customer spent at the restaurant?
select 
	s.customer_id as customers,
    sum(m.price) as total_spent
from sales as s 
join menu as m
on s.product_id = m.product_id
group by s.customer_id;

-- query 2: How many days has each customer visited the restaurant?
SELECT
	CUSTOMER_ID, 
    COUNT(DISTINCT ORDER_DATE) AS VISITED_DATE
FROM SALES
GROUP BY CUSTOMER_ID;

-- query 3:: What was the first item from the menu purchased by each customer?
WITH FLAG_MARK AS (
	SELECT
		S.*,
		M.PRODUCT_NAME,
		DENSE_RANK() OVER(PARTITION BY CUSTOMER_ID ORDER BY S.ORDER_DATE) AS RANK_ORDER
	FROM SALES AS S
	JOIN MENU AS M
	ON S.PRODUCT_ID = M.PRODUCT_ID)
SELECT 
	CUSTOMER_ID, 
    PRODUCT_NAME
FROM FLAG_MARK
WHERE RANK_ORDER = 1
GROUP BY CUSTOMER_ID,PRODUCT_NAME;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT
		M.PRODUCT_NAME,
        count(S.PRODUCT_ID) AS MOST_PURCHASED
FROM SALES AS S
JOIN MENU AS M
ON S.PRODUCT_ID = M.PRODUCT_ID
GROUP BY M.PRODUCT_NAME
ORDER BY MOST_PURCHASED DESC;


-- 5. Which item was the most popular for each customer?
WITH PURCHASE_HISTORY AS (SELECT	
		S.CUSTOMER_ID AS CUSTOMERS,
		M.PRODUCT_NAME AS PRODUCTS,
        count(S.PRODUCT_ID) AS PURCHASED_COUNT,
        DENSE_RANK() OVER(PARTITION BY S.CUSTOMER_ID ORDER BY count(S.PRODUCT_ID) DESC)  AS MOST_PURCHASED
FROM SALES AS S
JOIN MENU AS M
ON S.PRODUCT_ID = M.PRODUCT_ID
GROUP BY S.CUSTOMER_ID, M.PRODUCT_NAME)
SELECT
	CUSTOMERS,
	PRODUCTS,
    PURCHASED_COUNT,
    MOST_PURCHASED
FROM PURCHASE_HISTORY
WHERE MOST_PURCHASED = 1;

-- INSIGHT: Each user may have more than 1 favourite item.

-- ## QUERY 6. Which item was purchased first by the customer after they became a member?
with first_order_after_join as (select 
	s.*,
    m.join_date,
    mn.product_name,
    row_number() over(partition by s.customer_id) AS ORDERS_LIST
from sales as s
join members as m
on s.customer_id = m.customer_id
join menu as mn 
on s.product_id = mn.product_id
where s.order_date >m.join_date)
SELECT CUSTOMER_ID, PRODUCT_ID, product_name, order_date
FROM first_order_after_join
WHERE ORDERS_LIST = 1;

-- ## QUERY 7. Which item was purchased just before the customer became a member?
with orders_before_join as (
select 
	s.*,
    m.join_date,
    mn.product_name,
    row_number() over(partition by s.customer_id) AS ORDERS_LIST
from sales as s
join members as m
on s.customer_id = m.customer_id
join menu as mn 
on s.product_id = mn.product_id
where s.order_date < m.join_date)
select customer_id, product_name
from orders_before_join
where ORDERS_LIST=1;

-- ## QUERY 8. What is the total items and amount spent for each member before they became a member?

select 
	s.customer_id,
    count(s.product_id) as total_items,
    sum(mn.price) as total_paid
from sales as s
join members as m
on s.customer_id = m.customer_id
join menu as mn 
on s.product_id = mn.product_id
where s.order_date < m.join_date
group by s.customer_id;

-- ## Query 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
with updated_price_points as(
	select
		mn.product_id,
		mn.product_name,
		case
			when product_id = 1 then mn.price*20
			else price*10
		end as points -- each 1$ -> 10 points, for each sushi 20 points
	from menu as mn
)
select 
	s.customer_id,
    sum(points)  as total_points
from updated_price_points
join sales as s
on s.product_id = updated_price_points.product_id
group by s.customer_id;

-- ## Query 10: In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi — how many points do customer A and B have at the end of January?
WITH points_table AS (
    SELECT
        s.customer_id AS ids,
        s.order_date,
        mn.price,
        m.join_date,
        CASE 
            -- Rule 1: First week (including join date) gets 2x
            WHEN s.order_date >= m.join_date 
                 AND s.order_date <= DATE_ADD(m.join_date, INTERVAL 6 DAY) THEN mn.price * 20
            -- Rule 2: Sushi always gets 2x
            WHEN mn.product_name = 'sushi' THEN mn.price * 20
            -- Rule 3: Everything else 1x
            ELSE mn.price * 10
        END AS points
    FROM sales AS s
    JOIN menu AS mn -- Ensure this matches your table name 'manu'
        ON mn.product_id = s.product_id
    JOIN members AS m
        ON m.customer_id = s.customer_id
    WHERE s.order_date BETWEEN '2021-01-01' AND '2021-01-31' 
      AND s.customer_id != 'C'
)
SELECT 
    ids, 
    SUM(points) AS total_points 
FROM points_table
GROUP BY ids;


--
select * from sales;
select * from menu;
select * from members;
 