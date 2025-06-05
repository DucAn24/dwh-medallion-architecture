--EXEC gold.load_gold;

CREATE OR ALTER PROCEDURE gold.load_gold AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Loading Gold Layer - Final Dimensional Model';
        PRINT 'Reading from Silver SCD2 Dimensions';
        PRINT '================================================';

        -- Load DimDate 
        SET @start_time = GETDATE();
        PRINT '>> Loading Table: gold.DimDate';
        
        DELETE FROM gold.DimDate;
        INSERT INTO gold.DimDate (
            DateKey, Date, DayOfWeek, DayName, DayOfMonth, DayOfYear,
            WeekOfYear, MonthName, MonthOfYear, Quarter, QuarterName, Year, IsWeekday
        )
        SELECT 
            DateKey, Date, DayOfWeek, DayName, DayOfMonth, DayOfYear,
            WeekOfYear, MonthName, MonthOfYear, Quarter, QuarterName, Year, IsWeekday
        FROM silver.DimDate;
        
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        -- Load DimCustomer 
        SET @start_time = GETDATE();
        PRINT '>> Loading Table: gold.DimCustomer';
        
        DELETE FROM gold.DimCustomer;
        SET IDENTITY_INSERT gold.DimCustomer ON;
        INSERT INTO gold.DimCustomer (
            CustomerKey, CustomerID, CompanyName, ContactName, ContactTitle,
            CustomerCountry, CustomerRegion, CustomerCity, CustomerPostalCode,
            RowIsCurrent, RowStartDate, RowEndDate, RowChangeReason
        )
        SELECT 
            CustomerKey, CustomerID, CompanyName, ContactName, ContactTitle,
            CustomerCountry, CustomerRegion, CustomerCity, CustomerPostalCode,
            RowIsCurrent, RowStartDate, RowEndDate, RowChangeReason
        FROM silver.DimCustomer;
        SET IDENTITY_INSERT gold.DimCustomer OFF;
        
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        -- Load DimEmployee 
        SET @start_time = GETDATE();
        PRINT '>> Loading Table: gold.DimEmployee';
        
        DELETE FROM gold.DimEmployee;
        SET IDENTITY_INSERT gold.DimEmployee ON;
        INSERT INTO gold.DimEmployee (
            EmployeeKey, EmployeeID, EmployeeName, EmployeeTitle,
            RowIsCurrent, RowStartDate, RowEndDate, RowChangeReason
        )
        SELECT 
            EmployeeKey, EmployeeID, EmployeeName, EmployeeTitle,
            RowIsCurrent, RowStartDate, RowEndDate, RowChangeReason
        FROM silver.DimEmployee;
        SET IDENTITY_INSERT gold.DimEmployee OFF;
        
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        -- Load DimProducts 
        SET @start_time = GETDATE();
        PRINT '>> Loading Table: gold.DimProducts';
        
        DELETE FROM gold.DimProducts;
        SET IDENTITY_INSERT gold.DimProducts ON;
        INSERT INTO gold.DimProducts (
            ProductKey, ProductID, ProductName, Discontinued, CategoryName, SupplierName,
            RowIsCurrent, RowStartDate, RowEndDate, RowChangeReason
        )
        SELECT 
            ProductKey, ProductID, ProductName, Discontinued, CategoryName, SupplierName,
            RowIsCurrent, RowStartDate, RowEndDate, RowChangeReason
        FROM silver.DimProducts;
        SET IDENTITY_INSERT gold.DimProducts OFF;
        
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        -- Load DimShipper 
        SET @start_time = GETDATE();
        PRINT '>> Loading Table: gold.DimShipper';
        
        DELETE FROM gold.DimShipper;
        SET IDENTITY_INSERT gold.DimShipper ON;
        INSERT INTO gold.DimShipper (
            ShipperKey, ShipperID, CompanyName, Phone,
            RowIsCurrent, RowStartDate, RowEndDate, RowChangeReason
        )
        SELECT 
            ShipperKey, ShipperID, CompanyName, Phone,
            RowIsCurrent, RowStartDate, RowEndDate, RowChangeReason
        FROM silver.DimShipper;
        SET IDENTITY_INSERT gold.DimShipper OFF;
        
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        -- Load DimSupplier 
        SET @start_time = GETDATE();
        PRINT '>> Loading Table: gold.DimSupplier';
        
        DELETE FROM gold.DimSupplier;
        SET IDENTITY_INSERT gold.DimSupplier ON;
        INSERT INTO gold.DimSupplier (
            SupplierKey, SupplierID, CompanyName, ContactName, ContactTitle,
            Address, City, Region, PostalCode, Country, Phone,
            RowIsCurrent, RowStartDate, RowEndDate, RowChangeReason
        )
        SELECT 
            SupplierKey, SupplierID, CompanyName, ContactName, ContactTitle,
            Address, City, Region, PostalCode, Country, Phone,
            RowIsCurrent, RowStartDate, RowEndDate, RowChangeReason
        FROM silver.DimSupplier;
        SET IDENTITY_INSERT gold.DimSupplier OFF;
        
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        -- Load DimCategory 
        SET @start_time = GETDATE();
        PRINT '>> Loading Table: gold.DimCategory';
        
        DELETE FROM gold.DimCategory;
        SET IDENTITY_INSERT gold.DimCategory ON;
        INSERT INTO gold.DimCategory (
            CategoryKey, CategoryID, CategoryName, Description,
            RowIsCurrent, RowStartDate, RowEndDate, RowChangeReason
        )
        SELECT 
            CategoryKey, CategoryID, CategoryName, Description,
            RowIsCurrent, RowStartDate, RowEndDate, RowChangeReason
        FROM silver.DimCategory;
        SET IDENTITY_INSERT gold.DimCategory OFF;
        
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        -- Load FactSales 
        SET @start_time = GETDATE();
        PRINT '>> Loading Table: gold.FactSales';
        
        TRUNCATE TABLE gold.FactSales;
        INSERT INTO gold.FactSales (
            DateKey, CustomerKey, EmployeeKey, ProductKey, OrderID,
            UnitPrice, Quantity, Discount, SalesAmount
        )
        SELECT 
            DateKey, CustomerKey, EmployeeKey, ProductKey, OrderID,
            UnitPrice, Quantity, Discount, SalesAmount
        FROM silver.FactSales;
        
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        -- Load FactOrderFulfillment 
        SET @start_time = GETDATE();
        PRINT '>> Loading Table: gold.FactOrderFulfillment';
        
        TRUNCATE TABLE gold.FactOrderFulfillment;
        INSERT INTO gold.FactOrderFulfillment (
            OrderDateKey, RequiredDateKey, ShippedDateKey, CustomerKey, EmployeeKey, ShipperKey,
            OrderID, Freight, DaysToShip, DaysLate, OnTimeDelivery
        )
        SELECT 
            OrderDateKey, RequiredDateKey, ShippedDateKey, CustomerKey, EmployeeKey, ShipperKey,
            OrderID, Freight, DaysToShip, DaysLate, OnTimeDelivery
        FROM silver.FactOrderFulfillment;
        
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        -- Load FactInventory 
        SET @start_time = GETDATE();
        PRINT '>> Loading Table: gold.FactInventory';
        
        TRUNCATE TABLE gold.FactInventory;
        INSERT INTO gold.FactInventory (
            ProductKey, SupplierKey, CategoryKey,
            UnitsInStock, UnitsOnOrder, ReorderLevel, UnitPrice, StockValue, StockStatus
        )
        SELECT 
            ProductKey, SupplierKey, CategoryKey,
            UnitsInStock, UnitsOnOrder, ReorderLevel, UnitPrice, StockValue, StockStatus
        FROM silver.FactInventory;
        
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        SET @batch_end_time = GETDATE();
        PRINT '=========================================='
        PRINT 'Loading Gold Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '=========================================='
        
    END TRY
    BEGIN CATCH
        PRINT '=========================================='
        PRINT 'ERROR OCCURRED DURING LOADING GOLD LAYER'
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '=========================================='
    END CATCH
END
GO