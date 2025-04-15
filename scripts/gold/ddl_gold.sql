
IF OBJECT_ID('gold.DimCustomer', 'U') IS NOT NULL
    DROP TABLE gold.DimCustomer;
GO

-- Dimension Tables
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
    RowIsCurrent BIT NOT NULL DEFAULT 1,
    RowStartDate DATETIME NOT NULL DEFAULT GETDATE(),
    RowEndDate DATETIME NOT NULL DEFAULT '9999-12-31',
    RowChangeReason NVARCHAR(200) NOT NULL DEFAULT 'Initial Load',
    CONSTRAINT PK_gold_DimCustomer PRIMARY KEY CLUSTERED (CustomerKey)
);
GO

IF OBJECT_ID('gold.DimEmployee', 'U') IS NOT NULL
    DROP TABLE gold.DimEmployee;
GO

CREATE TABLE gold.DimEmployee (
    EmployeeKey INT IDENTITY(1,1) NOT NULL,
    EmployeeID INT NOT NULL,
    EmployeeName NVARCHAR(100) NOT NULL,
    EmployeeTitle NVARCHAR(30) NOT NULL,
    RowIsCurrent BIT NOT NULL DEFAULT 1,
    RowStartDate DATETIME NOT NULL DEFAULT GETDATE(),
    RowEndDate DATETIME NOT NULL DEFAULT '9999-12-31',
    RowChangeReason NVARCHAR(200) NOT NULL DEFAULT 'Initial Load',
    CONSTRAINT PK_gold_DimEmployee PRIMARY KEY CLUSTERED (EmployeeKey)
);
GO

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
    RowIsCurrent BIT NOT NULL DEFAULT 1,
    RowStartDate DATETIME NOT NULL DEFAULT GETDATE(),
    RowEndDate DATETIME NOT NULL DEFAULT '9999-12-31',
    RowChangeReason NVARCHAR(200) NOT NULL DEFAULT 'Initial Load',
    CONSTRAINT PK_gold_DimProducts PRIMARY KEY CLUSTERED (ProductKey)
);
GO

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

IF OBJECT_ID('gold.DimShipper', 'U') IS NOT NULL
    DROP TABLE gold.DimShipper;
GO

CREATE TABLE gold.DimShipper (
    ShipperKey INT IDENTITY(1,1) NOT NULL,
    ShipperID INT NOT NULL,
    CompanyName NVARCHAR(100) NOT NULL,
    Phone NVARCHAR(30) NULL,
    RowIsCurrent BIT NOT NULL DEFAULT 1,
    RowStartDate DATETIME NOT NULL DEFAULT GETDATE(),
    RowEndDate DATETIME NOT NULL DEFAULT '9999-12-31',
    RowChangeReason NVARCHAR(200) NOT NULL DEFAULT 'Initial Load',
    CONSTRAINT PK_gold_DimShipper PRIMARY KEY CLUSTERED (ShipperKey)
);

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
    RowIsCurrent BIT NOT NULL DEFAULT 1,
    RowStartDate DATETIME NOT NULL DEFAULT GETDATE(),
    RowEndDate DATETIME NOT NULL DEFAULT '9999-12-31',
    RowChangeReason NVARCHAR(200) NOT NULL DEFAULT 'Initial Load',
    CONSTRAINT PK_gold_DimSupplier PRIMARY KEY CLUSTERED (SupplierKey)
);

IF OBJECT_ID('gold.DimCategory', 'U') IS NOT NULL
    DROP TABLE gold.DimCategory;
GO

CREATE TABLE gold.DimCategory (
    CategoryKey INT IDENTITY(1,1) NOT NULL,
    CategoryID INT NOT NULL,
    CategoryName NVARCHAR(50) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    RowIsCurrent BIT NOT NULL DEFAULT 1,
    RowStartDate DATETIME NOT NULL DEFAULT GETDATE(),
    RowEndDate DATETIME NOT NULL DEFAULT '9999-12-31',
    RowChangeReason NVARCHAR(200) NOT NULL DEFAULT 'Initial Load',
    CONSTRAINT PK_gold_DimCategory PRIMARY KEY CLUSTERED (CategoryKey)
);


IF OBJECT_ID('gold.FactSales', 'U') IS NOT NULL
    DROP TABLE gold.FactSales;
GO

-- Fact Table for Sales Reporting
CREATE TABLE gold.FactSales (
    OrderID INT NOT NULL,
    ProductKey INT NOT NULL,
    CustomerKey INT NOT NULL,
    EmployeeKey INT NOT NULL,
    OrderDateKey INT NOT NULL,
    ShippedDateKey INT NULL,
    Quantity INT NOT NULL,
    DiscountAmount DECIMAL(18, 2) NOT NULL,
    SoldAmount DECIMAL(18, 2) NOT NULL,
    ExtendedPriceAmount DECIMAL(18, 2) NOT NULL,
    
    -- Foreign Key Constraints
    CONSTRAINT FK_FactSales_ProductKey FOREIGN KEY (ProductKey) REFERENCES gold.DimProducts (ProductKey),
    CONSTRAINT FK_FactSales_CustomerKey FOREIGN KEY (CustomerKey) REFERENCES gold.DimCustomer (CustomerKey),
    CONSTRAINT FK_FactSales_EmployeeKey FOREIGN KEY (EmployeeKey) REFERENCES gold.DimEmployee (EmployeeKey),
    CONSTRAINT FK_FactSales_OrderDateKey FOREIGN KEY (OrderDateKey) REFERENCES gold.DimDate (DateKey),
    CONSTRAINT FK_FactSales_ShippedDateKey FOREIGN KEY (ShippedDateKey) REFERENCES gold.DimDate (DateKey)
);
GO

IF OBJECT_ID('gold.FactOrderFulfillment', 'U') IS NOT NULL
    DROP TABLE gold.FactOrderFulfillment;
GO

-- Fact Table for Order Fulfillment Analysis
-- Update the FactOrderFulfillment table
CREATE TABLE gold.FactOrderFulfillment (
    OrderFulfillmentKey INT IDENTITY(1,1) NOT NULL,
    OrderID INT NOT NULL,
    CustomerKey INT NOT NULL,
    EmployeeKey INT NOT NULL,
    ShipperKey INT NOT NULL,  
    OrderDateKey INT NOT NULL,
    RequiredDateKey INT NOT NULL,
    ShippedDateKey INT NULL,
    Freight DECIMAL(10,2) NULL,  
    OrderToShipDays INT NULL,
    IsOrderDelayed BIT NULL,
    DaysDelayed INT NULL,       
    ShipRegion NVARCHAR(50) NULL, 
    ShipCity NVARCHAR(50) NULL,  
    ShipCountry NVARCHAR(50) NULL, 
    TotalOrderItems INT NULL,    
    TotalOrderAmount DECIMAL(18,2) NULL, 
    CONSTRAINT PK_FactOrderFulfillment PRIMARY KEY CLUSTERED (OrderFulfillmentKey),
    CONSTRAINT FK_FactOrderFulfillment_CustomerKey FOREIGN KEY (CustomerKey) REFERENCES gold.DimCustomer (CustomerKey),
    CONSTRAINT FK_FactOrderFulfillment_EmployeeKey FOREIGN KEY (EmployeeKey) REFERENCES gold.DimEmployee (EmployeeKey),
    CONSTRAINT FK_FactOrderFulfillment_ShipperKey FOREIGN KEY (ShipperKey) REFERENCES gold.DimShipper (ShipperKey),
    CONSTRAINT FK_FactOrderFulfillment_OrderDateKey FOREIGN KEY (OrderDateKey) REFERENCES gold.DimDate (DateKey),
    CONSTRAINT FK_FactOrderFulfillment_RequiredDateKey FOREIGN KEY (RequiredDateKey) REFERENCES gold.DimDate (DateKey),
    CONSTRAINT FK_FactOrderFulfillment_ShippedDateKey FOREIGN KEY (ShippedDateKey) REFERENCES gold.DimDate (DateKey)
);
GO

IF OBJECT_ID('gold.FactInventory', 'U') IS NOT NULL
    DROP TABLE gold.FactInventory;
GO

-- Fact Table for Inventory Analysis
CREATE TABLE gold.FactInventory (
    InventoryKey INT IDENTITY(1,1) NOT NULL,
    ProductKey INT NOT NULL,
    SupplierKey INT NOT NULL,      
    CategoryKey INT NOT NULL,      
    UnitsInStock INT NOT NULL,
    UnitsOnOrder INT NOT NULL,
    ReorderLevel INT NULL,
    LeadTimeDays INT NULL,         
    Discontinued NVARCHAR(5) NOT NULL,
    InventoryValue DECIMAL(18, 2) NOT NULL,
    DaysSinceLastOrder INT NULL,
    DaysSinceLastShipment INT NULL, 
    StockCoverDays INT NULL,        
    QuantityPerUnit NVARCHAR(50) NULL, 
    SafetyStockLevel INT NULL,
    InventoryDate DATETIME DEFAULT GETDATE(),  -- Optional: add this if you still want to track when inventory was recorded
    CONSTRAINT PK_FactInventory PRIMARY KEY CLUSTERED (InventoryKey),
    CONSTRAINT FK_FactInventory_ProductKey FOREIGN KEY (ProductKey) REFERENCES gold.DimProducts (ProductKey),
    CONSTRAINT FK_FactInventory_SupplierKey FOREIGN KEY (SupplierKey) REFERENCES gold.DimSupplier (SupplierKey),
    CONSTRAINT FK_FactInventory_CategoryKey FOREIGN KEY (CategoryKey) REFERENCES gold.DimCategory (CategoryKey)
);
GO

