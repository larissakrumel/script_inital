create schema larissa;

CREATE table larissa.customers(
    customer_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    signup_date DATE NOT NULL,
    country TEXT NOT NULL
);


-- Products Table
CREATE TABLE larissa.products (
    product_id SERIAL PRIMARY KEY,
    product_name TEXT NOT NULL,
    category TEXT NOT NULL,
    price NUMERIC(10,2) NOT NULL
);

-- Orders Table
CREATE TABLE larissa.orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES larissa.customers(customer_id),
    order_date DATE NOT NULL,
    total_amount NUMERIC(10,2) NOT NULL
);

-- Order Details Table (Many-to-Many between Orders and Products)
CREATE TABLE larissa.order_details (
    order_id INT REFERENCES larissa.orders(order_id),
    product_id INT REFERENCES larissa.products(product_id),
    quantity INT NOT NULL,
    PRIMARY key (order_id, product_id)
);

CREATE TABLE larissa.shops (
    shop_id INT PRIMARY KEY,          
    shop_name VARCHAR(100) NOT NULL, 
    location VARCHAR(100) NOT NULL     
);

CREATE TABLE larissa.vendor (
    vendor_id INT PRIMARY KEY,          
    vendor_name VARCHAR(100) NOT NULL,
    contact_info VARCHAR(100)
);

INSERT INTO larissa.customers VALUES('101', 'ALICE', '2023-01-15', 'USA');
INSERT INTO larissa.customers VALUES('102', 'BOB', '2023-02-20', 'CANADA');
INSERT INTO larissa.customers VALUES('103', 'CHARLIE', '2023-03-05','USA');
INSERT INTO larissa.customers VALUES('104', 'DIANA', '2023-04-10','CANADA');

select * from larissa.customers;

INSERT INTO larissa.products VALUES('1', 'LAPTOP', 'ELETRONICS', '1000.00');
INSERT INTO larissa.products VALUES('2', 'PHONE', 'ELETRONICS', '700.00');
INSERT INTO larissa.products VALUES('3', 'SHOES', 'FASHION','150.00');
INSERT INTO larissa.products VALUES('4', 'T-SHIRT', 'FASHION','50.00');

select * from larissa.products;

INSERT INTO larissa.orders VALUES('1', '101', '2023-02-01', '1000.00');
INSERT INTO larissa.orders VALUES('2', '101', '2023-06-10', '700.00');
INSERT INTO larissa.orders VALUES('3', '102', '2023-03-01', '150.00');
INSERT INTO larissa.orders VALUES('4', '103', '2023-03-10', '700.00');
INSERT INTO larissa.orders VALUES('5', '103', '2023-05-15', '50.00');
INSERT INTO larissa.orders VALUES('6', '104', '2023-04-20', '1000.00');

select * from larissa.orders;


INSERT INTO larissa.order_details VALUES('1', '1', '1');
INSERT INTO larissa.order_details VALUES('2', '2', '1');
INSERT INTO larissa.order_details VALUES('3', '3', '1');
INSERT INTO larissa.order_details VALUES('4', '2', '1');
INSERT INTO larissa.order_details VALUES('5', '4', '1');
INSERT INTO larissa.order_details VALUES('6', '1', '1');

select * from larissa.order_details;

INSERT INTO larissa.shops (shop_id, shop_name, location)
VALUES
    (1, 'Loja A', 'Rua das Flores, 123'),
    (2, 'Loja B', 'Avenida Central, 456'),
    (3, 'Loja C', 'Praça da Liberdade, 789'),
    (4, 'Loja D', 'Rua do Mercado, 101');

select * from larissa.shops;

INSERT INTO larissa.vendor (vendor_id, vendor_name, contact_info)
VALUES
    (1, 'Piccola Baia', 'contato@picbaia.com'),
    (2, 'Grupo Panvel', 'vendas@grupopanvel.com'),
    (3, 'Italian Gourmet', 'suporte@italiangourmet.com'),
    (4, 'Dominos Pizzaria', 'relacionamento@dominos.com');

select * from larissa.vendor;

--- Challenge 1: Top-Selling Product 
--- Find the top 2 products by total sales revenue
select p.product_name, sum(p.price) + sum(o.total_amount) as TOTAL_REVENUE
from larissa.products p, larissa.orders o
where p.product_id = o.order_id
group by p.product_name
order by total_revenue DESC
limit 2;


--- Challenge 2: Repeat Customers ---
--- Find customers who have made more than one order and 
--- display the number of orders they placed

select c.customer_id, name, count(o.customer_id) as order_count
from larissa.customers c
join larissa.orders o
on c.customer_id = o.customer_id
group by c.customer_id
having count(o.customer_id) > 1;


--- Challenge 3: First Purchase Per Customer
--- For each customer, find their first order date and the total amount spent in that order

select distinct on (o.customer_id) 
o.customer_id, c.name, o.order_date as first_order, o.total_amount as amount_spent
from larissa.orders o
join larissa.customers c
on o.customer_id = c.customer_id
order by o.customer_id, o.order_date;

--- Challenge 4: Customer Lifetime Value (CLV)
--- Calculate each customer’s total lifetime value (total spending)

select c.name, c.customer_id, sum(total_amount) as total_spent
from larissa.customers c 
join larissa.orders o
on c.customer_id = o.customer_id
group by c.name, c.customer_id
order by c.customer_id;

--- Bonus Challenge: Sales Contribution by Category
--- Calculate the percentage contribution of each product category to total sales revenue.

select * from larissa.products;
select * from larissa.orders;
select * from larissa.order_details;

select category, sum(p.price * od.quantity) as total_revenue, 
		CONCAT(ROUND(sum(p.price * od.quantity) * 100 / (select sum (op.price * ox.quantity) total_sales
																	from larissa.order_details ox, 
																		 larissa.products op 
																	where ox.product_id = op.product_id), 2) , '%') PERCENTAGE
from larissa.products p
join larissa.order_details od 
on p.product_id = od.product_id
group by category
order by category;

select * from 
larissa.ORDER_DETAILS OD,
larissa.products p 	 		
where od.product_id  = p.product_id;

select sum (op.price * ox.quantity) total_sales
from larissa.order_details ox, 
	 larissa.products op 
where ox.product_id = op.product_id;

--- Assessment
--- Which customer has made the highest number of purchases?
select count (name) as orders_number, name
from larissa.customers c
join larissa.orders o 
on c.customer_id = o.customer_id
group by name
order by orders_number DESC
;

--- What is the average price of the products?
select avg(price)
from larissa.products p;

--- List the top 5 best-selling products
select count(o.product_id) as best_selling, p.product_name, p.product_id
from larissa.products p
join larissa.order_details o
on p.product_id = o.product_id
group by p.product_name, p.product_id, o.product_id
order by best_selling desc;

select * from larissa.order_details od

--- How many sales were made by each customer?
select count(o.customer_id) as quantity_sales, name, c.customer_id
from larissa.customers c 
join larissa.orders o 
on c.customer_id = o.customer_id
group by name, c.customer_id;

--- What is the average age of existing customers?
select avg(customer_id)
from larissa.customers;

select distinct on (product_id)
product_id, product_name
from larissa.products

--- Which shop has the highest sales revenue?
select * from larissa.shops;

--- Adicionando minha tabela shops na tabela de orders :D

ALTER TABLE larissa.orders
ADD COLUMN shop_id INT;

ALTER TABLE larissa.orders
ADD CONSTRAINT fk_shop
FOREIGN KEY (shop_id) REFERENCES larissa.shops(shop_id);

UPDATE larissa.orders
SET shop_id = 1
WHERE order_id = 1;

UPDATE larissa.orders
SET shop_id = 2
WHERE order_id = 2;

UPDATE larissa.orders
SET shop_id = 3
WHERE order_id = 3;

UPDATE larissa.orders
SET shop_id = 4
WHERE order_id = 4;

INSERT INTO larissa.shops (shop_id, shop_name, location)
VALUES 
    (5, 'Loja E', 'Rua da Estação, 202'),
    (6, 'Loja F', 'Avenida das Palmeiras, 303');

UPDATE larissa.orders
SET shop_id = 5
WHERE order_id = 5;

UPDATE larissa.orders
SET shop_id = 6
WHERE order_id = 6;

--- Which shop has the highest sales revenue?
select sum(total_amount) as highest_revenue, s.shop_name
from larissa.orders o 
join larissa.shops s 
on o.shop_id = s.shop_id
group by s.shop_name, total_amount
order by highest_revenue desc
limit 1;

--- List the shops with the lowest total sales
select total_amount, shop_name 
from larissa.orders o
join larissa.shops s
on o.shop_id = s.shop_id
group by total_amount, shop_name
order by total_amount asc;

--- What is the average sales revenue per shop?
select s.shop_name, 
ROUND(AVG(o.total_amount), 2) AS average_sales_revenue
from larissa.orders o 
join larissa.shops s 
on o.shop_id = s.shop_id
group by s.shop_name, total_amount
order by s.shop_name;

--- What is the total sales revenue for the current month?
SELECT 
EXTRACT(month FROM order_date) AS month,
ROUND(SUM(total_amount), 2) AS total_sales_revenue
FROM larissa.orders
WHERE EXTRACT(MONTH FROM order_date) = 4
GROUP BY month
ORDER BY month;

--- How many products have never been sold?
SELECT COUNT(*) AS products_never_sold
FROM larissa.products p
left JOIN larissa.order_details od 
ON p.product_id = od.product_id
WHERE od.product_id IS NULL;

--- What is the total profit margin for all sales?
ALTER TABLE larissa.products
ADD COLUMN cost_price NUMERIC(10,2) NOT NULL DEFAULT 0.00;

UPDATE larissa.products
SET cost_price = CASE product_id
    WHEN 1 THEN 15.00
    WHEN 2 THEN 10.00
    WHEN 3 THEN 20.00
    WHEN 4 THEN 5.00
END;

SELECT ROUND(SUM((p.price - p.cost_price) * od.quantity), 2) AS total_profit
FROM larissa.order_details od
JOIN larissa.products p 
ON od.product_id = p.product_id;

select * from larissa.customers
where country = 'CANADA';

select * from larissa.customers
where customer_id > 102;

select * from larissa.customers
where extract (month from signup_date) = 3;













