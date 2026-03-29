use flashcart_analytics;
select*from products;
truncate table orders;
drop table products;
alter table customers modify column join_date date;
CREATE TABLE products (
  product_id INT PRIMARY KEY,
  sku VARCHAR(20),
  product_name VARCHAR(50),
  brand VARCHAR(30),
  category VARCHAR(50),
  mrp DECIMAL(10,2),
  unit_cost DECIMAL(10,2),
  pack_size_g INT
);

CREATE TABLE temp_orders (
  order_id INT,
  order_date DATETIME
);
SHOW VARIABLES LIKE 'local_infile';

SET GLOBAL local_infile = 1;
LOAD DATA LOCAL INFILE 'C:/mysql_import/products.csv'
INTO TABLE product
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select*from product;
CREATE TABLE returns_refunds (
  return_id INT PRIMARY KEY,
  order_id INT,
  return_reason VARCHAR(50),
  refund_amount DECIMAL(12,2),
  return_status VARCHAR(20),
  FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE support_tickets (
  ticket_id INT PRIMARY KEY,
  order_id INT,
  ticket_type VARCHAR(30),
  ticket_status VARCHAR(20),
  csat_rating INT,
  FOREIGN KEY (order_id) REFERENCES orders(order_id)
);
CREATE TABLE delivery (
  delivery_id INT PRIMARY KEY,
  order_id INT,
  dark_store_id INT,
  delivery_type VARCHAR(20),
  delivery_time_min DECIMAL(10,1),
  late_delivery_flag INT,
  FOREIGN KEY (order_id) REFERENCES orders(order_id)
);
CREATE TABLE payments (
  payment_id INT PRIMARY KEY,
  order_id INT,
  payment_method VARCHAR(20),
  payment_status VARCHAR(20),
  paid_amount DECIMAL(12,2),
  FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

OPT_LOCAL_INFILE=1;
drop table delivery;
CREATE TABLE orders (
  order_id INT PRIMARY KEY,
  customer_id INT,
  order_datetime DATETIME,
  city VARCHAR(50),
  channel VARCHAR(20),
  order_status VARCHAR(20),
  coupon_code VARCHAR(20),
  discount_pct DECIMAL(10,4),
  gross_amount DECIMAL(12,2),
  cost_amount DECIMAL(12,2),
  discount_amount DECIMAL(12,2),
  net_amount DECIMAL(12,2),
  delivery_fee DECIMAL(10,2),
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
  );
  CREATE TABLE order_items (
  order_item_id INT PRIMARY KEY,
  order_id INT,
  product_id INT,
  quantity INT,
  unit_price_mrp DECIMAL(10,2),
  unit_cost DECIMAL(10,2),
  FOREIGN KEY (order_id) REFERENCES orders(order_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);
CREATE TABLE products (
  product_id INT PRIMARY KEY,
  sku VARCHAR(20),
  product_name VARCHAR(50),
  brand VARCHAR(30),
  category VARCHAR(50),
  mrp DECIMAL(10,2),
  unit_cost DECIMAL(10,2),
  pack_size_g INT
);

CREATE TABLE delivery (
  delivery_id INT PRIMARY KEY,
  order_id INT,
  dark_store_id INT,
  delivery_type VARCHAR(20),
  delivery_time_min DECIMAL(10,1),
  late_delivery_flag INT,
  FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE marketing_spend (
  spend_id INT PRIMARY KEY,
  month DATE,
  city VARCHAR(50),
  channel VARCHAR(30),
  spend_amount DECIMAL(12,2)
);

truncate customers;customers
use flashcart_analytics;
select*from products;
UPDATE products p
JOIN product pr
    ON p.product_id = pr.product_id
SET p.category = pr.categoryy;



use flashcart_analytics;

create view Q1 as
       SELECT round(SUM(net_amount + delivery_fee),2) AS total_revenue
        FROM orders
         WHERE order_status = 'Delivered';
   select*from orders;
--Q4 cancellation rate
alter view Q2 as select round(sum(net_amount - cost_amount),2) as total_profit from orders where order_status = 'Delivered' ;


create view Q4 as SELECT ROUND(
  100 * SUM(CASE WHEN order_status='Cancelled' THEN 1 ELSE 0 END) / COUNT(*),
  2
) AS cancellation_rate_pct
FROM orders;

select*from Q3;
ALTER TABLE orders
ADD COLUMN order_date DATETIME;

LIMIT 5;

select * from products;



UPDATE products p
JOIN product pr ON p.product_id = pr.product_id
SET p.category = pr.categoryy;

create view Q5 as SELECT DATE_FORMAT(order_date, '%Y-%m') AS month,
       ROUND(SUM(net_amount + delivery_fee), 2) AS revenue
FROM orders
WHERE order_status = 'Delivered'
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;
create view Q6 as select city as top_cities,
 ROUND(SUM(net_amount + delivery_fee), 2) AS revenue
 from orders WHERE order_status = 'Delivered'
GROUP BY city
ORDER BY revenue DESC
LIMIT 10;
create view Q7 as SELECT ROUND(AVG(net_amount + delivery_fee), 2) AS avg_order_value
FROM orders
WHERE order_status = 'Delivered';

select* from Q8;
CREATE VIEW Q8 AS
    SELECT 
        channel, ROUND(SUM(net_amount + delivery_fee), 2) AS revenue
    FROM
        orders
    WHERE
        order_status = 'Delivered'
    GROUP BY channel
    ORDER BY revenue DESC;

create view Q9 as SELECT 
  CASE 
    WHEN order_count = 1 THEN 'One-time'
    ELSE 'Repeat'
  END AS customer_type,
  COUNT(*) AS customers
FROM (
  SELECT customer_id, COUNT(*) AS order_count
  FROM orders
  WHERE order_status='Delivered'
  GROUP BY customer_id
) t
GROUP BY customer_type;

create view Q10 as SELECT 
  d.late_delivery_flag,
  COUNT(DISTINCT d.order_id) AS total_orders,
  COUNT(DISTINCT r.order_id) AS returned_orders,
  ROUND(100 * COUNT(DISTINCT r.order_id) / COUNT(DISTINCT d.order_id), 2) AS return_rate_pct
FROM delivery d
LEFT JOIN returns_refunds r
ON d.order_id = r.order_id
GROUP BY d.late_delivery_flag;


--Q11 top  product byy revenue
create view Q11 As SELECT p.product_name,
       ROUND(SUM(oi.quantity * oi.unit_price_mrp),2) AS revenue
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.order_status = 'Delivered'
GROUP BY p.product_name
ORDER BY revenue DESC
LIMIT 10;

--Q12 top 10 products by profits 
create view Q12 as 
SELECT p.product_name,
       ROUND(SUM(oi.quantity * (oi.unit_price_mrp - oi.unit_cost)),2) AS profit
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.order_status = 'Delivered'
GROUP BY (p.product_name)
ORDER BY profit DESC
LIMIT 10;

--Q13 loss making products
create view Q13 as 
SELECT p.product_name,
       ROUND(SUM(oi.quantity * (oi.unit_price_mrp - oi.unit_cost)),2) AS profit
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.order_status='Delivered'
GROUP BY p.product_name
HAVING profit < 0
ORDER BY profit;
select * from Q14;
--Q14Category-wise Revenue & Profit
create view Q14 as SELECT p.categoryy,
       ROUND(SUM(oi.quantity * oi.unit_price_mrp),2) AS revenue,
       ROUND(SUM(oi.quantity * (oi.unit_price_mrp - oi.unit_cost)),2) AS profit
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status='Delivered'
GROUP BY p.categoryy
ORDER BY revenue DESC;

--Q15 Customer Lifetime Value (CLV)
SELECT customer_id,
       ROUND(SUM(net_amount + delivery_fee),2) AS lifetime_value,
       COUNT(order_id) AS total_orders
FROM orders
WHERE order_status='Delivered'
GROUP BY customer_id;

--Q16) New vs Returning Customers (Monthly)
SELECT DATE_FORMAT(order_date,'%Y-%m') AS month,
       SUM(CASE WHEN order_rank=1 THEN 1 ELSE 0 END) AS new_customers,
       SUM(CASE WHEN order_rank>1 THEN 1 ELSE 0 END) AS returning_customers
FROM (
  SELECT customer_id, order_date,
         ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_datetime) AS order_rank
  FROM orders
  WHERE order_status='Delivered'
) t
GROUP BY month
ORDER BY month;


--Q17) Avg Delivery Time by City
SELECT o.city,
       ROUND(AVG(d.delivery_time_min),2) AS avg_delivery_time
FROM delivery d
JOIN orders o ON d.order_id = o.order_id
WHERE o.order_status='Delivered'
GROUP BY o.city
ORDER BY avg_delivery_time DESC;


--Q18) Dark Store Delay Analysis
SELECT dark_store_id,
       COUNT(*) AS total_orders,
       SUM(late_delivery_flag) AS late_orders,
       ROUND(100 * SUM(late_delivery_flag)/COUNT(*),2) AS late_pct
FROM delivery
GROUP BY dark_store_id
HAVING total_orders > 100
ORDER BY late_pct DESC;


--Q19) Monthly Revenue vs Marketing Spend
SELECT m.month_spend_month,
       ROUND(SUM(m.spend_amount),2) AS marketing_spend,
       ROUND(SUM(o.net_amount + o.delivery_fee),2) AS revenue
FROM marketing_spend m
LEFT JOIN orders o
ON m.city = o.city
AND DATE_FORMAT(o.order_date,'%Y-%m') = DATE_FORMAT(m.month_spend_month,'%Y-%m')
AND o.order_status='Delivered'
GROUP BY m.month_spend_month
ORDER BY m.month_spend_month;


--Q20) ROI by Marketing Channel
SELECT m.channel,
       ROUND(SUM(o.net_amount + o.delivery_fee),2) AS revenue,
       ROUND(SUM(m.spend_amount),2) AS spend,
       ROUND((SUM(o.net_amount + o.delivery_fee) - SUM(m.spend_amount)) / SUM(m.spend_amount),2) AS roi
FROM marketing_spend m
LEFT JOIN orders o
ON m.city=o.city
AND DATE_FORMAT(o.order_date,'%Y-%m')=DATE_FORMAT(m.month,'%Y-%m')
AND o.order_status='Delivered'
GROUP BY m.channel
ORDER BY roi DESC;

FROM marketing_spend m
LEFT JOIN orders o
ON m.city=o.city
AND DATE_FORMAT(o.order_date,'%Y-%m')=DATE_FORMAT(m.month,'%Y-%m')
AND o.order_status='Delivered'
GROUP BY m.channel
ORDER BY roi DESC;

SET GLOBAL local_infile = 1;
select* from temp;
create table temp ( spend_id int primary key , month date); 

CREATE TABLE product (
  product_id INT PRIMARY KEY,
  categoryy varchar(50));
select*from marketing_spend;
ALTER TABLE marketing_spend
ADD COLUMN month_spend_month DATE;
UPDATE marketing_spend m
JOIN temp t
  ON m.spend_id = t.spend_id
SET m.month_spend_month = t.months;
SELECT spend_id, month_spend_month
FROM marketing_spend
LIMIT 10;
