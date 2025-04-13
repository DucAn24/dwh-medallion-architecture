-- Categories table
IF OBJECT_ID('silver.Categories', 'U') IS NOT NULL
    DROP TABLE silver.Categories;
GO

CREATE TABLE silver.Categories (
    CategoryID INT,
    CategoryName NVARCHAR(50),
    Description NVARCHAR(MAX),
    Picture NVARCHAR(MAX),
	dwh_create_date    DATETIME2 DEFAULT GETDATE()
);
GO

-- Customers table
IF OBJECT_ID('silver.Customers', 'U') IS NOT NULL
    DROP TABLE silver.Customers;
GO

CREATE TABLE silver.Customers (
    CustomerID NVARCHAR(10),
    CompanyName NVARCHAR(100),
    ContactName NVARCHAR(100),
    ContactTitle NVARCHAR(100),
    Address NVARCHAR(100),
    City NVARCHAR(50),
    Region NVARCHAR(50),
    PostalCode NVARCHAR(20),
    Country NVARCHAR(50),
    Phone NVARCHAR(30),
    Fax NVARCHAR(30),
	dwh_create_date    DATETIME2 DEFAULT GETDATE()
);
GO

-- Employees table
IF OBJECT_ID('silver.Employees', 'U') IS NOT NULL
    DROP TABLE silver.Employees;
GO

CREATE TABLE silver.Employees (
    EmployeeID INT,
    LastName NVARCHAR(50),
    FirstName NVARCHAR(50),
    Title NVARCHAR(100),
    TitleOfCourtesy NVARCHAR(20),
    BirthDate DATETIME,
    HireDate DATETIME,
    Address NVARCHAR(100),
    City NVARCHAR(50),
    Region NVARCHAR(50),
    PostalCode NVARCHAR(20),
    Country NVARCHAR(50),
    HomePhone NVARCHAR(30),
    Extension NVARCHAR(10),
    Photo NVARCHAR(MAX),
	dwh_create_date    DATETIME2 DEFAULT GETDATE()
);
GO

-- EmployeeTerritories table
IF OBJECT_ID('silver.EmployeeTerritories', 'U') IS NOT NULL
    DROP TABLE silver.EmployeeTerritories;
GO

CREATE TABLE silver.EmployeeTerritories (
    EmployeeID INT,
    TerritoryID NVARCHAR(20),
	dwh_create_date    DATETIME2 DEFAULT GETDATE()
);
GO

-- OrderDetails table
IF OBJECT_ID('silver.OrderDetails', 'U') IS NOT NULL
    DROP TABLE silver.OrderDetails;
GO

CREATE TABLE silver.OrderDetails (
    OrderID INT,
    ProductID INT,
    UnitPrice DECIMAL(10, 2),
    Quantity INT,
    Discount NVARCHAR(MAX),
	dwh_create_date    DATETIME2 DEFAULT GETDATE()
);
GO

-- Orders table
IF OBJECT_ID('silver.Orders', 'U') IS NOT NULL
    DROP TABLE silver.Orders;
GO

CREATE TABLE silver.Orders (
    OrderID INT,
    CustomerID NVARCHAR(10),
    EmployeeID INT,
    OrderDate DATETIME,
    RequiredDate DATETIME,
    ShippedDate DATETIME,
    ShipVia INT,
    Freight DECIMAL(10, 2),
    ShipName NVARCHAR(100),
    ShipAddress NVARCHAR(100),
    ShipCity NVARCHAR(50),
    ShipRegion NVARCHAR(50),
    ShipPostalCode NVARCHAR(20),
    ShipCountry NVARCHAR(50),
	dwh_create_date    DATETIME2 DEFAULT GETDATE()
);
GO

-- Products table
IF OBJECT_ID('silver.Products', 'U') IS NOT NULL
    DROP TABLE silver.Products;
GO

CREATE TABLE silver.Products (
    ProductID INT,
    ProductName NVARCHAR(100),
    SupplierID INT,
    CategoryID INT,
    QuantityPerUnit NVARCHAR(50),
    UnitPrice DECIMAL(10, 2),
    UnitsInStock INT,
    UnitsOnOrder INT,
    ReorderLevel INT,
    Discontinued NVARCHAR(1),
	dwh_create_date    DATETIME2 DEFAULT GETDATE()
);
GO

-- Region table
IF OBJECT_ID('silver.Region', 'U') IS NOT NULL
    DROP TABLE silver.Region;
GO

CREATE TABLE silver.Region (
    RegionID INT,
    RegionDescription NVARCHAR(50),
	dwh_create_date    DATETIME2 DEFAULT GETDATE()
);
GO

-- Shippers table
IF OBJECT_ID('silver.Shippers', 'U') IS NOT NULL
    DROP TABLE silver.Shippers;
GO

CREATE TABLE silver.Shippers (
    ShipperID INT,
    CompanyName NVARCHAR(100),
    Phone NVARCHAR(30),
	dwh_create_date    DATETIME2 DEFAULT GETDATE()
);
GO

-- Suppliers table
IF OBJECT_ID('silver.Suppliers', 'U') IS NOT NULL
    DROP TABLE silver.Suppliers;
GO

CREATE TABLE silver.Suppliers (
    SupplierID INT,
    CompanyName NVARCHAR(100),
    ContactName NVARCHAR(100),
    ContactTitle NVARCHAR(100),
    Address NVARCHAR(100),
    City NVARCHAR(50),
    Region NVARCHAR(50),
    PostalCode NVARCHAR(20),
    Country NVARCHAR(50),
    Phone NVARCHAR(30),
    Fax NVARCHAR(30),
    HomePage NVARCHAR(MAX),
	dwh_create_date    DATETIME2 DEFAULT GETDATE()
);
GO

-- Territories table
IF OBJECT_ID('silver.Territories', 'U') IS NOT NULL
    DROP TABLE silver.Territories;
GO

CREATE TABLE silver.Territories (
    TerritoryID NVARCHAR(20),
    TerritoryDescription NVARCHAR(50),
    RegionID INT,
	dwh_create_date    DATETIME2 DEFAULT GETDATE()
);
GO

-- Create Date table
IF OBJECT_ID('silver.Date', 'U') IS NOT NULL
    DROP TABLE silver.Date;
GO

CREATE TABLE silver.Date (
	date_key INT not null,
	full_date DATETIME,
	day_of_week INT,
	day_num_in_month INT,
	day_num_overall INT,
	day_name varchar(9),
	day_abbrev char(3),
	weekday_flag char(10),
	week_num_in_year INT,
	week_num_overall INT,
	week_begin_date DATETIME,
	week_begin_date_key INT,
	month INT,
	month_num_overall INT,
	month_name varchar(9),
	month_abbrev char(3),
	quarter INT,
	year INT,
	yearmo INT,
	fiscal_month INT,
	fiscal_quarter INT,
	fiscal_year INT,
	last_day_in_month_flag char(20),
	same_day_year_ago_date DATETIME,
	primary key (date_key),
	dwh_create_date    DATETIME2 DEFAULT GETDATE()
);
GO

