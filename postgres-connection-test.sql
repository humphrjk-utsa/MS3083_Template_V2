 -- PostgreSQL Connection Test
-- Run this to verify connection and test Northwind database

-- Connect to the northwind schema
SET search_path TO northwind, public;

-- Test query to verify tables exist
SELECT 'Categories' as table_name, COUNT(*) as row_count FROM categories
UNION ALL
SELECT 'Products' as table_name, COUNT(*) as row_count FROM products
UNION ALL
SELECT 'Customers' as table_name, COUNT(*) as row_count FROM customers
UNION ALL
SELECT 'Orders' as table_name, COUNT(*) as row_count FROM orders
UNION ALL
SELECT 'Order Details' as table_name, COUNT(*) as row_count FROM order_details;

-- Simple demo query - Top 5 products by name
SELECT product_name, unit_price, units_in_stock
FROM products
ORDER BY product_name
LIMIT 5;
