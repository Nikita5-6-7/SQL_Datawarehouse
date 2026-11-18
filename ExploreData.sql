USE DataWarehouse;

/*===========================Explore the Rang==================================================*/

SELECT * FROM gold.fact_sales;
SELECT 
	DATEDIFF(DAY, MIN(order_date), MAX(order_date)) AS Day_Difference	
FROM gold.fact_sales;

SELECT 
	MIN(order_date) AS Start_Date,
	MAX(order_date) AS End_Date,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS month_Difference
FROM gold.fact_sales;

/*======================================================================*/

SELECT * FROM gold.dim_customers;

SELECT 
	DATEDIFF(year, MIN(birthdate),  GETDATE()) AS OldestAge,
	DATEDIFF(year, MAX(birthdate),  GETDATE()) AS youngestAge
FROM gold.dim_customers;

/*=====================OR==================================*/

SELECT 
    DATEDIFF(year, MIN(birthdate), GETDATE()) - 
        CASE WHEN DATEADD(year, DATEDIFF(year, MIN(birthdate), GETDATE()), MIN(birthdate)) > GETDATE() THEN 1 ELSE 0 END AS OldestAge,
    DATEDIFF(year, MAX(birthdate), GETDATE()) - 
        CASE WHEN DATEADD(year, DATEDIFF(year, MAX(birthdate), GETDATE()), MAX(birthdate)) > GETDATE() THEN 1 ELSE 0 END AS YoungestAge
FROM gold.dim_customers;

/*==============================================================
    Measure Exoloration
================================================================*/

--Total Sales
--Total Quantity sold
--Average Selling Price
--Number of Orders and Products
--Total Customers

SELECT * FROM gold.fact_sales;

SELECT 
	SUM(total_sales) AS Total_Sales,
	SUM(quantity) AS Total_Quantity,
	AVG(price) AS AvgPrice,
	COUNT(DISTINCT (order_number)) AS Orders,
	COUNT(DISTINCT (product_key)) AS Products,
	COUNT(DISTINCT (customer_key)) AS customers
FROM gold.fact_sales;
/*=============================-- Business KPI Report=======================*/
SELECT
    'Total sales' AS measure_name,
    SUM(total_sales) AS measure_value
FROM gold.fact_sales

UNION ALL

SELECT
    'Total Quantity',
    SUM(quantity)
FROM gold.fact_sales

UNION ALL

SELECT
    'Average Price',
    AVG(price)
FROM gold.fact_sales

UNION ALL

SELECT
    'Total Products',
    COUNT(DISTINCT product_key)
FROM gold.fact_sales

UNION ALL

SELECT
    'Total Customers',
    COUNT(DISTINCT customer_key)
FROM gold.fact_sales

UNION ALL

SELECT
    'Total Orders',
    COUNT(DISTINCT order_number)
FROM gold.fact_sales;


/*=======================================================================
Magnitude Analysis

-- Customers by Country
-- Customer by Gender
-- Products by Category
-- Average Cost by Category
-- Revenue By Category (JOIN fact_sales with dim_products)
-- Revenue by Customer ( JOIN fact_sales with dim_customers)

============================================================================*/

SELECT TOP 2 * FROM gold.dim_products;
SELECT TOP 2 * FROM gold.fact_sales;
SELECT TOP 2 * FROM gold.dim_customers

-- Products by Category
SELECT 
    product_name,
    category
FROM gold.dim_products
WHERE category IS NOT NULL
GROUP BY product_name,category;

--Average Cost by Category

SELECT 
    category,
    AVG(cost) AS AvgCost
FROM gold.dim_products
GROUP BY category;


-- Customers by Country
-- Customer by Gender
SELECT 
    COUNT(DISTINCT(customer_key)) AS customer,
    country,
    gender
FROM gold.dim_customers
GROUP BY country, gender;


/*==========================================================================
    Revenue By Category (JOIN fact_sales with dim_products)
===========================================================================*/
SELECT 
    gp.category,
    CAST(SUM(gfs.total_sales) AS DECIMAL(18,2)) AS Revenue
FROM gold.fact_sales AS gfs
LEFT JOIN gold.dim_products AS gp
    ON gp.product_key = gfs.product_key
 GROUP BY gp.category
 ORDER BY Revenue;

/*=============================================================================
    Revenue by Customer ( JOIN fact_sales with dim_customers)
================================================================================*/
 SELECT 
    gc.customer_key,
    CONCAT(gc.first_name, ' ' ,gc.last_name) AS Customer_Name ,
    CAST(SUM(gfs.total_sales) AS DECIMAL(18,2)) AS Revenue
FROM gold.fact_sales AS gfs
LEFT JOIN gold.dim_customers AS gc
    ON gfs.customer_key = gc.customer_key
GROUP BY gc.customer_key,
           gc.first_name,
           gc.last_name
ORDER BY Revenue DESC;

/*============================================================================
    Top 5 Product by Revenue (Group by and Rank())
 ==========================================================================*/   
---Using RANK()

WITH ProductRevenue AS (
    SELECT 
        gp.product_name,
        SUM(CAST(gfs.total_sales AS DECIMAL(18,2))) AS Revenue,
        RANK() OVER (ORDER BY SUM(gfs.total_sales) DESC) AS SalesRank
    FROM gold.fact_sales AS gfs
    LEFT JOIN gold.dim_products AS gp
        ON gp.product_key = gfs.product_key
    GROUP BY gp.product_key,gp.product_name
)
SELECT 
    product_name,
    Revenue
FROM ProductRevenue
WHERE SalesRank <= 5
ORDER BY SalesRank;

-- Using GROUP BY

 SELECT top 5
        gp.product_key,
        gp.product_name,
        SUM(CAST(gfs.total_sales AS DECIMAL(18,2))) AS Revenue
        --RANK() OVER (ORDER BY SUM(gfs.total_sales) DESC) AS SalesRank
    FROM gold.fact_sales AS gfs
    LEFT JOIN gold.dim_products AS gp
        ON gp.product_key = gfs.product_key
    GROUP BY 
        gp.product_key,
        gp.product_name
    ORDER BY Revenue DESC;


/*=======================================================================
    Worst Products
=========================================================================*/

SELECT  top 5
        gp.product_name,
        SUM(CAST(gfs.total_sales AS DECIMAL(18,2))) AS Revenue,
        RANK() OVER (ORDER BY SUM(gfs.total_sales) DESC) AS SalesRank
    FROM gold.fact_sales AS gfs
    LEFT JOIN gold.dim_products AS gp
        ON gp.product_key = gfs.product_key
    GROUP BY 
        gp.product_name
    ORDER BY Revenue ASC;

/*=======================================================
    Top 10 Customers
======================================================*/

 SELECT TOP 10
    CONCAT(gc.first_name, ' ' ,gc.last_name) AS Customer_Name ,
    CAST(SUM(gfs.total_sales) AS DECIMAL(18,2)) AS Revenue,
    RANK() OVER (ORDER BY SUM(gfs.total_sales) DESC) AS SalesRank
FROM gold.fact_sales AS gfs
LEFT JOIN gold.dim_customers AS gc
    ON gfs.customer_key = gc.customer_key
GROUP BY gc.customer_key,
           gc.first_name,
           gc.last_name
ORDER BY Revenue DESC;

/*========================================================================
    Customers with fewest Orders
=====================================================================*/

WITH CustomerOrders AS (
    SELECT 
        CONCAT(gc.first_name, ' ' ,gc.last_name) AS Customer_Name ,
        COUNT(DISTINCT gfs.order_number) AS TotalOrders,
        DENSE_RANK() OVER (ORDER BY COUNT(DISTINCT gfs.order_number) ASC) AS OrderRank
    FROM gold.dim_customers AS gc
    LEFT JOIN gold.fact_sales AS gfs
        ON gc.customer_key = gfs.customer_key
    GROUP BY gc.first_name,gc.last_name
)
SELECT 
    Customer_Name,
    TotalOrders
FROM CustomerOrders
WHERE OrderRank <= 5
ORDER BY OrderRank, Customer_Name;

