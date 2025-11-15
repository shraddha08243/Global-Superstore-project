create database if not exists indexing;
use indexing;
show tables;
rename table `global superstore 2018 _ csv format (1)` to superstore;
show tables;
describe superstore;

alter table superstore rename column `ï»¿Row ID` to row_id;
select*from superstore
order by row_id;

-- 1)
explain analyze
select *from superstore
where row_id =21550;
-- ->  (cost=409 rows=385) (actual time=16.8..19.9 rows=1 loops=1)

create index idx_row_id on superstore(row_id);

explain analyze
select *from superstore
where row_id =21550;  
-- -> (cost=0.35 rows=1) (actual time=0.0915..0.0995 rows=1 loops=1)
 show indexes from superstore;
describe superstore;
    
-- 2 ) find regionwise sales
explain analyze
select region,round(sum(sales),2)  as sale from superstore
group by region
order by sum(sales)desc;
-- ->  (actual time=20.1..20.1 rows=8 loops=1) (actual time=20..20 rows=8 loops=1)

create index idx_region 

on superstore (region(50));
explain analyze
select region,round(sum(sales),2)  as sale from superstore
group by region
order by sum(sales)desc;

show indexes from superstore;

explain analyze 
select*from superstore
where customer ='ea-140355' and region =' south amrica';

-- 3) creating a composite index
 create index idx_cust_region
 on superstore (region(50), `customer id`(30));
 explain analyze 
 select *from superstore
 where `customer id` ='ea-140355' and region =' south amrica';
 
 select *from superstore;
 show indexes from superstore;
 
 drop index idx_cust_region on superstore;
 
 
 
 -- exercise questions 
 -- 1) find the total revenue , quantities genrated
SELECT 
    SUM(Sales) AS Total_Revenue,
    SUM(Quantity) AS Total_Quantity
FROM superstore;

 -- 2) find the segment wise distribution of the sales
 SELECT segment,
(SUM(sales)) AS total_sales
FROM superstore
GROUP BY segment
ORDER BY total_sales DESC;
 
 -- 3)find the top 3 most profitable product 
SELECT 
    `Product Name` AS product_name,
    ROUND(SUM(profit), 2) AS total_profit
    FROM superstore
GROUP BY `Product Name`
ORDER BY total_profit DESC
LIMIT 3;

  -- 4) find how many ordeers are placed after 2016
  SELECT COUNT(*) AS total_orders_after_2016
  FROM superstore
WHERE YEAR(`Order Date`) > '2016-12-31';


  -- 5) how many states from austria are under the roof of business ?
SELECT 
    COUNT(DISTINCT state) AS total_states_in_austria
FROM superstore
WHERE country = 'Austria';
  
  -- 6) which products and and subcategories are most and least profitable
(SELECT 
`Sub-Category` AS sub_category,
`Product Name` AS product_name,
 SUM(Profit) AS total_profit
FROM superstore
GROUP BY `Sub-Category`, `Product Name`
ORDER BY total_profit DESC
LIMIT 5
)
UNION ALL
(
SELECT 
`Sub-Category` AS sub_category,
`Product Name` AS product_name,
SUM(Profit) AS total_profit
FROM superstore
GROUP BY `Sub-Category`, `Product Name`
ORDER BY total_profit ASC
 LIMIT 5
);
  
  -- 7) which coustomer segment contributes the most to the total revenue
SELECT segment,
SUM(sales) AS total_revenue
FROM superstore
GROUP BY segment
ORDER BY total_revenue DESC
LIMIT 1;
  
  -- 8) what is the year-over-year growth in sales and profit 
  SELECT 
    YEAR(`Order Date`) AS order_year,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Profit), 2) AS total_profit,
    ROUND(
        SUM(Sales) - LAG(SUM(Sales)) OVER (ORDER BY YEAR(`Order Date`)),2) AS sales_growth,
    ROUND(
        SUM(Profit) - LAG(SUM(Profit)) OVER (ORDER BY YEAR(`Order Date`)), 2
    ) AS profit_growth
FROM superstore
GROUP BY YEAR(`Order Date`)
ORDER BY order_year;
  
  
  -- 9) Which countries and cities are driving the highest sales?
  SELECT 
    country, 
    SUM(sales) AS total_sales
FROM superstore
GROUP BY country
ORDER BY total_sales DESC;
  
-- 10. What is the average delivery time from order to ship date across regions?
SELECT 
    region,
    AVG(DATEDIFF(`Ship Date`, `Order Date`))AS avg_delivery_days
FROM superstore
GROUP BY region
ORDER BY avg_delivery_days;


-- 11. what is the profit distribution across order priority?
SELECT 
    `Order Priority` AS order_priority,
    SUM(profit) AS total_profit,
    AVG(profit) AS avg_profit_per_order
FROM superstore
GROUP BY `Order Priority`
ORDER BY total_profit DESC;

-- 12. Suggest data-driven recommendations for improving profit and reducing losses.
SELECT 
    `Product Name`, 
    `Sub-Category`, 
    SUM(Profit)as Total_Profit
FROM superstore
GROUP BY `Product Name`, `Sub-Category`
HAVING SUM(Profit) < 0
ORDER BY Total_Profit ASC;