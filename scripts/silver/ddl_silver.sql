-- Silver Layer DDL 

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
    ShipCountry NVARCHAR(50)
);
GO

-- OrderDetails 
IF OBJECT_ID('silver.OrderDetails', 'U') IS NOT NULL
    DROP TABLE silver.OrderDetails;
GO

CREATE TABLE silver.OrderDetails (
    OrderID INT,
    ProductID INT,
    UnitPrice DECIMAL(10, 2),
    Quantity INT,
    Discount DECIMAL(5, 2)
);
GO

-- Products 
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
    Discontinued NVARCHAR(1)
);
GO

-- SCD2 DimCustomer 
IF OBJECT_ID('silver.DimCustomer', 'U') IS NOT NULL
    DROP TABLE silver.DimCustomer;
GO

CREATE TABLE silver.DimCustomer (
    CustomerKey INT IDENTITY(1,1) NOT NULL,
    CustomerID NVARCHAR(50) NOT NULL,
    CompanyName NVARCHAR(50) NOT NULL,
    ContactName NVARCHAR(50) NOT NULL,
    ContactTitle NVARCHAR(50) NULL,
    CustomerCountry NVARCHAR(50) NULL,
    CustomerRegion NVARCHAR(50) NULL,
    CustomerCity NVARCHAR(50) NULL,
    CustomerPostalCode NVARCHAR(50) NULL,
    RowIsCurrent BIT NOT NULL DEFAULT 1,
    RowStartDate DATETIME NOT NULL DEFAULT GETDATE(),
    RowEndDate DATETIME NOT NULL DEFAULT '9999-12-31',
    RowChangeReason NVARCHAR(200) NOT NULL DEFAULT 'Initial Load',
    CONSTRAINT PK_silver_DimCustomer PRIMARY KEY CLUSTERED (CustomerKey)
);
GO

-- SCD2 DimEmployee 
IF OBJECT_ID('silver.DimEmployee', 'U') IS NOT NULL
    DROP TABLE silver.DimEmployee;
GO

CREATE TABLE silver.DimEmployee (
    EmployeeKey INT IDENTITY(1,1) NOT NULL,
    EmployeeID INT NOT NULL,
    EmployeeName NVARCHAR(100) NOT NULL,
    EmployeeTitle NVARCHAR(30) NOT NULL,
    RowIsCurrent BIT NOT NULL DEFAULT 1,
    RowStartDate DATETIME NOT NULL DEFAULT GETDATE(),
    RowEndDate DATETIME NOT NULL DEFAULT '9999-12-31',
    RowChangeReason NVARCHAR(200) NOT NULL DEFAULT 'Initial Load',
    CONSTRAINT PK_silver_DimEmployee PRIMARY KEY CLUSTERED (EmployeeKey)
);
GO

-- SCD2 DimProducts 
IF OBJECT_ID('silver.DimProducts', 'U') IS NOT NULL
    DROP TABLE silver.DimProducts;
GO

CREATE TABLE silver.DimProducts (
    ProductKey INT IDENTITY(1,1) NOT NULL,
    ProductID INT NOT NULL,
    ProductName NVARCHAR(200) NOT NULL,
    Discontinued NVARCHAR(5) NOT NULL,
    CategoryName NVARCHAR(200) NOT NULL,
    SupplierName NVARCHAR(40) NOT NULL,
    RowIsCurrent BIT NOT NULL DEFAULT 1,
    RowStartDate DATETIME NOT NULL DEFAULT GETDATE(),
    RowEndDate DATETIME NOT NULL DEFAULT '9999-12-31',
    RowChangeReason NVARCHAR(200) NOT NULL DEFAULT 'Initial Load',
    CONSTRAINT PK_silver_DimProducts PRIMARY KEY CLUSTERED (ProductKey)
);
GO

-- SCD2 DimRegion 
IF OBJECT_ID('silver.DimRegion', 'U') IS NOT NULL
    DROP TABLE silver.DimRegion;
GO

CREATE TABLE silver.DimRegion (
    RegionKey INT IDENTITY(1,1) NOT NULL,
    RegionID INT NOT NULL,
    RegionDescription NVARCHAR(50) NOT NULL,
    RowIsCurrent BIT NOT NULL DEFAULT 1,
    RowStartDate DATETIME NOT NULL DEFAULT GETDATE(),
    RowEndDate DATETIME NOT NULL DEFAULT '9999-12-31',
    RowChangeReason NVARCHAR(200) NOT NULL DEFAULT 'Initial Load',
    CONSTRAINT PK_silver_DimRegion PRIMARY KEY CLUSTERED (RegionKey)
);
GO

-- SCD2 DimShipper 
IF OBJECT_ID('silver.DimShipper', 'U') IS NOT NULL
    DROP TABLE silver.DimShipper;
GO

CREATE TABLE silver.DimShipper (
    ShipperKey INT IDENTITY(1,1) NOT NULL,
    ShipperID INT NOT NULL,
    CompanyName NVARCHAR(100) NOT NULL,
    Phone NVARCHAR(30) NULL,
    RowIsCurrent BIT NOT NULL DEFAULT 1,
    RowStartDate DATETIME NOT NULL DEFAULT GETDATE(),
    RowEndDate DATETIME NOT NULL DEFAULT '9999-12-31',
    RowChangeReason NVARCHAR(200) NOT NULL DEFAULT 'Initial Load',
    CONSTRAINT PK_silver_DimShipper PRIMARY KEY CLUSTERED (ShipperKey)
);
GO

-- SCD2 DimSupplier 
IF OBJECT_ID('silver.DimSupplier', 'U') IS NOT NULL
    DROP TABLE silver.DimSupplier;
GO

CREATE TABLE silver.DimSupplier (
    SupplierKey INT IDENTITY(1,1) NOT NULL,
    SupplierID INT NOT NULL,
    CompanyName NVARCHAR(100) NOT NULL,
    ContactName NVARCHAR(100) NULL,
    ContactTitle NVARCHAR(100) NULL,
    Address NVARCHAR(100) NULL,
    City NVARCHAR(50) NULL,
    Region NVARCHAR(50) NULL,
    PostalCode NVARCHAR(20) NULL,
    Country NVARCHAR(50) NULL,
    Phone NVARCHAR(30) NULL,
    RowIsCurrent BIT NOT NULL DEFAULT 1,
    RowStartDate DATETIME NOT NULL DEFAULT GETDATE(),
    RowEndDate DATETIME NOT NULL DEFAULT '9999-12-31',
    RowChangeReason NVARCHAR(200) NOT NULL DEFAULT 'Initial Load',
    CONSTRAINT PK_silver_DimSupplier PRIMARY KEY CLUSTERED (SupplierKey)
);
GO

-- SCD2 DimCategory 
IF OBJECT_ID('silver.DimCategory', 'U') IS NOT NULL
    DROP TABLE silver.DimCategory;
GO

CREATE TABLE silver.DimCategory (
    CategoryKey INT IDENTITY(1,1) NOT NULL,
    CategoryID INT NOT NULL,
    CategoryName NVARCHAR(50) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    RowIsCurrent BIT NOT NULL DEFAULT 1,
    RowStartDate DATETIME NOT NULL DEFAULT GETDATE(),
    RowEndDate DATETIME NOT NULL DEFAULT '9999-12-31',
    RowChangeReason NVARCHAR(200) NOT NULL DEFAULT 'Initial Load',
    CONSTRAINT PK_silver_DimCategory PRIMARY KEY CLUSTERED (CategoryKey)
);
GO

-- SCD2 DimTerritories 
IF OBJECT_ID('silver.DimTerritories', 'U') IS NOT NULL
    DROP TABLE silver.DimTerritories;
GO

CREATE TABLE silver.DimTerritories (
    TerritoryKey INT IDENTITY(1,1) NOT NULL,
    TerritoryID NVARCHAR(20) NOT NULL,
    TerritoryDescription NVARCHAR(50) NOT NULL,
    RegionID INT NOT NULL,
    RegionDescription NVARCHAR(50) NOT NULL,
    RowIsCurrent BIT NOT NULL DEFAULT 1,
    RowStartDate DATETIME NOT NULL DEFAULT GETDATE(),
    RowEndDate DATETIME NOT NULL DEFAULT '9999-12-31',
    RowChangeReason NVARCHAR(200) NOT NULL DEFAULT 'Initial Load',
    CONSTRAINT PK_silver_DimTerritories PRIMARY KEY CLUSTERED (TerritoryKey)
);
GO

-- DimDate 
IF OBJECT_ID('silver.DimDate', 'U') IS NOT NULL
    DROP TABLE silver.DimDate;
GO

CREATE TABLE silver.DimDate (
    DateKey INT NOT NULL,
    Date DATETIME NOT NULL,
    DayOfWeek INT NOT NULL,
    DayName NVARCHAR(50) NOT NULL,
    DayOfMonth INT NOT NULL,
    DayOfYear INT NOT NULL,
    WeekOfYear INT NOT NULL,
    MonthName NVARCHAR(50) NOT NULL,
    MonthOfYear INT NOT NULL,
    Quarter INT NOT NULL,
    QuarterName NVARCHAR(50) NOT NULL,
    Year INT NOT NULL,
    IsWeekday NVARCHAR(50) NOT NULL,
    CONSTRAINT PK_silver_DimDate PRIMARY KEY CLUSTERED (DateKey)
);
GO


-- FactSales 
IF OBJECT_ID('silver.FactSales', 'U') IS NOT NULL
    DROP TABLE silver.FactSales;
GO

CREATE TABLE silver.FactSales (
    DateKey INT NOT NULL,
    CustomerKey INT NOT NULL,
    EmployeeKey INT NOT NULL,
    ProductKey INT NOT NULL,
    OrderID INT NOT NULL,
    UnitPrice DECIMAL(10, 2) NOT NULL,
    Quantity INT NOT NULL,
    Discount DECIMAL(5, 2) NOT NULL,
    SalesAmount DECIMAL(12, 2) NOT NULL --  UnitPrice * Quantity * (1 - Discount)
);
GO

-- FactOrderFulfillment 
IF OBJECT_ID('silver.FactOrderFulfillment', 'U') IS NOT NULL
    DROP TABLE silver.FactOrderFulfillment;
GO

CREATE TABLE silver.FactOrderFulfillment (
    OrderDateKey INT NOT NULL,
    RequiredDateKey INT NOT NULL,
    ShippedDateKey INT NULL,
    CustomerKey INT NOT NULL,
    EmployeeKey INT NOT NULL,
    ShipperKey INT NOT NULL,
    OrderID INT NOT NULL,
    Freight DECIMAL(10, 2) NOT NULL,
    DaysToShip INT NULL, --  DATEDIFF(DAY, OrderDate, ShippedDate)
    DaysLate INT NOT NULL, --  DATEDIFF(DAY, RequiredDate, ShippedDate) when late
    OnTimeDelivery BIT NOT NULL --  1 if shipped <= required date, 0 otherwise
);
GO

-- FactInventory 
IF OBJECT_ID('silver.FactInventory', 'U') IS NOT NULL
    DROP TABLE silver.FactInventory;
GO

CREATE TABLE silver.FactInventory (
    ProductKey INT NOT NULL,
    SupplierKey INT NOT NULL,
    CategoryKey INT NOT NULL,
    UnitsInStock INT NOT NULL,
    UnitsOnOrder INT NOT NULL,
    ReorderLevel INT NOT NULL,
    UnitPrice DECIMAL(10, 2) NOT NULL,
    StockValue DECIMAL(12, 2) NOT NULL, --  UnitsInStock * UnitPrice
    StockStatus NVARCHAR(20) NOT NULL -- Low Stock/Normal/Overstock logic
);
GO

