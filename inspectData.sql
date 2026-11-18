/*
======================================================
				Silver Layer
======================================================

1. Pre inspection
2. Create six new tables
3. Apply the transformations ( Cleaning, Standardization and derived columns)
4. Load the transformations in newly created tables

*/

-- Pre-Inspection

SELECT *
FROM Bronze.crm_cust_info;

SELECT cst_key, COUNT(*)
FROM Bronze.crm_cust_info
GROUP BY cst_key
HAVING COUNT(*) > 1;

SELECT DISTINCT cst_martial_status
FROM Bronze.crm_cust_info;

SELECT cst_martial_status,
COUNT (*)
FROM Bronze.crm_cust_info
GROUP BY cst_martial_status;

SELECT cst_gndr,
COUNT (*)
FROM Bronze.crm_cust_info
GROUP BY cst_gndr;

-----Product info

SELECT *
FROM Bronze.crm_prd_info;

SELECT COUNT(*) AS NullVlue
FROM Bronze.crm_prd_info
WHERE prd_cost IS NULL;

SELECT DISTINCT prd_line
FROM Bronze.crm_prd_info;

----CRM Sales

SELECT *
from Bronze.crm_sales_details;

SELECT sls_due_dt
FROM Bronze.crm_sales_details
WHERE sls_due_dt = 0
OR LEN(sls_due_dt) !=0;

SELECT sls_order_dt
FROM Bronze.crm_sales_details
WHERE sls_order_dt = 0
OR LEN(sls_order_dt) !=0;

SELECT sls_sales, sls_quantity, sls_price
FROM Bronze.crm_sales_details
WHERE sls_price != (sls_sales * sls_quantity) OR sls_sales IS NULL;

----ERP Tables

SELECT *
FROM Bronze.erp_cust_az12;

SELECT *
FROM Bronze.erp_cust_az12
WHERE cid NOT LIKE 'NAS%';

SELECT DISTINCT gen
FROM Bronze.erp_cust_az12;

SELECT *
FROM Bronze.erp_cust_az12
WHERE bdate > GETDATE();

-------------------------------------------------------
SELECT *
FROM Bronze.erp_px_cat_g1v2;

SELECT DISTINCT maintenance
FROM Bronze.erp_px_cat_g1v2;

SELECT DISTINCT subcat
FROM Bronze.erp_px_cat_g1v2;

SELECT DISTINCT cat
FROM Bronze.erp_px_cat_g1v2;
------------------------------------------
SELECT *
FROM Bronze.erp_loc_a101;

SELECT DISTINCT cntry
FROM Bronze.erp_loc_a101;

-----------------------------------------
/*
1. What problems did we find?
-- Through my inspection, I form some Null values, Spaces around the words, date inconsistency and found negative value for Cost.
2. Which values need standardization?
--Table crm_prd_info
	1)prd_cost - found null values.
--Table crm_sales_details
	1)sls_sales, sls_price - found NULL, 0 and negative value. so It should be in standared formate ($56.00)
3. Which values are invalid?
4. Which duplicates should be removed?
5. What should the Silver data/tables look like?
*/

