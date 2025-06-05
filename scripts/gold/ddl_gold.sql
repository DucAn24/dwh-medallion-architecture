

-- DimCustomer 
IF OBJECT_ID('gold.DimCustomer', 'U') IS NOT NULL
    DROP TABLE gold.DimCustomer;
GO

CREATE TABLE gold.DimCustomer (
    CustomerKey INT IDENTITY(1,1) NOT NULL,
    CustomerID NVARCHAR(50) NOT NULL,
    CompanyName NVARCHAR(50) NOT NULL,
    ContactName NVARCHAR(50) NOT NULL,
    ContactTitle NVARCHAR(50) NULL,
    CustomerCountry NVARCHAR(50) NULL,
    CustomerRegion NVARCHAR(50) NULL,
    CustomerCity NVARCHAR(50) NULL,
    CustomerPostalCode NVARCHAR(50) NULL,
    RowIsCurrent BIT NOT NULL,
    RowStartDate DATETIME NOT NULL,
    RowEndDate DATETIME NOT NULL,
    RowChangeReason NVARCHAR(200) NOT NULL,
    CONSTRAINT PK_gold_DimCustomer PRIMARY KEY CLUSTERED (CustomerKey)
);
GO

-- DimEmployee 
IF OBJECT_ID('gold.DimEmployee', 'U') IS NOT NULL
    DROP TABLE gold.DimEmployee;
GO

CREATE TABLE gold.DimEmployee (
    EmployeeKey INT IDENTITY(1,1) NOT NULL,
    EmployeeID INT NOT NULL,
    EmployeeName NVARCHAR(100) NOT NULL,
    EmployeeTitle NVARCHAR(30) NOT NULL,
    RowIsCurrent BIT NOT NULL,
    RowStartDate DATETIME NOT NULL,
    RowEndDate DATETIME NOT NULL,
    RowChangeReason NVARCHAR(200) NOT NULL,
    CONSTRAINT PK_gold_DimEmployee PRIMARY KEY CLUSTERED (EmployeeKey)
);
GO

-- DimProducts 
IF OBJECT_ID('gold.DimProducts', 'U') IS NOT NULL
    DROP TABLE gold.DimProducts;
GO

CREATE TABLE gold.DimProducts (
    ProductKey INT IDENTITY(1,1) NOT NULL,
    ProductID INT NOT NULL,
    ProductName NVARCHAR(200) NOT NULL,
    Discontinued NVARCHAR(5) NOT NULL,
    CategoryName NVARCHAR(200) NOT NULL,
    SupplierName NVARCHAR(40) NOT NULL,
    RowIsCurrent BIT NOT NULL,
    RowStartDate DATETIME NOT NULL,
    RowEndDate DATETIME NOT NULL,
    RowChangeReason NVARCHAR(200) NOT NULL,
    CONSTRAINT PK_gold_DimProducts PRIMARY KEY CLUSTERED (ProductKey)
);
GO

-- DimShipper 
IF OBJECT_ID('gold.DimShipper', 'U') IS NOT NULL
    DROP TABLE gold.DimShipper;
GO

CREATE TABLE gold.DimShipper (
    ShipperKey INT IDENTITY(1,1) NOT NULL,
    ShipperID INT NOT NULL,
    CompanyName NVARCHAR(100) NOT NULL,
    Phone NVARCHAR(30) NULL,
    RowIsCurrent BIT NOT NULL,
    RowStartDate DATETIME NOT NULL,
    RowEndDate DATETIME NOT NULL,
    RowChangeReason NVARCHAR(200) NOT NULL,
    CONSTRAINT PK_gold_DimShipper PRIMARY KEY CLUSTERED (ShipperKey)
);
GO

-- DimSupplier 
IF OBJECT_ID('gold.DimSupplier', 'U') IS NOT NULL
    DROP TABLE gold.DimSupplier;
GO

CREATE TABLE gold.DimSupplier (
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
    RowIsCurrent BIT NOT NULL,
    RowStartDate DATETIME NOT NULL,
    RowEndDate DATETIME NOT NULL,
    RowChangeReason NVARCHAR(200) NOT NULL,
    CONSTRAINT PK_gold_DimSupplier PRIMARY KEY CLUSTERED (SupplierKey)
);
GO

-- DimCategory 
IF OBJECT_ID('gold.DimCategory', 'U') IS NOT NULL
    DROP TABLE gold.DimCategory;
GO

CREATE TABLE gold.DimCategory (
    CategoryKey INT IDENTITY(1,1) NOT NULL,
    CategoryID INT NOT NULL,
    CategoryName NVARCHAR(50) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    RowIsCurrent BIT NOT NULL,
    RowStartDate DATETIME NOT NULL,
    RowEndDate DATETIME NOT NULL,
    RowChangeReason NVARCHAR(200) NOT NULL,
    CONSTRAINT PK_gold_DimCategory PRIMARY KEY CLUSTERED (CategoryKey)
);
GO

-- DimDate 
IF OBJECT_ID('gold.DimDate', 'U') IS NOT NULL
    DROP TABLE gold.DimDate;
GO

CREATE TABLE gold.DimDate (
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
    CONSTRAINT PK_gold_DimDate PRIMARY KEY CLUSTERED (DateKey)
);
GO

-- FactSales 
IF OBJECT_ID('gold.FactSales', 'U') IS NOT NULL
    DROP TABLE gold.FactSales;
GO

CREATE TABLE gold.FactSales (
    SalesKey INT IDENTITY(1,1) NOT NULL,
    DateKey INT NOT NULL,
    CustomerKey INT NOT NULL,
    EmployeeKey INT NOT NULL,
    ProductKey INT NOT NULL,
    OrderID INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    Quantity INT NOT NULL,
    Discount DECIMAL(5,2) NOT NULL,
    SalesAmount DECIMAL(15,2) NOT NULL,
    CONSTRAINT PK_gold_FactSales PRIMARY KEY CLUSTERED (SalesKey),
    CONSTRAINT FK_FactSales_DimDate FOREIGN KEY (DateKey) REFERENCES gold.DimDate(DateKey),
    CONSTRAINT FK_FactSales_DimCustomer FOREIGN KEY (CustomerKey) REFERENCES gold.DimCustomer(CustomerKey),
    CONSTRAINT FK_FactSales_DimEmployee FOREIGN KEY (EmployeeKey) REFERENCES gold.DimEmployee(EmployeeKey),
    CONSTRAINT FK_FactSales_DimProducts FOREIGN KEY (ProductKey) REFERENCES gold.DimProducts(ProductKey)
);
GO

-- FactOrderFulfillment 
IF OBJECT_ID('gold.FactOrderFulfillment', 'U') IS NOT NULL
    DROP TABLE gold.FactOrderFulfillment;
GO

CREATE TABLE gold.FactOrderFulfillment (
    FulfillmentKey INT IDENTITY(1,1) NOT NULL,
    OrderDateKey INT NOT NULL,
    RequiredDateKey INT NOT NULL,
    ShippedDateKey INT NULL,
    CustomerKey INT NOT NULL,
    EmployeeKey INT NOT NULL,
    ShipperKey INT NOT NULL,
    OrderID INT NOT NULL,
    Freight DECIMAL(10,2) NOT NULL,
    DaysToShip INT NULL,
    DaysLate INT NULL,
    OnTimeDelivery BIT NOT NULL,
    CONSTRAINT PK_gold_FactOrderFulfillment PRIMARY KEY CLUSTERED (FulfillmentKey),
    CONSTRAINT FK_FactOrderFulfillment_OrderDate FOREIGN KEY (OrderDateKey) REFERENCES gold.DimDate(DateKey),
    CONSTRAINT FK_FactOrderFulfillment_RequiredDate FOREIGN KEY (RequiredDateKey) REFERENCES gold.DimDate(DateKey),
    CONSTRAINT FK_FactOrderFulfillment_ShippedDate FOREIGN KEY (ShippedDateKey) REFERENCES gold.DimDate(DateKey),
    CONSTRAINT FK_FactOrderFulfillment_Customer FOREIGN KEY (CustomerKey) REFERENCES gold.DimCustomer(CustomerKey),
    CONSTRAINT FK_FactOrderFulfillment_Employee FOREIGN KEY (EmployeeKey) REFERENCES gold.DimEmployee(EmployeeKey),
    CONSTRAINT FK_FactOrderFulfillment_Shipper FOREIGN KEY (ShipperKey) REFERENCES gold.DimShipper(ShipperKey)
);
GO

-- FactInventory 
IF OBJECT_ID('gold.FactInventory', 'U') IS NOT NULL
    DROP TABLE gold.FactInventory;
GO

CREATE TABLE gold.FactInventory (
    InventoryKey INT IDENTITY(1,1) NOT NULL,
    ProductKey INT NOT NULL,
    SupplierKey INT NOT NULL,
    CategoryKey INT NOT NULL,
    UnitsInStock INT NOT NULL,
    UnitsOnOrder INT NOT NULL,
    ReorderLevel INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    StockValue DECIMAL(15,2) NOT NULL,
    StockStatus NVARCHAR(20) NOT NULL,
    CONSTRAINT PK_gold_FactInventory PRIMARY KEY CLUSTERED (InventoryKey),
    CONSTRAINT FK_FactInventory_Products FOREIGN KEY (ProductKey) REFERENCES gold.DimProducts(ProductKey),
    CONSTRAINT FK_FactInventory_Supplier FOREIGN KEY (SupplierKey) REFERENCES gold.DimSupplier(SupplierKey),
    CONSTRAINT FK_FactInventory_Category FOREIGN KEY (CategoryKey) REFERENCES gold.DimCategory(CategoryKey)
);
GO

