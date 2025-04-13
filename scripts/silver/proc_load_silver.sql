--EXEC Silver.load_silver;

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Loading Silver Layer';
        PRINT '================================================';

		-- Loading categories
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.Categories';
		TRUNCATE TABLE silver.Categories;
		PRINT '>> Inserting Data Into: silver.Categories';

		INSERT INTO silver.Categories (
			CategoryID,
			CategoryName,
			Description,
			Picture
		)
		SELECT
			CategoryID,
			CategoryName,
			REPLACE([Description], '"', '') AS Description,
			Picture
		FROM bronze.Categories;

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';


		-- Loading customers
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.Customers';
		TRUNCATE TABLE silver.Categories;
		PRINT '>> Inserting Data Into: silver.Customers';

		INSERT INTO silver.Customers (
			CustomerID ,
			CompanyName ,
			ContactName ,
			ContactTitle ,
			Address ,
			City ,
			Region ,
			PostalCode ,
			Country ,
			Phone ,
			Fax 
		)
		SELECT
			CustomerID ,
			CompanyName ,
			ContactName ,
			ContactTitle ,
			Address ,
			City ,
			CASE 
					WHEN Region = 'NULL' THEN 'N/A' 
					ELSE Region 
			END AS Region ,
			PostalCode ,
			CASE
					WHEN TRIM(Country) = 'UK' THEN 'United Kingdom'
					WHEN TRIM(Country) IN ('US', 'USA') THEN 'United States'
					WHEN TRIM(Country) = '' OR Country IS NULL THEN 'n/a'
					ELSE TRIM(Country)
			END AS Country,
			CASE 
					WHEN Phone IS NULL OR TRIM(Phone) = '' OR LOWER(TRIM(Phone)) = 'null' THEN 'N/A'
					ELSE REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(Phone, '(', ''), ')', ''), '.', ''), '-', ''), ' ', '')
			END AS Phone ,
			CASE 
						WHEN Fax IS NULL OR TRIM(Fax) = '' OR LOWER(TRIM(Fax)) = 'null' THEN 'N/A'
						ELSE REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(Fax, '(', ''), ')', ''), '.', ''), '-', ''), ' ', '')
			END AS  Fax
		FROM bronze.Customers;

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';


		-- Loading Territories
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.Territories';
		TRUNCATE TABLE silver.Categories;
		PRINT '>> Inserting Data Into: silver.Territories';

		INSERT INTO silver.Territories (
			TerritoryID ,
			TerritoryDescription ,
			RegionID
		)
		SELECT
			TerritoryID ,
			TerritoryDescription ,
			RegionID
		FROM bronze.Territories;

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';


		-- Loading Suppliers
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.Suppliers';
		TRUNCATE TABLE silver.Categories;
		PRINT '>> Inserting Data Into: silver.Suppliers';

		INSERT INTO silver.Suppliers (
			SupplierID ,
			CompanyName ,
			ContactName ,
			ContactTitle ,
			Address ,
			City ,
			Region ,
			PostalCode ,
			Country ,
			Phone ,
			Fax ,
			HomePage 
		)
		SELECT
			SupplierID ,
			CompanyName ,
			ContactName ,
			ContactTitle ,
			Address ,
			City ,
			CASE 
					WHEN Region is null THEN 'N/A' 
					ELSE Region 
			END AS Region ,
			PostalCode ,
			CASE
					WHEN TRIM(Country) = 'UK' THEN 'United Kingdom'
					WHEN TRIM(Country) IN ('US', 'USA') THEN 'United States'
					WHEN TRIM(Country) = '' OR Country IS NULL THEN 'n/a'
					ELSE TRIM(Country)
			END AS Country,
			CASE 
					WHEN Phone IS NULL OR TRIM(Phone) = '' OR LOWER(TRIM(Phone)) = 'null' THEN 'N/A'
					ELSE REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(Phone, '(', ''), ')', ''), '.', ''), '-', ''), ' ', '')
			END AS Phone ,
			CASE 
						WHEN Fax IS NULL OR TRIM(Fax) = '' OR LOWER(TRIM(Fax)) = 'null' THEN 'N/A'
						ELSE REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(Fax, '(', ''), ')', ''), '.', ''), '-', ''), ' ', '')
			END AS  Fax,
			CASE 
					WHEN HomePage is null THEN 'N/A' 
					ELSE HomePage 
			END AS HomePage 	 
		FROM bronze.Suppliers;

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';


		-- Loading Shippers
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.Shippers';
		TRUNCATE TABLE silver.Categories;
		PRINT '>> Inserting Data Into: silver.Shippers';

		INSERT INTO silver.Shippers (
			ShipperID ,
			CompanyName ,
			Phone 
		)
		SELECT
			ShipperID ,
			CompanyName ,
			Phone 
		FROM bronze.Shippers;

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';


		-- Loading Region
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.Region';
		TRUNCATE TABLE silver.Region;
		PRINT '>> Inserting Data Into: silver.Region';

		INSERT INTO silver.Region (
				RegionID ,
				RegionDescription 
		)
		SELECT
				RegionID ,
				RegionDescription 
		FROM bronze.Region;

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';


		-- Loading Products
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.Products';
		TRUNCATE TABLE silver.Products;
		PRINT '>> Inserting Data Into: silver.Products';

		INSERT INTO silver.Products (
				ProductID ,
				ProductName ,
				SupplierID ,
				CategoryID ,
				QuantityPerUnit ,
				UnitPrice ,
				UnitsInStock ,
				UnitsOnOrder ,
				ReorderLevel ,
				Discontinued 
		)
		SELECT
				ProductID ,
				ProductName ,
				SupplierID ,
				CategoryID ,
				QuantityPerUnit ,
				UnitPrice ,
				UnitsInStock ,
				UnitsOnOrder ,
				ReorderLevel ,
				CASE 
						WHEN Discontinued = 1 THEN 'Y' 
						ELSE 'N' 
				END Discontinued
		FROM bronze.Products;

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';


		-- Loading Orders
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.Orders';
		TRUNCATE TABLE silver.Orders;
		PRINT '>> Inserting Data Into: silver.Orders';

		INSERT INTO silver.Orders (
				OrderID ,
				CustomerID ,
				EmployeeID ,
				OrderDate ,
				RequiredDate ,
				ShippedDate ,
				ShipVia ,
				Freight ,
				ShipName ,
				ShipAddress ,
				ShipCity ,
				ShipRegion ,
				ShipPostalCode ,
				ShipCountry
		)
		SELECT
				OrderID ,
				CustomerID ,
				EmployeeID ,
				OrderDate ,
				RequiredDate ,
				ShippedDate ,
				ShipVia ,
				Freight ,
				ShipName ,
				CASE 
					-- When ShipCountry contains postal code pattern, concatenate ShipCity with ShipAddress
					WHEN ShipCountry LIKE '%,%' AND CHARINDEX(',', ShipCountry) > 0 
					THEN CONCAT(TRIM(ShipCity), ' - ',TRIM(ShipAddress))
					ELSE ShipAddress
				END AS ShipAddress,
        
				CASE 
					-- When ShipCountry contains postal code pattern, use ShipRegion as ShipCity
					WHEN ShipCountry LIKE '%,%' AND CHARINDEX(',', ShipCountry) > 0 
					THEN ISNULL(ShipRegion, ShipCity)
					ELSE ShipCity
				END AS ShipCity,
        
				CASE 
					-- When ShipCountry contains postal code pattern, set ShipRegion to NULL
					WHEN ShipRegion is null THEN 'N/A'
					WHEN ShipCountry LIKE '%,%' AND CHARINDEX(',', ShipCountry) > 0 
					THEN 'N/A'
					ELSE ShipRegion
				END AS ShipRegion,
        
				CASE 
					-- When ShipCountry contains postal code pattern, extract the postal code part
					WHEN ShipPostalCode is null THEN 'N/A'
					WHEN ShipCountry LIKE '%,%' AND CHARINDEX(',', ShipCountry) > 0 
					THEN 
						SUBSTRING(
							ShipCountry, 
							1, 
							CHARINDEX(',', ShipCountry)
						)
					ELSE ShipPostalCode
				END AS ShipPostalCode,
        
				CASE 
					-- When ShipCountry contains postal code pattern, extract just the country part
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
		PRINT '>> Truncating Table: silver.OrderDetails';
		TRUNCATE TABLE silver.OrderDetails;
		PRINT '>> Inserting Data Into: silver.OrderDetails';

		INSERT INTO silver.OrderDetails (
				OrderID ,
				ProductID ,
				UnitPrice ,
				Quantity ,
				Discount 
		)
		SELECT
				OrderID ,
				ProductID ,
				UnitPrice ,
				Quantity ,
				ROUND([Discount],2) 
		FROM bronze.OrderDetails;

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';


		-- Loading EmployeeTerritories
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.EmployeeTerritories';
		TRUNCATE TABLE silver.EmployeeTerritories;
		PRINT '>> Inserting Data Into: silver.EmployeeTerritories';

		INSERT INTO silver.EmployeeTerritories (
					EmployeeID ,
					TerritoryID 
		)
		SELECT
					EmployeeID ,
					TerritoryID 
		FROM bronze.EmployeeTerritories;

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';


		-- Loading Employees
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.Employees';
		TRUNCATE TABLE silver.Employees;
		PRINT '>> Inserting Data Into: silver.Employees';

		INSERT INTO silver.Employees (
				EmployeeID ,
				LastName ,
				FirstName ,
				Title ,
				TitleOfCourtesy,
				BirthDate ,
				HireDate ,
				Address ,
				City ,
				Region ,
				PostalCode ,
				Country ,
				HomePhone ,
				Extension ,
				Photo 
		)
		SELECT
				EmployeeID ,
				LastName ,
				FirstName ,
				Title ,
				TitleOfCourtesy,
				BirthDate ,
				HireDate ,
				REPLACE([Address], '"', '') ASAddress ,
				City ,
				CASE 
					WHEN Region is null THEN 'N/A'
					ELSE Region
				END AS Region,
				PostalCode ,
				CASE
					WHEN TRIM(Country) = 'UK' THEN 'United Kingdom'
					WHEN TRIM(Country) IN ('US', 'USA') THEN 'United States'
					WHEN TRIM(Country) = '' OR Country IS NULL THEN 'n/a'
					ELSE TRIM(Country)
				END AS Country ,
				HomePhone ,
				Extension ,
				Photo 
		FROM bronze.Employees;

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';


		-- Loading Date
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.Date';
		TRUNCATE TABLE silver.Date;
		PRINT '>> Inserting Data Into: silver.Date';

		INSERT INTO silver.Date (
				date_key ,
				full_date ,
				day_of_week ,
				day_num_in_month ,
				day_num_overall ,
				day_name ,
				day_abbrev ,
				weekday_flag ,
				week_num_in_year ,
				week_num_overall ,
				week_begin_date ,
				week_begin_date_key ,
				month ,
				month_num_overall ,
				month_name ,
				month_abbrev ,
				quarter ,
				year ,
				yearmo ,
				fiscal_month ,
				fiscal_quarter ,
				fiscal_year ,
				last_day_in_month_flag ,
				same_day_year_ago_date 
		)
		SELECT
				date_key ,
				full_date ,
				day_of_week ,
				day_num_in_month ,
				day_num_overall ,
				day_name ,
				day_abbrev ,
				weekday_flag ,
				week_num_in_year ,
				week_num_overall ,
				week_begin_date ,
				week_begin_date_key ,
				month ,
				month_num_overall ,
				month_name ,
				month_abbrev ,
				quarter ,
				year ,
				yearmo ,
				fiscal_month ,
				fiscal_quarter ,
				fiscal_year ,
				last_day_in_month_flag ,
				same_day_year_ago_date 
		FROM bronze.Date;

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
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '=========================================='
	END CATCH
END