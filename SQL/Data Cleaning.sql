-- Data Cleaning
================================================

-- Checking for null values in all tables 
SELECT *
FROM sales
WHERE sale_id IS NULL;

SELECT *
FROM stores
WHERE store_id IS NULL;

SELECT *
FROM products
WHERE product_id IS NULL;
-- There are no nulls in all tables

-- Checking for Duplicates in all tables   
SELECT 
    sale_id, 
    date, 
    store_id, 
    product_id, 
    units, 
    COUNT(*) AS total_count
FROM sales
GROUP BY 
    sale_id, 
    date, 
    store_id, 
    product_id, 
    units
HAVING COUNT(*) > 1;

SELECT
	store_name,
	COUNT(*) AS total_count
FROM stores
GROUP BY 1
HAVING COUNT(*) > 1

SELECT
	product_name,
	COUNT(*) AS total_count
FROM products
GROUP BY 1
HAVING COUNT(*) > 1
-- No Duplicates Found

	
--Standardizing  text values in store_name
UPDATE stores
SET store_name = LOWER(store_name);


-- Remove leading or trailing spaces if exists in products and stores table
UPDATE products
SET product_name = TRIM(product_name);


UPDATE stores
SET store_name = TRIM(store_name);

UPDATE stores
SET store_city = TRIM(store_city);

UPDATE stores
SET store_location = TRIM(store_location);

