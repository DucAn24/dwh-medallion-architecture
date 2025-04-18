--EXEC gold.load_gold 

CREATE OR ALTER PROCEDURE gold.load_gold 
AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Loading Gold Layer';
        PRINT '================================================';

        -- Loading DimDate
        SET @start_time = GETDATE();
        PRINT '>> Loading Table: gold.DimDate';
       
        
		INSERT INTO gold.DimDate (
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
		FROM silver.Date s
		WHERE NOT EXISTS (
			SELECT 1 FROM gold.DimDate d WHERE d.DateKey = s.date_key
		);
        
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';
        
        -- Loading DimCustomer with SCD Type 2
        SET @start_time = GETDATE();
        PRINT '>> Loading Table: gold.DimCustomer';
        
        -- SCD Type 2 - Merge for DimCustomer
        MERGE gold.DimCustomer AS target
        USING (
            SELECT 
                CustomerID,
                CompanyName,
                ContactName,
                ContactTitle,
                Country AS CustomerCountry,
                Region AS CustomerRegion,
                City AS CustomerCity,
                PostalCode AS CustomerPostalCode
            FROM silver.Customers
        ) AS source
        ON target.CustomerID = source.CustomerID AND target.RowIsCurrent = 1
        
        -- When matched and there's a change, update the current record to not current
        WHEN MATCHED AND (
            target.CompanyName <> source.CompanyName OR
            target.ContactName <> source.ContactName OR
            target.ContactTitle <> source.ContactTitle OR
            target.CustomerCountry <> source.CustomerCountry OR
            target.CustomerRegion <> source.CustomerRegion OR
            target.CustomerCity <> source.CustomerCity OR
            target.CustomerPostalCode <> source.CustomerPostalCode
        ) THEN
            UPDATE SET
                RowIsCurrent = 0,
                RowEndDate = GETDATE(),
                RowChangeReason = 'Updated'
        
        -- When not matched by target, insert a new record
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
        INSERT INTO gold.DimCustomer (
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
                Country AS CustomerCountry,
                Region AS CustomerRegion,
                City AS CustomerCity,
                PostalCode AS CustomerPostalCode
            FROM silver.Customers
        ) AS s
        INNER JOIN gold.DimCustomer AS d
            ON s.CustomerID = d.CustomerID AND d.RowIsCurrent = 0
            AND d.RowEndDate = GETDATE();
            
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';
        
        -- Loading DimEmployee with SCD Type 2
        SET @start_time = GETDATE();
        PRINT '>> Loading Table: gold.DimEmployee';
        
        -- SCD Type 2 - Merge for DimEmployee
        MERGE gold.DimEmployee AS target
        USING (
            SELECT 
                EmployeeID,
                FirstName + ' ' + LastName AS EmployeeName,
                Title AS EmployeeTitle
            FROM silver.Employees
        ) AS source
        ON target.EmployeeID = source.EmployeeID AND target.RowIsCurrent = 1
        
        -- When matched and there's a change, update the current record to not current
        WHEN MATCHED AND (
            target.EmployeeName <> source.EmployeeName OR
            target.EmployeeTitle <> source.EmployeeTitle
        ) THEN
            UPDATE SET
                RowIsCurrent = 0,
                RowEndDate = GETDATE(),
                RowChangeReason = 'Updated'
        
        -- When not matched by target, insert a new record
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
        INSERT INTO gold.DimEmployee (
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
            FROM silver.Employees
        ) AS s
        INNER JOIN gold.DimEmployee AS d
            ON s.EmployeeID = d.EmployeeID AND d.RowIsCurrent = 0
            AND d.RowEndDate = GETDATE();
            
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';
        
        -- Loading DimProducts with SCD Type 2
        SET @start_time = GETDATE();
        PRINT '>> Loading Table: gold.DimProducts';
        
---------------- SCD Type 2 - Merge for DimProducts
        MERGE gold.DimProducts AS target
        USING (
            SELECT 
                p.ProductID,
                p.ProductName,
				p.Discontinued,
                c.CategoryName,
                s.CompanyName AS SupplierName
            FROM silver.Products p
            JOIN silver.Categories c ON p.CategoryID = c.CategoryID
            JOIN silver.Suppliers s ON p.SupplierID = s.SupplierID
        ) AS source
        ON target.ProductID = source.ProductID AND target.RowIsCurrent = 1
        
        -- When matched and there's a change, update the current record to not current
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
        
        -- When not matched by target, insert a new record
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
        INSERT INTO gold.DimProducts (
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
				p.Discontinued,
                c.CategoryName,
                s.CompanyName AS SupplierName
            FROM silver.Products p
            JOIN silver.Categories c ON p.CategoryID = c.CategoryID
            JOIN silver.Suppliers s ON p.SupplierID = s.SupplierID
        ) AS s
        INNER JOIN gold.DimProducts AS d
            ON s.ProductID = d.ProductID AND d.RowIsCurrent = 0
            AND d.RowEndDate = GETDATE();
            
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';


----------------- Loading DimShipper with SCD Type 2
		SET @start_time = GETDATE();
		PRINT '>> Loading Table: gold.DimShipper';
        
		-- SCD Type 2 - Merge for DimShipper
		MERGE gold.DimShipper AS target
		USING (
			SELECT 
				ShipperID,
				CompanyName,
				Phone
			FROM silver.Shippers
		) AS source
		ON target.ShipperID = source.ShipperID AND target.RowIsCurrent = 1

		-- When matched and there's a change, update the current record to not current
		WHEN MATCHED AND (
			target.CompanyName <> source.CompanyName OR
			ISNULL(target.Phone,'') <> ISNULL(source.Phone,'')
		) THEN
			UPDATE SET
				RowIsCurrent = 0,
				RowEndDate = GETDATE(),
				RowChangeReason = 'Updated'

		-- When not matched by target, insert a new record
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




----------- Loading DimSupplier with SCD Type 2
		SET @start_time = GETDATE();
		PRINT '>> Loading Table: gold.DimSupplier';
        
		-- SCD Type 2 - Merge for DimSupplier
		MERGE gold.DimSupplier AS target
		USING (
			SELECT 
				SupplierID,
				CompanyName,
				ContactName,
				ContactTitle,
				Address,
				City,
				Region,
				PostalCode,
				Country,
				Phone
			FROM silver.Suppliers
		) AS source
		ON target.SupplierID = source.SupplierID AND target.RowIsCurrent = 1

		-- When matched and there's a change, update the current record
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

		-- When not matched by target, insert a new record
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


---------- Loading DimCategory
		SET @start_time = GETDATE();
		PRINT '>> Loading Table: gold.DimCategory';

		MERGE gold.DimCategory AS target
		USING (
			SELECT 
				CategoryID,
				CategoryName,
				Description
			FROM silver.Categories
		) AS source
		ON target.CategoryID = source.CategoryID AND target.RowIsCurrent = 1

		-- When matched and there's a change, update the current record
		WHEN MATCHED AND (
			target.CategoryName <> source.CategoryName OR
			ISNULL(target.Description,'') <> ISNULL(source.Description,'')
		) THEN
			UPDATE SET
				RowIsCurrent = 0,
				RowEndDate = GETDATE(),
				RowChangeReason = 'Updated'

		-- When not matched by target, insert a new record
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

        
---------------- Loading FactSales------------------------

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: gold.FactSales';
		TRUNCATE TABLE gold.FactSales;
        PRINT '>> Loading Table: gold.FactSales';
    
        
        INSERT INTO gold.FactSales (
            OrderID, ProductKey, CustomerKey, EmployeeKey,
            OrderDateKey, ShippedDateKey, Quantity,
            ExtendedPriceAmount, DiscountAmount, SoldAmount
        )
        SELECT 
            od.OrderID,
            p.ProductKey,
            c.CustomerKey,
            e.EmployeeKey,
            CONVERT(INT, FORMAT(o.OrderDate, 'yyyyMMdd')) AS OrderDateKey,
            CASE WHEN o.ShippedDate IS NULL THEN NULL
                ELSE CONVERT(INT, FORMAT(o.ShippedDate, 'yyyyMMdd'))
            END AS ShippedDateKey,
            od.Quantity,
            od.UnitPrice * od.Quantity AS ExtendedPriceAmount,
			od.UnitPrice * od.Quantity * TRY_CAST(od.Discount AS FLOAT) AS DiscountAmount,
			od.UnitPrice * od.Quantity * (1 - TRY_CAST(od.Discount AS FLOAT)) AS SoldAmount
        FROM silver.OrderDetails od
        JOIN silver.Orders o ON od.OrderID = o.OrderID
        JOIN gold.DimProducts p ON od.ProductID = p.ProductID AND p.RowIsCurrent = 1
        JOIN gold.DimCustomer c ON o.CustomerID = c.CustomerID AND c.RowIsCurrent = 1
        JOIN gold.DimEmployee e ON o.EmployeeID = e.EmployeeID AND e.RowIsCurrent = 1;
        
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';
        
------------ Loading FactOrderFulfillment------------------------

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: gold.FactOrderFulfillment';
		TRUNCATE TABLE gold.FactOrderFulfillment;
        PRINT '>> Loading Table: gold.FactOrderFulfillment';
        
        INSERT INTO gold.FactOrderFulfillment (
			OrderID, CustomerKey, EmployeeKey, ShipperKey,
			OrderDateKey, RequiredDateKey, ShippedDateKey,
			Freight, OrderToShipDays, IsOrderDelayed, DaysDelayed,
			ShipRegion, ShipCity, ShipCountry, 
			TotalOrderItems, TotalOrderAmount
		)
		SELECT 
			o.OrderID,
			c.CustomerKey,
			e.EmployeeKey,
			s.ShipperKey,
			CONVERT(INT, FORMAT(o.OrderDate, 'yyyyMMdd')) AS OrderDateKey,
			CONVERT(INT, FORMAT(o.RequiredDate, 'yyyyMMdd')) AS RequiredDateKey,
			CASE WHEN o.ShippedDate IS NULL THEN NULL
				ELSE CONVERT(INT, FORMAT(o.ShippedDate, 'yyyyMMdd'))
			END AS ShippedDateKey,
			o.Freight,
			CASE WHEN o.ShippedDate IS NULL THEN NULL
				ELSE DATEDIFF(DAY, o.OrderDate, o.ShippedDate)
			END AS OrderToShipDays,
			CASE WHEN o.ShippedDate IS NULL THEN NULL
				WHEN o.ShippedDate > o.RequiredDate THEN 1
				ELSE 0
			END AS IsOrderDelayed,
			CASE WHEN o.ShippedDate IS NULL THEN NULL
				WHEN o.ShippedDate > o.RequiredDate THEN DATEDIFF(DAY, o.RequiredDate, o.ShippedDate)
				ELSE 0
			END AS DaysDelayed,
			o.ShipRegion,
			o.ShipCity,
			o.ShipCountry,
			-- Calculate number of items in order
			(SELECT COUNT(*) FROM silver.OrderDetails WHERE OrderID = o.OrderID) AS TotalOrderItems,
			-- Calculate total order amount
			(SELECT SUM(UnitPrice * Quantity * (1 - CAST(Discount AS FLOAT))) 
			 FROM silver.OrderDetails 
			 WHERE OrderID = o.OrderID) AS TotalOrderAmount
		FROM silver.Orders o
		JOIN gold.DimCustomer c ON o.CustomerID = c.CustomerID AND c.RowIsCurrent = 1
		JOIN gold.DimEmployee e ON o.EmployeeID = e.EmployeeID AND e.RowIsCurrent = 1
		JOIN gold.DimShipper s ON o.ShipVia = s.ShipperID AND s.RowIsCurrent = 1;
        
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';
        
---------- Loading FactInventory---------------
		
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: gold.FactInventory';
		TRUNCATE TABLE gold.FactInventory;
        PRINT '>> Loading Table: gold.FactInventory';

		INSERT INTO gold.FactInventory (
			ProductKey, SupplierKey, CategoryKey,
			UnitsInStock, UnitsOnOrder, ReorderLevel, LeadTimeDays,
			Discontinued, InventoryValue, DaysSinceLastOrder,
			DaysSinceLastShipment, StockCoverDays, QuantityPerUnit, SafetyStockLevel
		)
		SELECT 
			p.ProductKey,
			s.SupplierKey,
			c.CategoryKey,
			sp.UnitsInStock,
			sp.UnitsOnOrder,
			sp.ReorderLevel,
			-- Estimated lead time from order data
			(SELECT AVG(DATEDIFF(DAY, o.OrderDate, o.ShippedDate))
				FROM silver.Orders o
				JOIN silver.OrderDetails od ON o.OrderID = od.OrderID
				WHERE od.ProductID = sp.ProductID
				AND o.ShippedDate IS NOT NULL) AS LeadTimeDays,
			sp.Discontinued,
			sp.UnitPrice * sp.UnitsInStock AS InventoryValue,
			-- Days since last order
			CASE 
				WHEN EXISTS (
					SELECT 1 FROM silver.OrderDetails od
					JOIN silver.Orders o ON od.OrderID = o.OrderID
					WHERE od.ProductID = sp.ProductID
				) THEN 
					DATEDIFF(DAY, 
						(SELECT MAX(o.OrderDate) FROM silver.OrderDetails od
						JOIN silver.Orders o ON od.OrderID = o.OrderID
						WHERE od.ProductID = sp.ProductID), 
						GETDATE())
				ELSE NULL
			END AS DaysSinceLastOrder,
			-- Days since last shipment
			CASE 
				WHEN EXISTS (
					SELECT 1 FROM silver.OrderDetails od
					JOIN silver.Orders o ON od.OrderID = o.OrderID
					WHERE od.ProductID = sp.ProductID AND o.ShippedDate IS NOT NULL
				) THEN 
					DATEDIFF(DAY, 
						(SELECT MAX(o.ShippedDate) FROM silver.OrderDetails od
						JOIN silver.Orders o ON od.OrderID = o.OrderID
						WHERE od.ProductID = sp.ProductID AND o.ShippedDate IS NOT NULL), 
						GETDATE())
				ELSE NULL
			END AS DaysSinceLastShipment,
			-- Stock cover days (based on average daily sales)
			CASE 
				WHEN sp.UnitsInStock > 0 THEN
					sp.UnitsInStock / 
					NULLIF((SELECT SUM(od.Quantity) / NULLIF(DATEDIFF(DAY, MIN(o.OrderDate), MAX(o.OrderDate)), 0)
							FROM silver.OrderDetails od
							JOIN silver.Orders o ON od.OrderID = o.OrderID
							WHERE od.ProductID = sp.ProductID), 0)
				ELSE 0
			END AS StockCoverDays,
			sp.QuantityPerUnit,
			-- Calculate safety stock (ReorderLevel + 20%)
			CASE 
				WHEN sp.ReorderLevel IS NOT NULL THEN sp.ReorderLevel * 1.2
				ELSE NULL
			END AS SafetyStockLevel
		FROM silver.Products sp
		JOIN gold.DimProducts p ON sp.ProductID = p.ProductID AND p.RowIsCurrent = 1
		JOIN gold.DimSupplier s ON sp.SupplierID = s.SupplierID AND s.RowIsCurrent = 1
		JOIN gold.DimCategory c ON sp.CategoryID = c.CategoryID AND c.RowIsCurrent = 1;
        
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
END;
GO