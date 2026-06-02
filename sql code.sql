-- creating a database--
create database project;

-- for creating table --
create table train(
Row_ID int primary key,	
Order_ID  varchar(50),
Order_Date date,
Ship_Date date,	
Ship_Mode varchar(50),
Customer_ID varchar(50),
Customer_Name varchar(100),
Segment varchar(50),
Country	varchar(50),
City varchar(50),
State varchar(50),
Postal_Code	int,
Region varchar(50),
Product_ID	varchar(50),
Category varchar(50),	
Sub_Category varchar(50),	
Product_Name varchar(255),	
Sales float
);

-- to know where to put your excel csv file so mysql accepts it -- 
SELECT @@secure_file_priv;

 -- to show how table is design --
 -- it is used to check column names,data types,column order --
 -- use this before importing csv,writing queries,debugging errors --   
 DESC train;
 
-- to modify data in a table --
ALTER TABLE train MODIFY postal_code VARCHAR(20);

ALTER TABLE train MODIFY Sales DECIMAL(10,5);

ALTER TABLE train MODIFY Row_ID INT AUTO_INCREMENT;

-- use in case of errors like column mismatch,truncation,wrong data type,duplicate issues --
-- this is for debugging or understanding csv structure --
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 9.3/Uploads/train.csv'
INTO TABLE train
FIELDS TERMINATED BY ','
IGNORE 1 LINES
(@c1,@c2,@c3,@c4,@c5,@c6,@c7,@c8,@c9,@c10,@c11,@c12,@c13,@c14,@c15,@c16,@c17,@c18);

-- to insert a excel file into the created table --
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 9.3/Uploads/train.csv'
INTO TABLE train
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
Row_ID,Order_ID,@Order_Date,@Ship_Date,Ship_Mode,Customer_ID,Customer_Name,Segment,Country,City,State,
Postal_Code,Region,Product_ID,Category,Sub_Category,Product_Name,@Sales
)
SET 
Order_Date = STR_TO_DATE(@Order_Date, '%d-%m-%Y'),
Ship_Date  = STR_TO_DATE(@Ship_Date, '%d-%m-%Y'),
Sales = REPLACE(REPLACE(@Sales, ',', ''), '$', '');

-- used to identify rows with missing data (NULL values) --
SELECT *
FROM train
WHERE row_id is null or
    order_id IS NULL or
    order_id is null or
     ship_date IS NULL or
    ship_mode IS NULL or
    customer_id is null or
    customer_name is null or
    segment is null or
    country is null or
    city is null or
    state is null or
    postal_code is null or
    region is null or
    product_id is null or
    category is null or
    sub_category is null or
    product_name is null or
    sales is null;
    
-- for counting no.of rows in a table--
select count(*) from train;

-- used to count how many missing values (NULLs) exist in each column --
SELECT 
    SUM(CASE WHEN row_id IS NULL THEN 1 ELSE 0 END) AS col1_nulls,
    SUM(CASE WHEN Order_ID IS NULL THEN 1 ELSE 0 END) AS col2_nulls,
    SUM(CASE WHEN Order_Date IS NULL THEN 1 ELSE 0 END) AS col3_nulls,
    SUM(CASE WHEN Ship_date IS NULL THEN 1 ELSE 0 END) AS col4_nulls,
    SUM(CASE WHEN ship_mode IS NULL THEN 1 ELSE 0 END) AS col5_nulls,
    SUM(CASE WHEN customer_ID IS NULL THEN 1 ELSE 0 END) AS col6_nulls,
    SUM(CASE WHEN customer_name IS NULL THEN 1 ELSE 0 END) AS col7_nulls,
    SUM(CASE WHEN segment IS NULL THEN 1 ELSE 0 END) AS col8_nulls,
    SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS col9_nulls,
    SUM(CASE WHEN city IS NULL THEN 1 ELSE 0 END) AS col10_nulls,
    SUM(CASE WHEN state IS NULL THEN 1 ELSE 0 END) AS col11_nulls,
    SUM(CASE WHEN postal_code IS NULL THEN 1 ELSE 0 END) AS col12_nulls,
    SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) AS col13_nulls,
    SUM(CASE WHEN sub_category IS NULL THEN 1 ELSE 0 END) AS col4_nulls,
    SUM(CASE WHEN product_name IS NULL THEN 1 ELSE 0 END) AS col15_nulls,
    SUM(CASE WHEN sales IS NULL THEN 1 ELSE 0 END) AS col16_nulls
    FROM train;

-- used to find duplicate records based on a specific column --
SELECT *
FROM train 
WHERE row_id IN (
    SELECT row_id
    FROM train
    GROUP BY row_id
    HAVING COUNT(*) > 1
);

-- used to detect duplicate records in your table --
SELECT Row_ID,Order_ID,Order_Date,Ship_Date,Ship_Mode,Customer_ID,Customer_Name,Segment,Country,City,State,
Postal_Code,Region,Product_ID,Category,Sub_Category,Product_Name,Sales, COUNT(*) AS cnt
FROM train
GROUP BY Row_ID,Order_ID,Order_Date,Ship_Date,Ship_Mode,Customer_ID,Customer_Name,Segment,Country,City,State,
Postal_Code,Region,Product_ID,Category,Sub_Category,Product_Name,Sales
HAVING COUNT(*) > 1;

-- used to find duplicate records, but it’s a more advanced and practical method compared to GROUP BY --
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY Row_ID,Order_ID,Order_Date,Ship_Date,Ship_Mode,Customer_ID,Customer_Name,Segment,Country,City,State,
Postal_Code,Region,Product_ID,Category,Sub_Category,Product_Name,Sales
               ORDER BY  row_id
           ) AS rn
    FROM train
) t
WHERE rn > 1;

-- revoming duplicate records --
DELETE FROM train
WHERE row_id IN (
    SELECT row_id
    FROM (
        SELECT row_id,
               ROW_NUMBER() OVER (
                   PARTITION BY Order_ID, Product_ID
                   ORDER BY row_id
               ) AS rn
        FROM train
    ) t
    WHERE rn > 1
);

-- create final clean dataset --
CREATE TABLE clean_train AS
SELECT *
FROM train
WHERE sales IS NOT NULL;

-- calculate total sales --
SELECT SUM(sales) AS total_sales
FROM train;

-- calculate total profit --
SELECT SUM(sales - cost) AS total_profit
FROM train;

-- if there is no profit column then --
SELECT SUM(sales * 0.20) AS estimated_profit
FROM train;

-- finding profit_margin --
SELECT 
    (SUM(sales * 0.20) / SUM(sales)) * 100 AS profit_margin_percentage
FROM train;

-- finding quantity sold but there is no quantity column so we cannot find --
SELECT SUM(quantity) AS total_quantity_sold
FROM train;

-- count number of orders --
SELECT COUNT(*) AS total_orders
FROM train;

-- finding average order value --
SELECT 
    SUM(sales) / COUNT(DISTINCT order_id) AS average_order_value
FROM train;

-- Which are the Top 10 products by sales --
SELECT 
    product_name,
    SUM(sales) AS total_sales
FROM train
GROUP BY product_name
ORDER BY total_sales DESC
LIMIT 10;

-- Which products are making losses (lowest selling prices) --
SELECT 
    product_name,
    SUM(sales) AS total_sales
FROM train
GROUP BY product_name
ORDER BY total_sales ASC
LIMIT 10;

-- Which region/state/city has the highest sales --
-- reason with highest sales --
SELECT 
    region,
    SUM(sales) AS total_sales
FROM train
GROUP BY region
ORDER BY total_sales DESC
LIMIT 1;

-- state with highest sales --
SELECT 
    state,
    SUM(sales) AS total_sales
FROM train
GROUP BY state
ORDER BY total_sales DESC
LIMIT 1;

-- city with highest sales --
SELECT 
    city,
    SUM(sales) AS total_sales
FROM train
GROUP BY city
ORDER BY total_sales DESC
LIMIT 1;

-- Which region/state/city has the lowest sales --
-- region with lowest sales --
SELECT 
    region,
    SUM(sales) AS total_sales
FROM train
GROUP BY region
ORDER BY total_sales ASC
LIMIT 1;

-- state with lowest sales --
SELECT 
    state,
    SUM(sales) AS total_sales
FROM train
GROUP BY state
ORDER BY total_sales ASC
LIMIT 1;

-- city with lowest sales --
SELECT 
    city,
    SUM(sales) AS total_sales
FROM train
GROUP BY city
ORDER BY total_sales ASC
LIMIT 1;

-- Which category/sub-category contributes the most profit --
-- category with highest sales --
SELECT 
    category,
    SUM(sales) AS total_sales
FROM train
GROUP BY category
ORDER BY total_sales DESC
LIMIT 1;

-- sub-category with highest sales --
SELECT 
    sub_category,
    SUM(sales) AS total_sales
FROM train
GROUP BY sub_category
ORDER BY total_sales DESC
LIMIT 1;

-- Which months have the highest and lowest sales --
-- monthly sales analysis --
SELECT 
    MONTHNAME(order_date) AS month_name,
    SUM(sales) AS total_sales
FROM train
GROUP BY MONTH(order_date), MONTHNAME(order_date)
ORDER BY total_sales DESC;

-- month with highest sales --
SELECT 
    MONTHNAME(order_date) AS month_name,
    SUM(sales) AS total_sales
FROM train
GROUP BY MONTH(order_date), MONTHNAME(order_date)
ORDER BY total_sales DESC
LIMIT 1;

-- month with lowest sales --
SELECT 
    MONTHNAME(order_date) AS month_name,
    SUM(sales) AS total_sales
FROM train
GROUP BY MONTH(order_date), MONTHNAME(order_date)
ORDER BY total_sales ASC
LIMIT 1;

-- Identify seasonal trends in sales --
-- Monthly sales trend --
SELECT 
    MONTH(order_date) AS month_number,
    MONTHNAME(order_date) AS month_name,
    SUM(sales) AS total_sales
FROM train
GROUP BY MONTH(order_date), MONTHNAME(order_date)
ORDER BY month_number;

-- Quarterly sales Trend --
SELECT 
    QUARTER(order_date) AS quarter,
    SUM(sales) AS total_sales
FROM train
GROUP BY QUARTER(order_date)
ORDER BY quarter;

-- Yearly Sales Trend --
SELECT 
    YEAR(order_date) AS year,
    SUM(sales) AS total_sales
FROM train
GROUP BY YEAR(order_date)
ORDER BY year;

-- Month-over-Month-Trend --
SELECT 
    YEAR(order_date) AS year,
    MONTHNAME(order_date) AS month,
    SUM(sales) AS total_sales
FROM train
GROUP BY YEAR(order_date), MONTH(order_date), MONTHNAME(order_date)
ORDER BY YEAR(order_date), MONTH(order_date);