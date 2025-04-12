--EXEC bronze.load_bronze;


CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Loading Bronze Layer';
        PRINT '================================================';

        PRINT '------------------------------------------------';
        PRINT 'Loading Categories Table';
        PRINT '------------------------------------------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.Categories';
        TRUNCATE TABLE bronze.Categories;
        PRINT '>> Inserting Data Into: bronze.Categories';
        BULK INSERT bronze.Categories
        FROM 'E:\dwh_project\datasets\Categories.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		PRINT '------------------------------------------------';
        PRINT 'Loading Customers Table';
        PRINT '------------------------------------------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.Customers';
        TRUNCATE TABLE bronze.Customers;
        PRINT '>> Inserting Data Into: bronze.Customers';
        BULK INSERT bronze.Customers
        FROM 'E:\dwh_project\datasets\Customers.csv'
        WITH (
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				CODEPAGE = '65001', -- For UTF-8 encoding
				FORMAT = 'CSV',
				TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		PRINT '------------------------------------------------';
        PRINT 'Loading Employees Table';
        PRINT '------------------------------------------------';


        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.Employees';
        TRUNCATE TABLE bronze.Employees;
        PRINT '>> Inserting Data Into: bronze.Employees';
        BULK INSERT bronze.Employees
        FROM 'E:\dwh_project\datasets\Employees.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';


		PRINT '------------------------------------------------';
        PRINT 'Loading EmployeeTerritories Table';
        PRINT '------------------------------------------------';


        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.EmployeeTerritories';
        TRUNCATE TABLE bronze.EmployeeTerritories;
        PRINT '>> Inserting Data Into: bronze.EmployeeTerritories';
        BULK INSERT bronze.EmployeeTerritories
        FROM 'E:\dwh_project\datasets\EmployeeTerritories.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		PRINT '------------------------------------------------';
        PRINT 'Loading Region Table';
        PRINT '------------------------------------------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.Region';
        TRUNCATE TABLE bronze.Region;
        PRINT '>> Inserting Data Into: bronze.Region';
        BULK INSERT bronze.Region
        FROM 'E:\dwh_project\datasets\Region.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		PRINT '------------------------------------------------';
        PRINT 'Loading Shippers Table';
        PRINT '------------------------------------------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.Shippers';
        TRUNCATE TABLE bronze.Shippers;
        PRINT '>> Inserting Data Into: bronze.Shippers';
        BULK INSERT bronze.Shippers
        FROM 'E:\dwh_project\datasets\Shippers.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		PRINT '------------------------------------------------';
        PRINT 'Loading Suppliers Table';
        PRINT '------------------------------------------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.Suppliers';
        TRUNCATE TABLE bronze.Suppliers;
        PRINT '>> Inserting Data Into: bronze.Suppliers';
        BULK INSERT bronze.Suppliers
        FROM 'E:\dwh_project\datasets\Suppliers.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			FORMAT = 'CSV',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		PRINT '------------------------------------------------';
        PRINT 'Loading Territories Table';
        PRINT '------------------------------------------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.Territories';
        TRUNCATE TABLE bronze.Territories;
        PRINT '>> Inserting Data Into: bronze.Territories';
        BULK INSERT bronze.Territories
        FROM 'E:\dwh_project\datasets\Territories.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			FORMAT = 'CSV',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		PRINT '------------------------------------------------';
        PRINT 'Loading Products Table';
        PRINT '------------------------------------------------';


		SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.Products';
        TRUNCATE TABLE bronze.Products;
        PRINT '>> Inserting Data Into: bronze.Products';
        BULK INSERT bronze.Products
        FROM 'E:\dwh_project\datasets\Products.csv'
        WITH (
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			CODEPAGE = '65001',
			FORMAT = 'CSV',
			FIRSTROW = 2,
			TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';


		PRINT '------------------------------------------------';
        PRINT 'Loading OrderDetails Table';
        PRINT '------------------------------------------------';


		SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.OrderDetails';
        TRUNCATE TABLE bronze.OrderDetails;
        PRINT '>> Inserting Data Into: bronze.OrderDetails';
        BULK INSERT bronze.OrderDetails
        FROM 'E:\dwh_project\datasets\OrderDetails.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            FORMAT = 'CSV',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';


		PRINT '------------------------------------------------';
        PRINT 'Loading Orders Table';
        PRINT '------------------------------------------------';


		SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.Orders';
        TRUNCATE TABLE bronze.Orders;
        PRINT '>> Inserting Data Into: bronze.Orders';
        BULK INSERT bronze.Orders
        FROM 'E:\dwh_project\datasets\Orders.csv'
        WITH (
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			FIRSTROW = 2
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';



        SET @batch_end_time = GETDATE();
        PRINT '==========================================';
        PRINT 'Loading Bronze Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '==========================================';
    END TRY
    BEGIN CATCH
        PRINT '==========================================';
        PRINT 'ERROR OCCURRED DURING LOADING BRONZE LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '==========================================';
    END CATCH
END
GO

