# Ecommerce_analysis_sql
This analysis  enhances marketing and inventory strategies. Key findings include identifying top cities for marketing, segmenting customers by order frequency, pinpointing high-revenue products, and evaluating sales trends. Recommendations focus on targeted marketing, optimizing inventory, and planning for peak sales periods

---

## Analysis of Sales and Customer Data

### Overview

This document provides a comprehensive analysis of sales and customer data across several dimensions, including market segmentation, engagement depth, purchase value, inventory turnover, and customer acquisition trends. The analysis uses the following tables:

- **Customers**
- **Products**
- **Orders**
- **OrderDetails**

### Tables Description

#### Customers Table
- **CustomerID**: Unique identifier for each customer.
- **Name**: Name of the customer.
- **Location**: Geographic location of the customer.
- **Email**: Email address of the customer.
- **Phone**: Contact number of the customer.

#### Products Table
- **ProductID**: Unique identifier for each product.
- **Name**: Name of the product.
- **Category**: Category under which the product falls.
- **Price**: Price of the product.

#### Orders Table
- **OrderID**: Unique identifier for each order.
- **CustomerID**: ID of the customer who placed the order.
- **OrderDate**: Date when the order was placed.
- **TotalAmount**: Total amount of the order.

#### OrderDetails Table
- **OrderID**: Unique identifier for each order (Foreign Key).
- **ProductID**: Unique identifier for each product (Foreign Key).
- **Quantity**: Quantity of the product ordered.
- **PricePerUnit**: Price per unit of the product.

---

### Market Segmentation Analysis

**Objective**: Identify the top 3 cities with the highest number of customers to determine key markets for targeted marketing and logistic optimization.

**Query**:
```sql
SELECT Location, COUNT(*) AS number_of_customers
FROM Customers
GROUP BY Location
ORDER BY number_of_customers DESC
LIMIT 3;
```

**Top Locations**:
1. Delhi
2. Chennai
3. Jaipur

---

### Engagement Depth Analysis

**Objective**: Determine the distribution of customers by the number of orders placed to segment customers for tailored marketing strategies.

**Query**:
```sql
SELECT Cs_segment AS NumberOfOrders, COUNT(customer_id) AS CustomerCount
FROM (
    SELECT customer_id, COUNT(order_id) AS Cs_segment
    FROM Orders
    GROUP BY customer_id
) a
GROUP BY Cs_segment
ORDER BY Cs_segment;
```

**Customer Categories**:
- One-time buyers
- Occasional shoppers

---

### Purchase His Value Products

**Objective**: Identify products where the average purchase quantity per order is 2 but with high total revenue, suggesting premium product trends.

**Query**:
```sql
SELECT ProductID, AVG(Quantity) AS AvgQuantity, SUM(Quantity * PricePerUnit) AS TotalRevenue
FROM OrderDetails
GROUP BY ProductID
HAVING AVG(Quantity) = 2
ORDER BY TotalRevenue DESC;
```

**Top Product**:
- Product ID 1

---

### Category-wise Customer Reach

**Objective**: Calculate the unique number of customers purchasing from each product category to understand category appeal.

**Query**:
```sql
SELECT p.Category, COUNT(DISTINCT c.CustomerID) AS UniqueCustomers
FROM Products p
JOIN OrderDetails od ON p.ProductID = od.ProductID
JOIN Orders o ON od.OrderID = o.OrderID
JOIN Customers c ON o.CustomerID = c.CustomerID
GROUP BY p.Category
ORDER BY UniqueCustomers DESC;
```

**High Demand Category**:
- Electronics

---

### Sales Trend Analysis

**Objective**: Analyze the month-on-month percentage change in total sales to identify growth trends.

**Query**:
```sql
SELECT *, 
       ROUND((TotalSales - LAG(TotalSales) OVER (ORDER BY Month)) / LAG(TotalSales) OVER (ORDER BY Month) * 100, 2) AS PercentChange
FROM (
    SELECT DATE_FORMAT(OrderDate, '%Y-%m') AS Month, SUM(TotalAmount) AS TotalSales
    FROM Orders
    GROUP BY Month
) a;
```

**Largest Decline**:
- February 2024

**Trend from March to August**:
- Sales fluctuated with no clear trend.

---

### Average Order Value Fluctuation

**Objective**: Examine month-on-month changes in average order value to guide pricing and promotional strategies.

**Query**:
```sql
SELECT *, 
       ROUND(AvgOrderValue - LAG(AvgOrderValue) OVER (ORDER BY Month), 2) AS ChangeInValue
FROM (
    SELECT DATE_FORMAT(OrderDate, '%Y-%m') AS Month, AVG(TotalAmount) AS AvgOrderValue
    FROM Orders
    GROUP BY Month
) a
ORDER BY ChangeInValue DESC;
```

**Month with Highest Change in Average Order Value**:
- December

---

### Inventory Refresh Rate

**Objective**: Identify products with the fastest turnover rates for frequent restocking.

**Query**:
```sql
SELECT ProductID, COUNT(*) AS SalesFrequency
FROM OrderDetails
GROUP BY ProductID
ORDER BY SalesFrequency DESC
LIMIT 5;
```

**Product with Highest Turnover Rates**:
- Product ID 7

---

### Low Engagement Products

**Objective**: List products purchased by less than 40% of the customer base to identify potential mismatches.

**Query**:
```sql
WITH s AS (
    SELECT p.ProductID, p.Name, COUNT(DISTINCT c.CustomerID) AS UniqueCustomerCount
    FROM Products p
    JOIN OrderDetails od ON p.ProductID = od.ProductID
    JOIN Orders o ON od.OrderID = o.OrderID
    JOIN Customers c ON o.CustomerID = c.CustomerID
    GROUP BY p.ProductID, p.Name
)
SELECT ProductID AS Product_ID, Name, UniqueCustomerCount
FROM (
    SELECT *, NTILE(10) OVER (ORDER BY UniqueCustomerCount) AS Percentile
    FROM s
) a
WHERE Percentile < 4
LIMIT 2;
```

**Possible Reasons for Low Purchase Rates**:
- Poor visibility on the platform.

**Strategic Action**:
- Implement targeted marketing campaigns to raise awareness and interest.

---

### Customer Acquisition Trends

**Objective**: Evaluate month-on-month growth rate in the customer base to understand the effectiveness of marketing campaigns.

**Query**:
```sql
SELECT DATE_FORMAT(OrderDate, '%Y-%m') AS FirstPurchaseMonth, 
       COUNT(CustomerID) AS TotalNewCustomers
FROM (
    SELECT CustomerID, MIN(OrderDate) AS OrderDate
    FROM Orders
    GROUP BY CustomerID
) a
GROUP BY FirstPurchaseMonth
ORDER BY FirstPurchaseMonth;
```

**Trend Inference**:
- Downward trend, implying marketing campaigns may not be as effective.

---

### Peak Sales Period Indication

**Objective**: Identify the months with the highest sales volume for better planning of stock levels and staffing.

**Query**:
```sql
SELECT DATE_FORMAT(OrderDate, '%Y-%m') AS Month, SUM(TotalAmount) AS TotalSales
FROM Orders
GROUP BY Month
ORDER BY TotalSales DESC
LIMIT 3;
```

**Months Requiring Major Restocking and Increased Staff**:
- September
- December

---

### Copyright Information

© Tarun Kumar Arora, [Date: August 21, 2024]
