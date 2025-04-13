/*
===============================================================================
Quality Checks for Bronze Layer
===============================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy, 
    and standardization across the 'bronze' layer. It includes checks for:
    - Null or duplicate primary keys.
    - Data validation for common fields.
    - Date ranges and consistency.
    - Data relationships between tables.

Usage Notes:
    - Run these checks after data loading Bronze Layer.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- ====================================================================
-- Checking 'bronze.Date'
-- ====================================================================
-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT 
    date_key,
    COUNT(*) 
FROM bronze.Date
GROUP BY date_key
HAVING COUNT(*) > 1 OR date_key IS NULL;

-- Check date range - should be between 1996 and 1998
-- Expectation: No Results (all dates should be within range)
SELECT 
    MIN(year) AS min_year,
    MAX(year) AS max_year
FROM bronze.Date
WHERE year < 1996 OR year > 1998;

-- Check for consistency between date_key and full_date
-- Expectation: No Results
SELECT 
    date_key,
    full_date
FROM bronze.Date
WHERE date_key != CONVERT(INT, CONVERT(VARCHAR, full_date, 112));

-- Check for invalid weekday flags
-- Expectation: Only 'Weekday' and 'Weekend' values
SELECT DISTINCT 
    weekday_flag 
FROM bronze.Date
WHERE weekday_flag NOT IN ('Weekday', 'Weekend');

-- Check month consistency
-- Expectation: No Results (month name should match month number)
SELECT 
    month,
    month_name
FROM bronze.Date
WHERE (month = 1 AND month_name != 'January')
   OR (month = 2 AND month_name != 'February')
   OR (month = 3 AND month_name != 'March')
   OR (month = 4 AND month_name != 'April')
   OR (month = 5 AND month_name != 'May')
   OR (month = 6 AND month_name != 'June')
   OR (month = 7 AND month_name != 'July')
   OR (month = 8 AND month_name != 'August')
   OR (month = 9 AND month_name != 'September')
   OR (month = 10 AND month_name != 'October')
   OR (month = 11 AND month_name != 'November')
   OR (month = 12 AND month_name != 'December');

-- ====================================================================
-- Checking 'bronze.Orders'
-- ====================================================================
-- Check for NULLs in Primary Key
-- Expectation: No Results
SELECT 
    OrderID
FROM bronze.Orders
WHERE OrderID IS NULL;

-- Check for duplicates in primary key
-- Expectation: No Results
SELECT 
    OrderID,
    COUNT(*) 
FROM bronze.Orders
GROUP BY OrderID
HAVING COUNT(*) > 1;

-- Check date ranges - Northwind dates should be between 1996-1998
-- Expectation: All dates within range
SELECT 
    MIN(OrderDate) AS min_order_date,
    MAX(OrderDate) AS max_order_date,
    MIN(RequiredDate) AS min_required_date,
    MAX(RequiredDate) AS max_required_date,
    MIN(ShippedDate) AS min_shipped_date,
    MAX(ShippedDate) AS max_shipped_date
FROM bronze.Orders;

-- Check for invalid date relationships
-- Expectation: No Results
SELECT 
    OrderID, OrderDate, RequiredDate, ShippedDate
FROM bronze.Orders
WHERE OrderDate > RequiredDate 
   OR (ShippedDate IS NOT NULL AND OrderDate > ShippedDate);

-- ====================================================================
-- Checking 'bronze.OrderDetails'
-- ====================================================================
-- Check for missing relationships
-- Expectation: No Results (all OrderIDs should exist in Orders table)
SELECT 
    od.OrderID
FROM bronze.OrderDetails od
LEFT JOIN bronze.Orders o ON od.OrderID = o.OrderID
WHERE o.OrderID IS NULL;

-- Check for negative or zero quantities or prices
-- Expectation: No Results
SELECT 
    OrderID, ProductID, UnitPrice, Quantity
FROM bronze.OrderDetails
WHERE UnitPrice <= 0 OR Quantity <= 0;

-- Check for discount values outside of expected range (0-1)
-- Expectation: No Results
SELECT 
    OrderID, Discount
FROM bronze.OrderDetails
WHERE CAST(Discount AS FLOAT) < 0 OR CAST(Discount AS FLOAT) > 1;

-- ====================================================================
-- Checking 'bronze.Products'
-- ====================================================================
-- Check for NULLs in Primary Key
-- Expectation: No Results
SELECT 
    ProductID
FROM bronze.Products
WHERE ProductID IS NULL;

-- Check for duplicates in primary key
-- Expectation: No Results
SELECT 
    ProductID,
    COUNT(*) 
FROM bronze.Products
GROUP BY ProductID
HAVING COUNT(*) > 1;

-- Check for negative prices or stock values
-- Expectation: No Results
SELECT 
    ProductID, UnitPrice, UnitsInStock, UnitsOnOrder
FROM bronze.Products
WHERE UnitPrice < 0 
   OR UnitsInStock < 0 
   OR UnitsOnOrder < 0
   OR ReorderLevel < 0;

-- ====================================================================
-- Checking 'bronze.Customers'
-- ====================================================================
-- Check for NULLs or duplicates in Primary Key
-- Expectation: No Results
SELECT 
    CustomerID,
    COUNT(*) 
FROM bronze.Customers
GROUP BY CustomerID
HAVING COUNT(*) > 1 OR CustomerID IS NULL;

-- Check for mandatory fields
-- Expectation: No Results
SELECT 
    CustomerID 
FROM bronze.Customers
WHERE CompanyName IS NULL;

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT 
    Country 
FROM bronze.Customers
WHERE Country != TRIM(Country);

-- ====================================================================
-- Checking 'bronze.Suppliers'
-- ====================================================================
-- Check for NULLs or duplicates in Primary Key
-- Expectation: No Results
SELECT 
    SupplierID,
    COUNT(*) 
FROM bronze.Suppliers
GROUP BY SupplierID
HAVING COUNT(*) > 1 OR SupplierID IS NULL;

-- ====================================================================
-- Checking 'bronze.Employees'
-- ====================================================================
-- Check for NULLs or duplicates in Primary Key
-- Expectation: No Results
SELECT 
    EmployeeID,
    COUNT(*) 
FROM bronze.Employees
GROUP BY EmployeeID
HAVING COUNT(*) > 1 OR EmployeeID IS NULL;

-- Check hire date is after birth date
-- Expectation: No Results
SELECT 
    EmployeeID, BirthDate, HireDate
FROM bronze.Employees
WHERE HireDate <= BirthDate;
