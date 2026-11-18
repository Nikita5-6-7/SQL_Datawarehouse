# Data warehouse
End-to-end SQL Server data warehouse using Medallion architecture (Bronze → Silver → Gold): CRM and ERP CSV ingestion, data cleaning, star schema, and exploratory analysis.
Topic(tag)
  sql-server 
  t-sql 
  data-warehouse 
  medallion-architecture 
  etl 
  data-cleaning 
  star-schema 
  data-analytics 
  business-intelligence 
  exploratory-data-analysis

# SQL Server Data Warehouse – Medallion Architecture

A data warehouse built in SQL Server that consolidates CRM and ERP sales data
into an analytics-ready star schema using the Bronze → Silver → Gold approach.

## Architecture
| Layer | Purpose |
|-------|---------|
| **Bronze** | Raw CSV data loaded as-is using `BULK INSERT` |
| **Silver** | Cleaned and standardized data (trimming, deduplication, code-to-label mapping, date and sales fixes) |
| **Gold** | Business-ready views: `dim_customers`, `dim_products`, `fact_sales` |

## Source Data (6 CSV files)
**CRM:** `cust_info.csv`, `prd_info.csv`, `sales_details.csv`
**ERP:** `CUST_AZ12.csv`, `LOC_A101.csv`, `PX_CAT_G1V2.csv`

## Repository Contents
| File | Description |
|------|-------------|
| `Bronze.sql` | Creates the `DataWarehouse` database, the bronze/silver/gold schemas, bronze tables, and the `Bronze.load_bronze` stored procedure |
| `inspectData.sql` | Pre-load data profiling: duplicates, NULLs, invalid dates, inconsistent categories, and sales/price mismatches |
| `SilverTable.sql` | Creates the silver tables with a `dwh_create_date` audit column |
| `Silver_Load_Data.sql` | `silver.load_data` stored procedure with all transformations |
| `GoldLayer.sql` | Creates the Gold views (star schema) with surrogate keys |
| `ExploreData.sql` | EDA queries: date ranges, key measures, revenue by category and customer, top/bottom products, top customers |

## Key Transformations (Silver)
- Removed duplicate customers (latest record via `ROW_NUMBER()`)
- Trimmed text and standardized codes (M/F, S/M, DE/US/USA → full names)
- Derived `cat_id` and product key from the combined product key
- Calculated product end dates using `LEAD()`
- Converted integer dates (YYYYMMDD) to `DATE`, with invalid values set to NULL
- Recalculated incorrect or missing sales and price values
- Cleaned ERP customer IDs and nullified future birthdates

## Analysis Covered
Total sales, quantity, average price, orders, products, customers; customers by
country and gender; revenue by category and customer; top 5 / bottom 5 products;
top 10 customers; customers with the fewest orders.

## How to Run
1. Update the CSV folder path in `Bronze.sql`
2. Run `Bronze.sql`, then `EXEC Bronze.load_bronze`
3. Run `SilverTable.sql` (tables), then `EXEC silver.load_data`
4. Run `GoldLayer.sql`
5. Run `ExploreData.sql`

## Tools
SQL Server, T-SQL, SSMS

## Author
Nikita Patel – Data Analytics & BI student, Toronto
