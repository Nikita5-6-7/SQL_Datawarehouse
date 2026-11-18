

USE master;
--create warehose database

CREATE DATABASE DataWarehouse;
GO
USE DataWarehouse;
GO
CREATE SCHEMA Bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;

CREATE TABLE Bronze.crm_cust_info(
	cst_id INT,
	cst_key NVARCHAR(50),
	cst_firstname NVARCHAR(50),
	cst_lastname NVARCHAR(50),
	cst_martial_status NVARCHAR(50),
	cst_gndr NVARCHAR(50),
	cst_create_date DATE
);

CREATE TABLE Bronze.crm_prd_info (
    prd_id INT,
    prd_key NVARCHAR(50),
    prd_nm NVARCHAR(50),
    prd_cost INT,
    prd_line NVARCHAR(50),
    prd_start_dt DATETIME,
    prd_end_dt DATETIME
);

CREATE TABLE Bronze.crm_sales_details (
    sls_ord_num NVARCHAR(50),
    sls_prd_key NVARCHAR(50),
    sls_cust_id INT,
    sls_order_dt INT,
    sls_ship_dt INT,
    sls_due_dt INT,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT
);

CREATE TABLE Bronze.erp_loc_a101 (
    cid NVARCHAR(50),
    cntry NVARCHAR(50)
);

CREATE TABLE Bronze.erp_cust_az12 (
    cid NVARCHAR(50),
    bdate DATE,
    gen NVARCHAR(50)
);

CREATE TABLE Bronze.erp_px_cat_g1v2 (
    id NVARCHAR(50),
    cat NVARCHAR(50),
    subcat NVARCHAR(50),
    maintenance NVARCHAR(50)
);

--Loading into the bronze layer

--F:\CIMT Study Material\Database Fundamental\Data Warehouse\DataWarehouse_Database

CREATE OR ALTER PROCEDURE Bronze.load_bronze
AS
BEGIN
    PRINT '>> Loading CRM cust_info table'
    TRUNCATE TABLE Bronze.crm_cust_info;
    BULK INSERT Bronze.crm_cust_info
    FROM 'F:\CIMT Study Material\Database Fundamental\Data Warehouse\DataWarehouse_Database\cust_info.csv'
    WITH (FORMAT = 'CSV', FIRSTROW = 2);
    
    PRINT '>> Loading CRM prd_info table'
    TRUNCATE TABLE Bronze.crm_prd_info;
    BULK INSERT Bronze.crm_prd_info
    FROM 'F:\CIMT Study Material\Database Fundamental\Data Warehouse\DataWarehouse_Database\prd_info.csv'
    WITH (FORMAT = 'CSV', FIRSTROW = 2);

    PRINT '>> Loading CRM sales_details table'
    TRUNCATE TABLE Bronze.crm_sales_details;
    BULK INSERT Bronze.crm_sales_details
    FROM 'F:\CIMT Study Material\Database Fundamental\Data Warehouse\DataWarehouse_Database\sales_details.csv'
    WITH (FORMAT = 'CSV', FIRSTROW = 2);

    PRINT '>> Loading CRM erp_location table';
    TRUNCATE TABLE Bronze.erp_loc_a101;
    BULK INSERT Bronze.erp_loc_a101
    FROM 'F:\CIMT Study Material\Database Fundamental\Data Warehouse\DataWarehouse_Database\loc_a101.csv'
    WITH (FORMAT = 'CSV', FIRSTROW = 2);

    PRINT '>> Loading CRM erp_customer table';
    TRUNCATE TABLE Bronze.erp_cust_az12;
    BULK INSERT Bronze.erp_cust_az12
    FROM 'F:\CIMT Study Material\Database Fundamental\Data Warehouse\DataWarehouse_Database\cust_az12.csv'
    WITH (FORMAT = 'CSV', FIRSTROW = 2);

    PRINT '>> Loading CRM erp_product_category table';
    TRUNCATE TABLE Bronze.erp_px_cat_g1v2;
    BULK INSERT Bronze.erp_px_cat_g1v2
    FROM 'F:\CIMT Study Material\Database Fundamental\Data Warehouse\DataWarehouse_Database\px_cat_g1v2.csv'
    WITH (FORMAT = 'CSV', FIRSTROW = 2);
END

EXEC Bronze.load_bronze;

SELECT TOP 10 *
FROM Bronze.crm_cust_info;

SELECT TOP 10 *
FROM Bronze.erp_px_cat_g1v2;