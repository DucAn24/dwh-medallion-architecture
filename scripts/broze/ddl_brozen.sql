-- Categories table
IF OBJECT_ID('bronze.Categories', 'U') IS NOT NULL
    DROP TABLE bronze.Categories;
GO

CREATE TABLE bronze.Categories (
    CategoryID INT,
    CategoryName NVARCHAR(50),
    Description NVARCHAR(MAX),
    Picture NVARCHAR(MAX)
);
GO

-- Customers table
IF OBJECT_ID('bronze.Customers', 'U') IS NOT NULL
    DROP TABLE bronze.Customers;
GO

CREATE TABLE bronze.Customers (
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
    Fax NVARCHAR(30)
);
GO

-- Employees table
IF OBJECT_ID('bronze.Employees', 'U') IS NOT NULL
    DROP TABLE bronze.Employees;
GO

CREATE TABLE bronze.Employees (
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
    Photo NVARCHAR(MAX)
);
GO

-- EmployeeTerritories table
IF OBJECT_ID('bronze.EmployeeTerritories', 'U') IS NOT NULL
    DROP TABLE bronze.EmployeeTerritories;
GO

CREATE TABLE bronze.EmployeeTerritories (
    EmployeeID INT,
    TerritoryID NVARCHAR(20)
);
GO

-- OrderDetails table
IF OBJECT_ID('bronze.OrderDetails', 'U') IS NOT NULL
    DROP TABLE bronze.OrderDetails;
GO

CREATE TABLE bronze.OrderDetails (
    OrderID INT,
    ProductID INT,
    UnitPrice DECIMAL(10, 2),
    Quantity INT,
    Discount NVARCHAR(MAX)
);
GO

-- Orders table
IF OBJECT_ID('bronze.Orders', 'U') IS NOT NULL
    DROP TABLE bronze.Orders;
GO

CREATE TABLE bronze.Orders (
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
    ShipCountry NVARCHAR(50)
);
GO

-- Products table
IF OBJECT_ID('bronze.Products', 'U') IS NOT NULL
    DROP TABLE bronze.Products;
GO

CREATE TABLE bronze.Products (
    ProductID INT,
    ProductName NVARCHAR(100),
    SupplierID INT,
    CategoryID INT,
    QuantityPerUnit NVARCHAR(50),
    UnitPrice DECIMAL(10, 2),
    UnitsInStock INT,
    UnitsOnOrder INT,
    ReorderLevel INT,
    Discontinued BIT
);
GO

-- Region table
IF OBJECT_ID('bronze.Region', 'U') IS NOT NULL
    DROP TABLE bronze.Region;
GO

CREATE TABLE bronze.Region (
    RegionID INT,
    RegionDescription NVARCHAR(50)
);
GO

-- Shippers table
IF OBJECT_ID('bronze.Shippers', 'U') IS NOT NULL
    DROP TABLE bronze.Shippers;
GO

CREATE TABLE bronze.Shippers (
    ShipperID INT,
    CompanyName NVARCHAR(100),
    Phone NVARCHAR(30)
);
GO

-- Suppliers table
IF OBJECT_ID('bronze.Suppliers', 'U') IS NOT NULL
    DROP TABLE bronze.Suppliers;
GO

CREATE TABLE bronze.Suppliers (
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
    HomePage NVARCHAR(MAX)
);
GO

-- Territories table
IF OBJECT_ID('bronze.Territories', 'U') IS NOT NULL
    DROP TABLE bronze.Territories;
GO

CREATE TABLE bronze.Territories (
    TerritoryID NVARCHAR(20),
    TerritoryDescription NVARCHAR(50),
    RegionID INT
);
GO