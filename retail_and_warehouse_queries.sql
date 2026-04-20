select * from sales;

-- top 10 suppliers who generated the highest total sales  

SELECT "SUPPLIER", 
ROUND(SUM("TOTAL SALES")::NUMERIC, 2) AS TOTAL_SALES,
ROUND(SUM("RETAIL SALES")::NUMERIC,2) AS retail_sales,
ROUND(SUM("WAREHOUSE SALES")::NUMERIC,2) AS warehouse_sales
FROM sales
GROUP BY "SUPPLIER"
ORDER BY TOTAL_SALES DESC LIMIT 10;

-- top 5 item types who generated the highest total sales 

SELECT "ITEM TYPE", 
ROUND(SUM("TOTAL SALES")::NUMERIC, 2) AS TOTAL_SALES,
ROUND(SUM("RETAIL SALES")::NUMERIC,2) AS retail_sales,
ROUND(SUM("WAREHOUSE SALES")::NUMERIC,2) AS warehouse_sales
FROM sales
GROUP BY "ITEM TYPE"
ORDER BY TOTAL_SALES DESC LIMIT 5;

SELECT 
"ITEM CODE",
"ITEM DESCRIPTION",
"ITEM TYPE",
ROUND(SUM("TOTAL SALES")::NUMERIC, 2) AS TOTAL_SALES,
ROUND(SUM("WAREHOUSE SALES")::NUMERIC,2) AS warehouse_sale
FROM sales
WHERE "ITEM TYPE" IN ('BEER', 'WINE', 'LIQUOR')
GROUP BY "ITEM CODE", "ITEM DESCRIPTION", "ITEM TYPE"
ORDER BY total_sales DESC;

-- Top 3 per category 
WITH ranked_sales AS (
    SELECT 
        "ITEM CODE",
        "ITEM DESCRIPTION",
        "ITEM TYPE",
        ROUND(SUM("TOTAL SALES")::NUMERIC, 2) AS total_sales,
        ROUND(SUM("WAREHOUSE SALES")::NUMERIC, 2) AS warehouse_sale,
        ROW_NUMBER() OVER (
            PARTITION BY "ITEM TYPE"
            ORDER BY SUM("TOTAL SALES") DESC
        ) AS rnk
    FROM sales
    GROUP BY "ITEM CODE", "ITEM DESCRIPTION", "ITEM TYPE"
)
SELECT *
FROM ranked_sales
WHERE rnk <= 3
ORDER BY "ITEM TYPE", total_sales DESC;


-- Count of negative values

SELECT 
    COUNT(CASE WHEN "RETAIL SALES" < 0 THEN 1 END) AS neg_retail,
    COUNT(CASE WHEN "RETAIL TRANSFERS" < 0 THEN 1 END) AS neg_transfers,
    COUNT(CASE WHEN "WAREHOUSE SALES" < 0 THEN 1 END) AS neg_warehouse
FROM sales;

-- Shows actual negative rows

SELECT *
FROM sales
WHERE "RETAIL SALES" < 0 
   OR "RETAIL TRANSFERS" < 0 
   OR "WAREHOUSE SALES" < 0
ORDER BY "WAREHOUSE SALES" ASC;

-- how much each category contributed each month

WITH monthly_sales AS (
    SELECT "YEAR", "MONTH", "ITEM TYPE",
        ROUND(SUM("RETAIL SALES" + "WAREHOUSE SALES")::NUMERIC,2) AS total_sales
    FROM sales
    WHERE "ITEM TYPE" IN ('BEER', 'WINE', 'LIQUOR')
    GROUP BY "YEAR", "MONTH", "ITEM TYPE"
)
SELECT 
    "YEAR",
    "MONTH",
    "ITEM TYPE",
    total_sales,
    ROUND((100.0 * total_sales / SUM(total_sales) OVER (PARTITION BY "YEAR", "MONTH"))::numeric, 2) 
        AS percentage_of_month
FROM monthly_sales
ORDER BY "YEAR", "MONTH", total_sales DESC;

-- actual sales values of beer, wine, and liquor each month

SELECT 
    "YEAR",
    "MONTH",
    ROUND(SUM(CASE WHEN "ITEM TYPE" = 'BEER'   THEN "RETAIL SALES" + "WAREHOUSE SALES" END)::NUMERIC,2) AS beer_total,
    ROUND(SUM(CASE WHEN "ITEM TYPE" = 'WINE'   THEN "RETAIL SALES" + "WAREHOUSE SALES" END)::NUMERIC,2) AS wine_total,
    ROUND(SUM(CASE WHEN "ITEM TYPE" = 'LIQUOR' THEN "RETAIL SALES" + "WAREHOUSE SALES" END)::NUMERIC,2) AS liquor_total,
    ROUND(SUM("RETAIL SALES" + "WAREHOUSE SALES")::NUMERIC, 2) AS grand_total
FROM sales
WHERE "ITEM TYPE" IN ('BEER', 'WINE', 'LIQUOR')
GROUP BY "YEAR", "MONTH"
ORDER BY "YEAR", "MONTH";
