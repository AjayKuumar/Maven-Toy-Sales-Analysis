/*
--------------------------------------------------------------------
				Data Exploration for Mexico Toy Sales
--------------------------------------------------------------------


Research Questions
====================================================================
--> Identify the top 5 products with the highest units sold.
--> Calculate the profit margin (revenue - cost) for each store.
--> Show the stock availability for the top 5 best-selling products.
--> What are the top 5 Stores by Product Category Sales
--> Sales Trend Over Time
--> Calculate Year-Over-Year Sales Growth percentage
--> Which product categories drive the biggest profits? Is this the same across store locations?
--> Are sales being lost with out-of-stock products at certain locations?

*/


-- Key Metrics : -
-- ============================================

-- Calculate the total revenue generated 
SELECT 
    ROUND(CAST(SUM(units * product_price) AS numeric), 2) AS total_revenue
FROM sales AS s
JOIN products AS p
ON s.product_id = p.product_id;

-- Calculate the total cost of goods
SELECT 
    ROUND(CAST(SUM(units * product_cost) AS numeric), 2) AS total_cogs
FROM sales AS s
JOIN products AS p
ON s.product_id = p.product_id;

-- Calculate the total profit
SELECT 
    ROUND(CAST(SUM(units * (product_price - product_cost)) AS numeric), 2) AS total_profit
FROM sales AS s
JOIN products AS p
ON s.product_id = p.product_id;

-- Calculate the total units sold
SELECT
	SUM(units) AS total_units_sold
FROM sales;

-- Calculate the avg units sold per day
SELECT 
	ROUND(CAST(AVG(units) AS numeric), 2) AS avg_units
FROM sales;


-- Find the average price for each product category.
SELECT
	product_category,
	ROUND(CAST(AVG(product_price) AS numeric), 2) AS avg_price
FROM products
GROUP BY product_category;


-- List the stock on hand for each store.
SELECT
	store_id,
	SUM(stock_on_hand) AS total_stock
FROM inventory
GROUP BY store_id
ORDER BY store_id;


-- Get the total number of sales transactions.
SELECT
	COUNT(sale_id) AS total_sales
FROM sales;


-- Number of units Sold per Day
SELECT
	date,
	SUM(units) AS total_units_sold
FROM sales
GROUP BY date
ORDER BY date;


-- DATA ANALYSIS
-- ==================================================

-- Identify the top 5 products with the highest units sold.

SELECT
	s.product_id,
	pr.product_name,
	SUM(s.units) AS total_units_sold
FROM sales AS s 
JOIN products AS pr
ON s.product_id = pr.product_id
GROUP BY s.product_id , pr.product_name
ORDER BY SUM(s.units) DESC
LIMIT 5;

-- Color Buds & PlayDoh Can are best selling products with over 1 lakh units sold each


--  Calculate the total revenue (units sold * product price) per store.

SELECT
	s.store_id,
	ROUND(CAST(SUM(s.units*pr.product_price) AS numeric), 0) AS total_revenue
FROM sales AS s 
JOIN products AS pr
ON s.product_id = pr.product_id
GROUP BY s.store_id
ORDER BY ROUND(CAST(SUM(s.units*pr.product_price) AS numeric), 2) DESC;




-- Show the stock availability for the top 5 best-selling products.

SELECT
	inv.product_id,
	SUM(stock_on_hand) AS total_stock_available
FROM inventory AS inv
GROUP BY product_id
HAVING product_id IN (
	SELECT
		s.product_id
	FROM sales AS s 
	JOIN products AS pr
	ON s.product_id = pr.product_id
	GROUP BY s.product_id
	ORDER BY SUM(s.units) DESC
	LIMIT 5
);

-- The stocks for top selling products are not low which indicates overall sales are not effected by stock availability 


-- What are the top 5 Stores for each  Product Category sales

SELECT
	product_category,
	store_name,
	total_units_sold
FROM(
	SELECT
		product_category,
		store_name,
		SUM(sa.units) AS total_units_sold,
		ROW_NUMBER() OVER(PARTITION BY product_category ORDER BY SUM(sa.units) DESC) AS tn_rank
	FROM sales AS sa
	JOIN products AS pr
	ON sa.product_id = pr.product_id
	JOIN stores AS st
	ON sa.store_id = st.store_id
	GROUP BY product_category, store_name

)
WHERE tn_rank <= 5;


-- Sales Trend Over Time: Show the total units sold per month.
SELECT
	EXTRACT(MONTH FROM date) AS sales_month,
	TO_CHAR(date, 'Month') AS month_name,
	SUM(units) AS total_units_sold
FROM sales
GROUP BY sales_month, month_name
ORDER BY sales_month;

-- Sales are highest in the summer season (March - July) as it is the children's favourite season.


--> Calculate Year-Over-Year Sales Growth percentage
SELECT 
	EXTRACT(YEAR FROM date) AS sales_year, 
    SUM(units) AS total_units_sold,
    LAG(SUM(units)) OVER (ORDER BY EXTRACT(YEAR FROM date)) AS previous_year_sales,
    ROUND((SUM(units) - LAG(SUM(units)) OVER (ORDER BY EXTRACT(YEAR FROM date))) * 100.0 / LAG(SUM(units)) OVER (ORDER BY EXTRACT(YEAR FROM date)),2) AS percentage_growth
FROM sales
GROUP BY EXTRACT(YEAR FROM date)
ORDER BY sales_year;



-- Are sales being lost with out-of-stock products at certain locations?
-- Finding top 10 product sales in each locations
SELECT
	store_id,
	product_id,
	total_units_sold
FROM(
	SELECT
		sa.store_id,
		product_id,
		SUM(units) AS total_units_sold,
		ROW_NUMBER() OVER(PARTITION BY sa.store_id ORDER BY SUM(units) DESC) AS city_rank
	FROM sales AS sa
	GROUP BY sa.store_id,sa.product_id
)
WHERE city_rank <= 10;

-- Dividing the stocks into 3 groups HIGH(1), MEDIUM(2), LOW(3)
SELECT
	*,
	CASE NTILE(3) OVER(PARTITION BY store_id ORDER BY stock_on_hand DESC)
		WHEN 1 THEN 'HIGH'
		WHEN 2 THEN 'MEDIUM'
		WHEN 3 THEN 'LOW'
	END AS stock_status
FROM inventory;


-- Joining both the table to know whether top sales products in the city has High stock available or not
SELECT
	city_top_sales.store_id,
	city_top_sales.product_id,
	city_top_sales.total_units_sold,
	stock_status
FROM (
	SELECT
		store_id,
		product_id,
		total_units_sold
	FROM(
		SELECT
			sa.store_id,
			product_id,
			SUM(units) AS total_units_sold,
			ROW_NUMBER() OVER(PARTITION BY sa.store_id ORDER BY SUM(units) DESC) AS city_rank
		FROM sales AS sa
		GROUP BY sa.store_id,sa.product_id
	)
	WHERE city_rank <= 10
) AS city_top_sales
JOIN (
	SELECT
		*,
		CASE NTILE(3) OVER(PARTITION BY store_id ORDER BY stock_on_hand DESC)
			WHEN 1 THEN 'HIGH'
			WHEN 2 THEN 'MEDIUM'
			WHEN 3 THEN 'LOW'
		END AS stock_status
	FROM inventory
) AS inv_rank
ON city_top_sales.store_id = inv_rank.store_id
AND city_top_sales.product_id = inv_rank.product_id
WHERE stock_status = 'LOW';
-- Out of 500 top 10 selling products in various location 78 have low stock available
-- About 16% of top product sales are being lost beacuse of less stock available.


--> Which product categories drive the biggest profits? Is this the same across store locations?
SELECT
	product_category,
	SUM((s.units*product_price) - (s.units*product_cost)) AS total_profit
FROM sales AS s
JOIN products AS p
ON s.product_id = p.product_id
GROUP BY product_category
ORDER BY SUM((s.units*product_price) - (s.units*product_cost)) DESC
LIMIT 1;
-- Toys is the biggest profit driving category


SELECT
	store_location,
	product_category AS top_selling_category,
	profit
FROM (
	SELECT
		*,
		ROW_NUMBER() OVER(PARTITION BY store_location ORDER BY profit DESC) AS profit_rank
	FROM (
		SELECT
			st.store_location,
			p.product_category,
			SUM((s.units*product_price) - (s.units*product_cost)) AS profit
		FROM sales AS s
		JOIN products AS p
		ON s.product_id = p.product_id
		JOIN stores AS st
		ON s.store_id = st.store_id
		GROUP BY st.store_location , p.product_category
	)
) WHERE profit_rank = 1 ;
-- Whereas, In two locations toys remains biggest profit driving category and in other two locations Electronics is the biggest profit driving category
