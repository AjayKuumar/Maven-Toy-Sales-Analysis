--  Careating Products Table
CREATE TABLE products(
product_id INT PRIMARY KEY,
product_name VARCHAR(30) NOT NULL,
product_category VARCHAR(25),
product_cost FLOAT NOT NULL,
product_price FLOAT NOT NULL
);

SELECT *
FROM products;


-- Craeting Stores Table
CREATE TABLE stores(
store_id INT PRIMARY KEY,
store_name VARCHAR(35) NOT NULL,
store_city VARCHAR(25) NOT NULL,
store_location VARCHAR(15) NOT NULL,
store_open_date DATE
);

SELECT *
FROM stores;


-- Creating Sales Table
CREATE TABLE sales(
sale_id INT PRIMARY KEY,
date DATE,
store_id INT,
product_id INT,
units INT,
CONSTRAINT fk_stores FOREIGN KEY (store_id) REFERENCES stores(store_id),
CONSTRAINT fk_products FOREIGN KEY (product_id) REFERENCES products(product_id)
);

SELECT *
FROM sales;


-- Creating Inventory Table
CREATE TABLE inventory(
store_id INT,
product_id INT,
stock_on_hand INT,
CONSTRAINT fk_stores_inv FOREIGN KEY (store_id) REFERENCES stores(store_id),
CONSTRAINT fk_products_inv FOREIGN KEY (product_id) REFERENCES products(product_id)
);

SELECT *
FROM inventory;

-- Creating Calendar Table
CREATE TABLE calendar(
date_column DATE
);

SELECT *
FROM calendar;


-- Importing data into products table
-- Importing data into stores table
-- Importing data into sales table
-- Importing data into inventory table
-- Importing data into calendar table