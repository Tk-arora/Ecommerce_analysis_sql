-- **Case Study Description**

-- This section provides an overview of the analysis conducted.

-- **1. Describe the Tables**

-- Customers Table
SELECT * FROM Customers LIMIT 1;

-- Products Table
SELECT * FROM Products LIMIT 1;

-- Orders Table
SELECT * FROM Orders LIMIT 1;

-- OrderDetails Table
SELECT * FROM OrderDetails LIMIT 1;

-- **2. Market Segmentation Analysis**

-- Identify the top 3 cities with the highest number of customers
SELECT Location, COUNT(*) AS number_of_customers
FROM Customers
GROUP BY Location
ORDER BY number_of_customers DESC
LIMIT 3;

-- **3. Engagement Depth Analysis**

-- Determine the distribution of customers by the number of orders placed
SELECT Cs_segment AS NumberOfOrders, COUNT(customer_id) AS CustomerCount
FROM (
    SELECT customer_id, COUNT(order_id) AS Cs_segment
    FROM Orders
    GROUP BY customer_id
) AS a
GROUP BY Cs_segment
ORDER BY Cs_segment;

-- **4. Purchase High-Value Products**

-- Identify products with average purchase quantity of 2 and high total revenue
SELECT product_id, AVG(quantity) AS AvgQuantity, SUM(quantity * price_per_unit) AS TotalRevenue
FROM OrderDetails
GROUP BY product_id
HAVING AVG(quantity) = 2
ORDER BY TotalRevenue DESC;

-- **5. Category-wise Customer Reach**

-- Calculate the unique number of customers purchasing each product category
SELECT p.category, COUNT(DISTINCT customer_id) AS unique_customers
FROM Products AS p
JOIN OrderDetails AS od ON p.product_id = od.product_id
JOIN Orders AS o ON o.order_id = od.order_id
GROUP BY p.category
ORDER BY unique_customers DESC;

-- **6. Sales Trend Analysis**

-- Analyze month-on-month percentage change in total sales
SELECT Month, TotalSales, ROUND((TotalSales - LAG(TotalSales) OVER (ORDER BY Month)) / LAG(TotalSales) OVER (ORDER BY Month) * 100, 2) AS PercentChange
FROM (
    SELECT DATE_FORMAT(order_date, '%Y-%m') AS Month, SUM(total_amount) AS TotalSales
    FROM Orders
    GROUP BY Month
) AS a;

-- **7. Average Order Value Fluctuation**

-- Examine month-on-month change in average order value
SELECT Month, AvgOrderValue, ROUND(AvgOrderValue - LAG(AvgOrderValue) OVER (ORDER BY Month), 2) AS ChangeInValue
FROM (
    SELECT DATE_FORMAT(order_date, '%Y-%m') AS Month, AVG(total_amount) AS AvgOrderValue
    FROM Orders
    GROUP BY Month
) AS a
ORDER BY ChangeInValue DESC;

-- **8. Inventory Refresh Rate**

-- Identify products with the fastest turnover rates (top 5)
SELECT product_id, COUNT(*) AS SalesFrequency
FROM OrderDetails
GROUP BY product_id
ORDER BY SalesFrequency DESC
LIMIT 5;

-- **9. Low Engagement Products**

-- List products purchased by less than 40% of the customer base
WITH s AS (
    SELECT p.product_id, p.Name AS Name, COUNT(DISTINCT c.customer_id) AS UniqueCustomerCount
    FROM Products p
    JOIN OrderDetails od ON p.product_id = od.product_id
    JOIN Orders o ON od.order_id = o.order_id
    JOIN Customers c ON o.customer_id = c.customer_id
    GROUP BY p.product_id, p.Name
)
SELECT product_id AS Product_id, Name, UniqueCustomerCount
FROM (
    SELECT *, NTILE(10) OVER (ORDER BY UniqueCustomerCount) AS percentile
    FROM s
) AS a
WHERE percentile < 4
LIMIT 2;

-- **10. Customer Acquisition Trends**

-- Evaluate month-on-month growth rate in the customer base
SELECT FirstPurchaseMonth, COUNT(customer_id) AS TotalNewCustomers
FROM (
    SELECT customer_id, MIN(order_date) AS order_date
    FROM Orders
    GROUP BY customer_id
) AS a
GROUP BY FirstPurchaseMonth
ORDER BY FirstPurchaseMonth;

-- **11. Peak Sales Period Indication**

-- Identify the months with the highest sales volume
SELECT DATE_FORMAT(order_date, '%Y-%m') AS month, SUM(total_amount) AS TotalSales
FROM Orders
GROUP BY month
ORDER BY TotalSales DESC
LIMIT 3;
