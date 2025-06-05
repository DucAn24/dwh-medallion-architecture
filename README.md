# Data Warehouse and Analytics Project

A comprehensive data warehouse for the Northwind database using medallion architecture (Bronze, Silver, Gold layers) with Star and Galaxy schema implementations for advanced analytics.

---
## 🏗️ Data Architecture

### Medallion Architecture: Bronze → Silver → Gold
![Medallion-Architecture-High-Level-Data-flow](https://github.com/user-attachments/assets/aebb5cd5-8ca8-4906-8b07-f3cd25ba9aee)

#### Bronze Layer (Raw Data)
- **Purpose**: Raw CSV ingestion via BULK INSERT
- **Tables**: 12 Northwind source tables
- **Processing**: Minimal transformation, handles UTF-8 encoding
- **Script**: `scripts/bronze/proc_load_bronze.sql`

#### Silver Layer (Transformation + SCD2)
- **Purpose**: Data cleansing, SCD Type 2, business logic
- **Features**: 
  - SCD2 dimensions with `RowIsCurrent`, `RowStartDate`, `RowEndDate`
  - Business calculations (SalesAmount, DaysToShip, StockValue)
  - Data quality improvements (address formatting, postal codes)
- **Tables**: 7 SCD2 dimensions + 3 fact preparation tables + DimDate
- **Script**: `scripts/silver/proc_load_silver.sql`

#### Gold Layer (Star Schema)
- **Purpose**: Consumption-ready dimensional model
- **Processing**: Direct SELECT from Silver (no transformations)
- **Structure**: Star schema with enforced foreign keys
- **Script**: `scripts/gold/proc_load_gold.sql`

---
## 📊 Data Modeling Approaches

### Star Schema 

![Screenshot 2025-06-05 233449](https://github.com/user-attachments/assets/a76d0d66-2b6d-4140-9015-1f3a46d7c26b)

---
## 📈 Business Data Model

### Fact Tables
| Fact Table | Grain | Key Measures | Business Purpose |
|------------|-------|--------------|------------------|
| **FactSales** | Order line item | SalesAmount, Quantity, Discount | Revenue analysis |
| **FactOrderFulfillment** | Order | DaysToShip, OnTimeDelivery, Freight | Fulfillment efficiency |
| **FactInventory** | Product snapshot | StockValue, UnitsInStock, StockStatus | Inventory management |

### Dimension Tables (SCD2)
- **DimCustomer**: Customer master with address tracking
- **DimEmployee**: Employee details with role changes
- **DimProducts**: Product catalog with supplier/category
- **DimSupplier**: Supplier information
- **DimShipper**: Shipping companies
- **DimCategory**: Product categorization
- **DimDate**: Comprehensive date dimension

---
## 🚀 Quick Start

### ETL Pipeline Execution
```sql
-- 1. Load raw data
EXEC bronze.load_bronze;

-- 2. Transform and apply SCD2
EXEC silver.load_silver;

-- 3. Assemble final model
EXEC gold.load_gold;
```

### Data Flow
**CSV** → **Bronze** → **Silver** → **Gold** → **Power BI**

---
## 📂 Repository Structure
```
sql-dwh-project/
├── datasets/              # Raw Northwind CSV files
├── scripts/
│   ├── bronze/           # Raw data ingestion
│   ├── silver/           # SCD2 + business logic
│   ├── gold/             # Star schema assembly
│   └── init_date/        # Date dimension setup
├── dash.pbix            # Power BI dashboard
└── README.md
```

---
## 📊 Analytics Capabilities

### Power BI Dashboard
![Screenshot 2025-04-16 012651](https://github.com/user-attachments/assets/f90bea14-f447-4748-988a-80a770a1e224)

### Key Analytics Areas
1. **Sales Performance**: Revenue, trends, product/customer analysis
2. **Order Fulfillment**: Delivery metrics, shipping cost optimization
3. **Inventory Management**: Stock levels, valuation, reorder alerts

