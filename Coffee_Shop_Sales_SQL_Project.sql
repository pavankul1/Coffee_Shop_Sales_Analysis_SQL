SELECT * FROM
    coffee_shop_sales;
    
-- 1. CONVERT DATE (transaction_date) COLUMN TO PROPER DATE FORMAT
UPDATE coffee_shop_sales 
SET 
    transaction_date = STR_TO_DATE(transaction_date, '%d-%m-%Y');

-- 2. ALTER DATE(transaction_date) COLUMN TO DATE DATA TYPE
ALTER TABLE coffee_shop_sales
MODIFY COLUMN transaction_date DATE;

-- 3. CONVERT TIME (transaction_time)  COLUMN TO PROPER DATE FORMAT
UPDATE coffee_shop_sales
SET transaction_time = STR_TO_DATE(transaction_time, '%H:%i:%s');

-- 4. ALTER TIME (transaction_time) COLUMN TO DATE DATA TYPE
ALTER TABLE coffee_shop_sales
MODIFY COLUMN transaction_time TIME;
 
 -- 5. DATA TYPES OF DIFFERENT COLUMNS
 describe coffee_shop_sales;

-- 6. CHANGE COLUMN NAME `ï»¿transaction_id` to transaction_id
ALTER TABLE coffee_shop_sales
CHANGE COLUMN `ï»¿transaction_id` Transaction_ID INT;

SELECT * FROM
    coffee_shop_sales;

-- 7. Total Sales
SELECT 
    ROUND(SUM(Unit_Price * Transaction_Qty)) AS Total_Sales
FROM
    coffee_shop_sales
WHERE
    MONTH(transaction_date) = 5;

-- 8. TOTAL SALES KPI - MOM DIFFERENCE AND MOM GROWTH
SELECT 
    MONTH(transaction_date) AS Month,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales,
    (SUM(unit_price * transaction_qty) - LAG(SUM(unit_price * transaction_qty), 1)
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(unit_price * transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS MOM_Increase_Percentage
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for months of April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);
 
-- 9. Total_Orders
SELECT 
    COUNT(Transaction_ID) AS Total_Orders
FROM
    coffee_shop_sales
WHERE
    MONTH(transaction_date) = 3;
   
-- 10. TOTAL ORDERS KPI - MOM DIFFERENCE AND MOM GROWTH
select
	month(transaction_date)as Month,
	round(count(transaction_id))as Total_orders,
	(count(transaction_id)-lag(count(transaction_id),1)	
	over(order by month(transaction_date)))/lag(count(transaction_id),1)
	over(order by month(transaction_date))*100 as MOM_Increase_Percentage
from 
	coffee_shop_sales
where
	month(transaction_date) in (4, 5)  -- 4-April month(Previous month), 5-May month month(Current month)
group by 
	month(transaction_date);    

-- 11. Total_Quantity_Sold
SELECT 
    SUM(Transaction_Qty)as Total_Quantity_Sold
FROM
    coffee_shop_sales
WHERE
    MONTH(transaction_date) = 6; -- June month
    
-- 12. TOTAL QUANTITY SOLD KPI - MOM DIFFERENCE AND MOM GROWTH
select
month(transaction_date)as Month,
sum(transaction_qty) as Total_Quantity_Sold,
(sum(transaction_qty)-lag(sum(transaction_qty),1)
over (order by month(transaction_date)))/lag(sum(transaction_qty),1)
over (order by month(transaction_date))* 100 as MOM_Increase_Percentage
from coffee_shop_sales
where 
month(transaction_date) in (4,5)  -- 4-April month(Previous month), 5-May month month(Current month)
group by month(transaction_date)
order by month(transaction_date);

-- 13. Total_Sales, Total_Orders, Tota	l_QTY, Sold (CALENDAR TABLE – DAILY SALES, QUANTITY and TOTAL ORDERS)
SELECT 
    concat(round(SUM(Unit_Price * Transaction_Qty)/1000,1),'K') AS Total_Sales,
    concat(round(count(transaction_id)/1000,1),'K')as Total_Orders,
    concat(round(sum(Transaction_Qty)/1000,1),'K')as Toatl_QTY_Sold
FROM
    coffee_shop_sales
where
	Transaction_Date='2023-05-18';
    
-- 14. (SALES TREND OVER PERIOD ) Daily sales analysis with average line:
SELECT 
    CONCAT(ROUND(AVG(total_sales) / 1000, 1), 'K') AS Avg_Sales
FROM
    (
    SELECT 
        SUM(unit_price * transaction_qty) AS total_sales
    FROM
        coffee_shop_sales
    WHERE
        MONTH(transaction_date) = 5
    GROUP BY transaction_date) AS Inner_Query;

-- 15. DAILY SALES FOR MONTH SELECTED
SELECT 
    DAY(transaction_date) AS Day_Of_Month,
    ROUND(SUM(unit_price * transaction_qty),1) AS Total_Sales
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 5  -- Filter for May
GROUP BY 
    DAY(transaction_date)
ORDER BY 
    DAY(transaction_date);
    
-- 16. COMPARING DAILY SALES WITH AVERAGE SALES – IF GREATER THAN “ABOVE AVERAGE” and LESSER THAN “BELOW AVERAGE”
SELECT 
    Day_Of_Month,
    CASE 
        WHEN total_sales > avg_sales THEN 'Above Average'
        WHEN total_sales < avg_sales THEN 'Below Average'
        ELSE 'Average'
    END AS Sales_Status,
    Total_Sales
FROM (
    SELECT 
        DAY(transaction_date) AS day_of_month,
        round(SUM(unit_price * transaction_qty),2) AS total_sales,
        AVG(SUM(unit_price * transaction_qty)) OVER () AS avg_sales
    FROM 
        coffee_shop_sales
    WHERE 
        MONTH(transaction_date) = 5  -- Filter for May
    GROUP BY 
        DAY(transaction_date)
) AS sales_data
ORDER BY 
    day_of_month;


-- 17. Sales Analysis for weekends and weekdays 
-- Sat & Sunday = Weekends
-- Mon to Fri = Weekdays
-- in SQL Sunday=1, Mon=2, ...., Sat=7.
SELECT 
    CASE
        WHEN DAYOFWEEK(transaction_date) IN (1 , 7) THEN 'Weekends'
        ELSE 'Weekdays'
    END AS Day_Type,
    CONCAT(ROUND(SUM(unit_price * transaction_qty) / 1000,1),'K') AS Total_Sales
FROM
    coffee_shop_sales
WHERE
    MONTH(transaction_date) = 5
GROUP BY CASE
    WHEN DAYOFWEEK(transaction_date) IN (1 , 7) THEN 'Weekends'
    ELSE 'Weekdays'
END;
 
-- 18. Sales analysis by Store Location.
SELECT 
    store_location,
    CONCAT(ROUND(SUM(unit_price * transaction_qty) / 1000,1),'K') AS Total_sales
FROM
    coffee_shop_sales
WHERE
    MONTH(transaction_date) = 5
GROUP BY Store_Location
ORDER BY Total_Sales;
    
-- 19. Sales Analysis by Product Category
SELECT 
    Product_Category,
    round(SUM(unit_price * transaction_qty),1) AS Total_sales
FROM
    coffee_shop_sales
WHERE
    MONTH(transaction_date) = 5
GROUP BY product_category
order by Total_Sales desc;

-- 20. Top 10 products by sales
SELECT 
    Product_Type,
    round(SUM(unit_price * transaction_qty),1) AS Total_Sales
FROM
    coffee_shop_sales
WHERE
    MONTH(transaction_date) = 5
GROUP BY product_type
ORDER BY Total_sales DESC
LIMIT 10;

-- 21. Sales Analysis by Days and Hours
SELECT 
    round(SUM(unit_price * transaction_qty)) AS Total_sales,
    SUM(transaction_qty) AS Total_QTY_Sold,
    COUNT(*) AS Total_Orders
FROM
    coffee_shop_sales
WHERE
    MONTH(transaction_date) = 5
        AND DAYOFWEEK(transaction_date) = 3
        AND HOUR(transaction_time) = 8; -- hour no 8

-- 22. TO GET SALES FROM MONDAY TO SUNDAY FOR MONTH OF MAY
select
	case 
    when dayofweek(transaction_date) = 2 Then 'Monday'
    when dayofweek(transaction_date) = 3 Then 'Tuesday'
    when dayofweek(transaction_date) = 4 Then 'Wednesday'
    when dayofweek(transaction_date) = 5 Then 'Thursday'
    when dayofweek(transaction_date) = 6 Then 'Fridayday'
    when dayofweek(transaction_date) = 7 Then 'Saturday'
    when dayofweek(transaction_date) = 1 Then 'Sunday'
    End as Day_Of_Week,
    round(sum(unit_price*transaction_qty))as Total_Sales
From
	coffee_shop_sales
Where
	month(transaction_date)=5
Group By
	case 
    when dayofweek(transaction_date) = 2 Then 'Monday'
    when dayofweek(transaction_date) = 3 Then 'Tuesday'
    when dayofweek(transaction_date) = 4 Then 'Wednesday'
    when dayofweek(transaction_date) = 5 Then 'Thursday'
    when dayofweek(transaction_date) = 6 Then 'Fridayday'
    when dayofweek(transaction_date) = 7 Then 'Saturday'
    when dayofweek(transaction_date) = 1 Then 'Sunday'
    End;
    
-- 23. TO GET SALES FOR ALL HOURS FOR MONTH OF MAY
Select
	hour(transaction_time)as Hours,
    round(sum(unit_price*transaction_qty))as Total_Sales
From 
	coffee_shop_sales
Where
	month(transaction_date)=5
Group by 
	Hours
Order by
	Hours;