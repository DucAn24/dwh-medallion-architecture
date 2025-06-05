--EXEC Silver.load_silver;

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Loading Silver Layer: Bronze to SCD2 + Clean Base Tables';
        PRINT '================================================';

        -- Loading DimDate
        SET @start_time = GETDATE();
        PRINT '>> Loading Table: silver.DimDate';
       
        TRUNCATE TABLE silver.DimDate;
        INSERT INTO silver.DimDate (
            DateKey, Date, DayOfWeek, DayName, DayOfMonth, DayOfYear,
            WeekOfYear, MonthName, MonthOfYear, Quarter, QuarterName, Year, IsWeekday
        )
        SELECT 
            date_key AS DateKey,
            full_date AS Date,
            day_of_week AS DayOfWeek,
            day_name AS DayName,
            day_num_in_month AS DayOfMonth,
            day_num_overall AS DayOfYear,
            week_num_in_year AS WeekOfYear,
            month_name AS MonthName,
            month AS MonthOfYear,
            quarter AS Quarter,
            CASE 
                WHEN quarter >= 1 AND quarter <= 3 THEN 'First' 
                WHEN quarter >= 4 AND quarter <= 6 THEN 'Second' 
                WHEN quarter >= 7 AND quarter <= 9 THEN 'Third' 
                WHEN quarter >= 10 AND quarter <= 12 THEN 'Fourth' 
            END AS QuarterName,
            year AS Year,
            weekday_flag AS IsWeekday
        FROM bronze.Date;
        
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';
        
        -- Loading DimCustomer with SCD Type 2
        SET @start_time = GETDATE();
        PRINT '>> Loading Table: silver.DimCustomer';
        
        MERGE silver.DimCustomer AS target
        USING (
            SELECT 
                CustomerID,
                CompanyName,
                ContactName,
                ContactTitle,
                CASE
                    WHEN TRIM(Country) = 'UK' THEN 'United Kingdom'
                    WHEN TRIM(Country) IN ('US', 'USA') THEN 'United States'
                    WHEN TRIM(Country) = '' OR Country IS NULL THEN 'n/a'
                    ELSE TRIM(Country)
                END AS CustomerCountry,
                CASE 
                    WHEN Region = 'NULL' THEN 'N/A' 
                    ELSE Region 
                END AS CustomerRegion,
                City AS CustomerCity,
                PostalCode AS CustomerPostalCode
            FROM bronze.Customers
        ) AS source
        ON target.CustomerID = source.CustomerID AND target.RowIsCurrent = 1
        
        WHEN MATCHED AND (
            target.CompanyName <> source.CompanyName OR
            target.ContactName <> source.ContactName OR
            ISNULL(target.ContactTitle,'') <> ISNULL(source.ContactTitle,'') OR
            target.CustomerCountry <> source.CustomerCountry OR
            ISNULL(target.CustomerRegion,'') <> ISNULL(source.CustomerRegion,'') OR
            ISNULL(target.CustomerCity,'') <> ISNULL(source.CustomerCity,'') OR
            ISNULL(target.CustomerPostalCode,'') <> ISNULL(source.CustomerPostalCode,'')
        ) THEN
            UPDATE SET
                RowIsCurrent = 0,
                RowEndDate = GETDATE(),
                RowChangeReason = 'Updated'
        
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (
                CustomerID, CompanyName, ContactName, ContactTitle,
                CustomerCountry, CustomerRegion, CustomerCity, CustomerPostalCode,
                RowIsCurrent, RowStartDate, RowEndDate, RowChangeReason
            )
            VALUES (
                source.CustomerID, source.CompanyName, source.ContactName, source.ContactTitle,
                source.CustomerCountry, source.CustomerRegion, source.CustomerCity, source.CustomerPostalCode,
                1, GETDATE(), '9999-12-31', 'Initial Load'
            );
        
        -- Insert new records for changed customers
        INSERT INTO silver.DimCustomer (
            CustomerID, CompanyName, ContactName, ContactTitle,
            CustomerCountry, CustomerRegion, CustomerCity, CustomerPostalCode,
            RowIsCurrent, RowStartDate, RowEndDate, RowChangeReason
        )
        SELECT 
            s.CustomerID, s.CompanyName, s.ContactName, s.ContactTitle,
            s.CustomerCountry, s.CustomerRegion, s.CustomerCity, s.CustomerPostalCode,
            1, GETDATE(), '9999-12-31', 'Updated'
        FROM (
            SELECT 
                CustomerID,
                CompanyName,
                ContactName,
                ContactTitle,
                CASE
                    WHEN TRIM(Country) = 'UK' THEN 'United Kingdom'
                    WHEN TRIM(Country) IN ('US', 'USA') THEN 'United States'
                    WHEN TRIM(Country) = '' OR Country IS NULL THEN 'n/a'
                    ELSE TRIM(Country)
                END AS CustomerCountry,
                CASE 
                    WHEN Region = 'NULL' THEN 'N/A' 
                    ELSE Region 
                END AS CustomerRegion,
                City AS CustomerCity,
                PostalCode AS CustomerPostalCode
            FROM bronze.Customers
        ) AS s
        INNER JOIN silver.DimCustomer AS d
            ON s.CustomerID = d.CustomerID AND d.RowIsCurrent = 0
            AND d.RowEndDate = CAST(GETDATE() AS DATE);
            
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';
        
        -- Loading DimEmployee with SCD Type 2 
        SET @start_time = GETDATE();
        PRINT '>> Loading Table: silver.DimEmployee';
        
        MERGE silver.DimEmployee AS target
        USING (
            SELECT 
                EmployeeID,
                FirstName + ' ' + LastName AS EmployeeName,
                Title AS EmployeeTitle
            FROM bronze.Employees
        ) AS source
        ON target.EmployeeID = source.EmployeeID AND target.RowIsCurrent = 1
        
        WHEN MATCHED AND (
            target.EmployeeName <> source.EmployeeName OR
            target.EmployeeTitle <> source.EmployeeTitle
        ) THEN
            UPDATE SET
                RowIsCurrent = 0,
                RowEndDate = GETDATE(),
                RowChangeReason = 'Updated'
        
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (
                EmployeeID, EmployeeName, EmployeeTitle,
                RowIsCurrent, RowStartDate, RowEndDate, RowChangeReason
            )
            VALUES (
                source.EmployeeID, source.EmployeeName, source.EmployeeTitle,
                1, GETDATE(), '9999-12-31', 'Initial Load'
            );
        
        -- Insert new records for changed employees
        INSERT INTO silver.DimEmployee (
            EmployeeID, EmployeeName, EmployeeTitle,
            RowIsCurrent, RowStartDate, RowEndDate, RowChangeReason
        )
        SELECT 
            s.EmployeeID, s.EmployeeName, s.EmployeeTitle,
            1, GETDATE(), '9999-12-31', 'Updated'
        FROM (
            SELECT 
                EmployeeID,
                FirstName + ' ' + LastName AS EmployeeName,
                Title AS EmployeeTitle
            FROM bronze.Employees
        ) AS s
        INNER JOIN silver.DimEmployee AS d
            ON s.EmployeeID = d.EmployeeID AND d.RowIsCurrent = 0
            AND d.RowEndDate = CAST(GETDATE() AS DATE);
            
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';
        
        -- Loading DimProducts with SCD Type 2
        SET @start_time = GETDATE();
        PRINT '>> Loading Table: silver.DimProducts';
        
        MERGE silver.DimProducts AS target
        USING (
            SELECT 
                p.ProductID,
                p.ProductName,
                CASE 
                    WHEN p.Discontinued = 1 THEN 'Y' 
                    ELSE 'N' 
                END AS Discontinued,
                c.CategoryName,
                s.CompanyName AS SupplierName
            FROM bronze.Products p
            JOIN bronze.Categories c ON p.CategoryID = c.CategoryID
            JOIN bronze.Suppliers s ON p.SupplierID = s.SupplierID
        ) AS source
        ON target.ProductID = source.ProductID AND target.RowIsCurrent = 1
        
        WHEN MATCHED AND (
            target.ProductName <> source.ProductName OR
            target.Discontinued <> source.Discontinued OR
            target.CategoryName <> source.CategoryName OR
            target.SupplierName <> source.SupplierName
        ) THEN
            UPDATE SET
                RowIsCurrent = 0,
                RowEndDate = GETDATE(),
                RowChangeReason = 'Updated'
        
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (
                ProductID, ProductName, Discontinued, CategoryName, SupplierName,
                RowIsCurrent, RowStartDate, RowEndDate, RowChangeReason
            )
            VALUES (
                source.ProductID, source.ProductName, source.Discontinued, source.CategoryName, source.SupplierName,
                1, GETDATE(), '9999-12-31', 'Initial Load'
            );
        
        -- Insert new records for changed products
        INSERT INTO silver.DimProducts (
            ProductID, ProductName, Discontinued, CategoryName, SupplierName,
            RowIsCurrent, RowStartDate, RowEndDate, RowChangeReason
        )
        SELECT 
            s.ProductID, s.ProductName, s.Discontinued, s.CategoryName, s.SupplierName,
            1, GETDATE(), '9999-12-31', 'Updated'
        FROM (
            SELECT 
                p.ProductID,
                p.ProductName,
                CASE 
                    WHEN p.Discontinued = 1 THEN 'Y' 
                    ELSE 'N' 
                END AS Discontinued,
                c.CategoryName,
                s.CompanyName AS SupplierName
            FROM bronze.Products p
            JOIN bronze.Categories c ON p.CategoryID = c.CategoryID
            JOIN bronze.Suppliers s ON p.SupplierID = s.SupplierID
        ) AS s
        INNER JOIN silver.DimProducts AS d
            ON s.ProductID = d.ProductID AND d.RowIsCurrent = 0
            AND d.RowEndDate = CAST(GETDATE() AS DATE);
            
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        -- Loading DimShipper with SCD Type 2 
        SET @start_time = GETDATE();
        PRINT '>> Loading Table: silver.DimShipper';
        
        MERGE silver.DimShipper AS target
        USING (
            SELECT 
                ShipperID,
                CompanyName,
                Phone
            FROM bronze.Shippers
        ) AS source
        ON target.ShipperID = source.ShipperID AND target.RowIsCurrent = 1

        WHEN MATCHED AND (
            target.CompanyName <> source.CompanyName OR
            ISNULL(target.Phone,'') <> ISNULL(source.Phone,'')
        ) THEN
            UPDATE SET
                RowIsCurrent = 0,
                RowEndDate = GETDATE(),
                RowChangeReason = 'Updated'

        WHEN NOT MATCHED BY TARGET THEN
            INSERT (
                ShipperID, CompanyName, Phone,
                RowIsCurrent, RowStartDate, RowEndDate, RowChangeReason
            )
            VALUES (
                source.ShipperID, source.CompanyName, source.Phone,
                1, GETDATE(), '9999-12-31', 'Initial Load'
            );

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        -- Loading DimSupplier with SCD Type 2 
        SET @start_time = GETDATE();
        PRINT '>> Loading Table: silver.DimSupplier';
        
        MERGE silver.DimSupplier AS target
        USING (
            SELECT 
                SupplierID,
                CompanyName,
                ContactName,
                ContactTitle,
                Address,
                City,
                CASE 
                    WHEN Region is null THEN 'N/A' 
                    ELSE Region 
                END AS Region,
                PostalCode,
                CASE
                    WHEN TRIM(Country) = 'UK' THEN 'United Kingdom'
                    WHEN TRIM(Country) IN ('US', 'USA') THEN 'United States'
                    WHEN TRIM(Country) = '' OR Country IS NULL THEN 'n/a'
                    ELSE TRIM(Country)
                END AS Country,
                CASE 
                    WHEN Phone IS NULL OR TRIM(Phone) = '' OR LOWER(TRIM(Phone)) = 'null' THEN 'N/A'
                    ELSE REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(Phone, '(', ''), ')', ''), '.', ''), '-', ''), ' ', '')
                END AS Phone
            FROM bronze.Suppliers
        ) AS source
        ON target.SupplierID = source.SupplierID AND target.RowIsCurrent = 1

        WHEN MATCHED AND (
            target.CompanyName <> source.CompanyName OR
            ISNULL(target.ContactName,'') <> ISNULL(source.ContactName,'') OR
            ISNULL(target.ContactTitle,'') <> ISNULL(source.ContactTitle,'') OR
            ISNULL(target.Address,'') <> ISNULL(source.Address,'') OR
            ISNULL(target.City,'') <> ISNULL(source.City,'') OR
            ISNULL(target.Region,'') <> ISNULL(source.Region,'') OR
            ISNULL(target.PostalCode,'') <> ISNULL(source.PostalCode,'') OR
            ISNULL(target.Country,'') <> ISNULL(source.Country,'') OR
            ISNULL(target.Phone,'') <> ISNULL(source.Phone,'')
        ) THEN
            UPDATE SET
                RowIsCurrent = 0,
                RowEndDate = GETDATE(),
                RowChangeReason = 'Updated'

        WHEN NOT MATCHED BY TARGET THEN
            INSERT (
                SupplierID, CompanyName, ContactName, ContactTitle,
                Address, City, Region, PostalCode, Country, Phone,
                RowIsCurrent, RowStartDate, RowEndDate, RowChangeReason
            )
            VALUES (
                source.SupplierID, source.CompanyName, source.ContactName, source.ContactTitle,
                source.Address, source.City, source.Region, source.PostalCode, source.Country, source.Phone,
                1, GETDATE(), '9999-12-31', 'Initial Load'
            );

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        -- Loading DimCategory 
        SET @start_time = GETDATE();
        PRINT '>> Loading Table: silver.DimCategory';

        MERGE silver.DimCategory AS target
        USING (
            SELECT 
                CategoryID,
                CategoryName,
                REPLACE([Description], '"', '') AS Description
            FROM bronze.Categories
        ) AS source
        ON target.CategoryID = source.CategoryID AND target.RowIsCurrent = 1

        WHEN MATCHED AND (
            target.CategoryName <> source.CategoryName OR
            ISNULL(target.Description,'') <> ISNULL(source.Description,'')
        ) THEN
            UPDATE SET
                RowIsCurrent = 0,
                RowEndDate = GETDATE(),
                RowChangeReason = 'Updated'

        WHEN NOT MATCHED BY TARGET THEN
            INSERT (
                CategoryID, CategoryName, Description,
                RowIsCurrent, RowStartDate, RowEndDate, RowChangeReason
            )
            VALUES (
                source.CategoryID, source.CategoryName, source.Description,
                1, GETDATE(), '9999-12-31', 'Initial Load'
            );

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        -- Loading DimRegion 
        SET @start_time = GETDATE();
        PRINT '>> Loading Table: silver.DimRegion';

        MERGE silver.DimRegion AS target
        USING (
            SELECT 
                RegionID,
                RegionDescription
            FROM bronze.Region
        ) AS source
        ON target.RegionID = source.RegionID AND target.RowIsCurrent = 1

        WHEN MATCHED AND (
            target.RegionDescription <> source.RegionDescription
        ) THEN
            UPDATE SET
                RowIsCurrent = 0,
                RowEndDate = GETDATE(),
                RowChangeReason = 'Updated'

        WHEN NOT MATCHED BY TARGET THEN
            INSERT (
                RegionID, RegionDescription,
                RowIsCurrent, RowStartDate, RowEndDate, RowChangeReason
            )
            VALUES (
                source.RegionID, source.RegionDescription,
                1, GETDATE(), '9999-12-31', 'Initial Load'
            );

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        -- Loading DimTerritories 
        SET @start_time = GETDATE();
        PRINT '>> Loading Table: silver.DimTerritories';

        MERGE silver.DimTerritories AS target
        USING (
            SELECT 
                t.TerritoryID,
                t.TerritoryDescription,
                t.RegionID,
                r.RegionDescription
            FROM bronze.Territories t
            JOIN bronze.Region r ON t.RegionID = r.RegionID
        ) AS source
        ON target.TerritoryID = source.TerritoryID AND target.RowIsCurrent = 1

        WHEN MATCHED AND (
            target.TerritoryDescription <> source.TerritoryDescription OR
            target.RegionID <> source.RegionID OR
            target.RegionDescription <> source.RegionDescription
        ) THEN
            UPDATE SET
                RowIsCurrent = 0,
                RowEndDate = GETDATE(),
                RowChangeReason = 'Updated'

        WHEN NOT MATCHED BY TARGET THEN
            INSERT (
                TerritoryID, TerritoryDescription, RegionID, RegionDescription,
                RowIsCurrent, RowStartDate, RowEndDate, RowChangeReason
            )
            VALUES (
                source.TerritoryID, source.TerritoryDescription, source.RegionID, source.RegionDescription,
                1, GETDATE(), '9999-12-31', 'Initial Load'
            );

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        SET @start_time = GETDATE();
        PRINT '>> Loading Table: silver.Orders';
        
        TRUNCATE TABLE silver.Orders;
        INSERT INTO silver.Orders (
            OrderID, CustomerID, EmployeeID, OrderDate, RequiredDate, ShippedDate,
            ShipVia, Freight, ShipName, ShipAddress, ShipCity, ShipRegion, ShipPostalCode, ShipCountry
        )
        SELECT
            OrderID, CustomerID, EmployeeID, OrderDate, RequiredDate, ShippedDate,
            ShipVia, Freight, ShipName,
            CASE 
                WHEN ShipCountry LIKE '%,%' AND CHARINDEX(',', ShipCountry) > 0 
                THEN CONCAT(TRIM(ShipCity), ' - ',TRIM(ShipAddress))
                ELSE ShipAddress
            END AS ShipAddress,
            CASE 
                WHEN ShipCountry LIKE '%,%' AND CHARINDEX(',', ShipCountry) > 0 
                THEN ISNULL(ShipRegion, ShipCity)
                ELSE ShipCity
            END AS ShipCity,
            CASE 
                WHEN ShipRegion is null THEN 'N/A'
                WHEN ShipCountry LIKE '%,%' AND CHARINDEX(',', ShipCountry) > 0 
                THEN 'N/A'
                ELSE ShipRegion
            END AS ShipRegion,
            CASE 
                WHEN ShipPostalCode IS NULL THEN 'N/A'
                WHEN ShipCountry LIKE '%,%' AND CHARINDEX(',', ShipCountry) > 0 
                THEN 
                    REPLACE(
                        SUBSTRING(
                            ShipCountry, 
                            1, 
                            CHARINDEX(',', ShipCountry)
                        ), ',', ''
                    )
                ELSE REPLACE(ShipPostalCode, ',', '')
            END AS ShipPostalCode,
            CASE 
                WHEN ShipCountry LIKE '%,%' AND CHARINDEX(',', ShipCountry) > 0 
                THEN 
                    LTRIM(
                        SUBSTRING(
                            ShipCountry, 
                            CHARINDEX(',', ShipCountry) + 1, 
                            LEN(ShipCountry)
                        )
                    )
                ELSE ShipCountry
            END AS ShipCountry
        FROM bronze.Orders;
        
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        -- Loading OrderDetails 
        SET @start_time = GETDATE();
        PRINT '>> Loading Table: silver.OrderDetails';
        
        TRUNCATE TABLE silver.OrderDetails;
        INSERT INTO silver.OrderDetails (
            OrderID, ProductID, UnitPrice, Quantity, Discount
        )
        SELECT
            OrderID, ProductID, UnitPrice, Quantity, ROUND([Discount], 2)
        FROM bronze.OrderDetails;
        
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        -- Loading Products 
        SET @start_time = GETDATE();
        PRINT '>> Loading Table: silver.Products';
        
        TRUNCATE TABLE silver.Products;
        INSERT INTO silver.Products (
            ProductID, ProductName, SupplierID, CategoryID, QuantityPerUnit,
            UnitPrice, UnitsInStock, UnitsOnOrder, ReorderLevel, Discontinued
        )
        SELECT
            ProductID, ProductName, SupplierID, CategoryID, QuantityPerUnit,
            UnitPrice, UnitsInStock, UnitsOnOrder, ReorderLevel,
            CASE 
                WHEN Discontinued = 1 THEN 'Y' 
                ELSE 'N' 
            END AS Discontinued
        FROM bronze.Products;
        
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        -- Loading Fact Tables 
        -- FactSales 
        SET @start_time = GETDATE();
        PRINT '>> Loading Table: silver.FactSales';
        
        TRUNCATE TABLE silver.FactSales;
        INSERT INTO silver.FactSales (
            DateKey, CustomerKey, EmployeeKey, ProductKey, OrderID,
            UnitPrice, Quantity, Discount, SalesAmount
        )
        SELECT 
            CONVERT(INT, CONVERT(VARCHAR, o.OrderDate, 112)) AS DateKey,
            dc.CustomerKey,
            de.EmployeeKey,
            dp.ProductKey,
            o.OrderID,
            od.UnitPrice,
            od.Quantity,
            od.Discount,
            ROUND((od.UnitPrice * od.Quantity * (1 - od.Discount)), 2) AS SalesAmount
        FROM silver.Orders o
        INNER JOIN silver.OrderDetails od ON o.OrderID = od.OrderID
        INNER JOIN silver.DimCustomer dc ON o.CustomerID = dc.CustomerID AND dc.RowIsCurrent = 1
        INNER JOIN silver.DimEmployee de ON o.EmployeeID = de.EmployeeID AND de.RowIsCurrent = 1
        INNER JOIN silver.DimProducts dp ON od.ProductID = dp.ProductID AND dp.RowIsCurrent = 1;
        
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        -- FactOrderFulfillment 
        SET @start_time = GETDATE();
        PRINT '>> Loading Table: silver.FactOrderFulfillment';
        
        TRUNCATE TABLE silver.FactOrderFulfillment;
        INSERT INTO silver.FactOrderFulfillment (
            OrderDateKey, RequiredDateKey, ShippedDateKey, CustomerKey, EmployeeKey, ShipperKey,
            OrderID, Freight, DaysToShip, DaysLate, OnTimeDelivery
        )
        SELECT 
            CONVERT(INT, CONVERT(VARCHAR, o.OrderDate, 112)) AS OrderDateKey,
            CONVERT(INT, CONVERT(VARCHAR, o.RequiredDate, 112)) AS RequiredDateKey,
            CASE 
                WHEN o.ShippedDate IS NOT NULL 
                THEN CONVERT(INT, CONVERT(VARCHAR, o.ShippedDate, 112))
                ELSE NULL 
            END AS ShippedDateKey,
            dc.CustomerKey,
            de.EmployeeKey,
            ds.ShipperKey,
            o.OrderID,
            o.Freight,
            CASE 
                WHEN o.ShippedDate IS NOT NULL THEN DATEDIFF(DAY, o.OrderDate, o.ShippedDate)
                ELSE NULL 
            END AS DaysToShip,
            CASE 
                WHEN o.ShippedDate IS NOT NULL AND o.ShippedDate > o.RequiredDate 
                THEN DATEDIFF(DAY, o.RequiredDate, o.ShippedDate)
                ELSE 0 
            END AS DaysLate,
            CASE 
                WHEN o.ShippedDate IS NULL THEN 0
                WHEN o.ShippedDate <= o.RequiredDate THEN 1
                ELSE 0 
            END AS OnTimeDelivery
        FROM silver.Orders o
        INNER JOIN silver.DimCustomer dc ON o.CustomerID = dc.CustomerID AND dc.RowIsCurrent = 1
        INNER JOIN silver.DimEmployee de ON o.EmployeeID = de.EmployeeID AND de.RowIsCurrent = 1
        INNER JOIN silver.DimShipper ds ON o.ShipVia = ds.ShipperID AND ds.RowIsCurrent = 1;
        
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        -- FactInventory 
        SET @start_time = GETDATE();
        PRINT '>> Loading Table: silver.FactInventory';
        
        TRUNCATE TABLE silver.FactInventory;
        INSERT INTO silver.FactInventory (
            ProductKey, SupplierKey, CategoryKey,
            UnitsInStock, UnitsOnOrder, ReorderLevel, UnitPrice, StockValue, StockStatus
        )
        SELECT 
            dp.ProductKey,
            ds.SupplierKey,
            dc.CategoryKey,
            p.UnitsInStock,
            p.UnitsOnOrder,
            p.ReorderLevel,
            p.UnitPrice,
            ROUND((p.UnitsInStock * p.UnitPrice), 2) AS StockValue,
            CASE 
                WHEN p.UnitsInStock <= p.ReorderLevel THEN 'Low Stock'
                WHEN p.UnitsInStock > p.ReorderLevel * 2 THEN 'Overstock'
                ELSE 'Normal'
            END AS StockStatus
        FROM silver.Products p
        INNER JOIN silver.DimProducts dp ON p.ProductID = dp.ProductID AND dp.RowIsCurrent = 1
        INNER JOIN silver.DimSupplier ds ON p.SupplierID = ds.SupplierID AND ds.RowIsCurrent = 1
        INNER JOIN silver.DimCategory dc ON p.CategoryID = dc.CategoryID AND dc.RowIsCurrent = 1;
        
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		SET @batch_end_time = GETDATE();
		PRINT '=========================================='
		PRINT 'Loading Silver Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '=========================================='
		
	END TRY
	BEGIN CATCH
		PRINT '=========================================='
		PRINT 'ERROR OCCURRED DURING LOADING SILVER LAYER'
		PRINT 'Error Message: ' + ERROR_MESSAGE();
		PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '=========================================='
	END CATCH
END