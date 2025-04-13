create database Temp
GO

USE Temp
GO

create table [dbo].[Date_Dimension] (
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
	primary key (date_key)
);
GO


USE DataWarehouse
GO

SELECT 
    MIN(OrderDate) AS StartOrderDate,
    MAX(OrderDate) AS EndOrderDate,
    MIN(ShippedDate) AS StartShippedDate, 
    MAX(ShippedDate) AS EndShippedDate 
FROM bronze.Orders;
GO