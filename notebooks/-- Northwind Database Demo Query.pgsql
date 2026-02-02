-- Northwind Database Demo Query
-- This query demonstrates various SQL features and business insights

-- Set search path to northwind schema
-- Note: Make sure to connect to database 'student' with user 'jovyan'
SET search_path TO northwind, public;

-- Demo Query 1: Top 10 Products by Revenue
-- Shows product performance with category and supplier information
SELECT 
    p.product_name,
    c.category_name,
    s.company_name AS supplier,
    SUM(od.unit_price * od.quantity * (1 - od.discount)) AS total_revenue,
    COUNT(DISTINCT od.order_id) AS orders_count,
    SUM(od.quantity) AS total_quantity_sold
FROM products p
JOIN categories c ON p.category_id = c.category_id
JOIN suppliers s ON p.supplier_id = s.supplier_id
JOIN order_details od ON p.product_id = od.product_id
GROUP BY p.product_id, p.product_name, c.category_name, s.company_name
ORDER BY total_revenue DESC
LIMIT 10;
SELECT 
    cu.country,
    COUNT(DISTINCT cu.customer_id) AS customers_count,
    COUNT(o.order_id) AS total_orders,
    SUM(od.unit_price * od.quantity * (1 - od.discount)) AS total_sales,
    AVG(od.unit_price * od.quantity * (1 - od.discount)) AS avg_order_value
FROM customers cu
LEFT JOIN orders o ON cu.customer_id = o.customer_id
LEFT JOIN order_details od ON o.order_id = od.order_id
GROUP BY cu.country
HAVING COUNT(o.order_id) > 0
ORDER BY total_sales DESC;

-- Demo Query 3: Employee Performance Analysis
-- Shows employee sales performance with hierarchy
SELECT 
    e.first_name || ' ' || e.last_name AS employee_name,
    e.title,
    manager.first_name || ' ' || manager.last_name AS manager_name,
    COUNT(DISTINCT o.order_id) AS orders_handled,
    SUM(od.unit_price * od.quantity * (1 - od.discount)) AS total_sales,
    AVG(od.unit_price * od.quantity * (1 - od.discount)) AS avg_order_value
FROM employees e
LEFT JOIN employees manager ON e.reports_to = manager.employee_id
LEFT JOIN orders o ON e.employee_id = o.employee_id
LEFT JOIN order_details od ON o.order_id = od.order_id
GROUP BY e.employee_id, e.first_name, e.last_name, e.title, manager.first_name, manager.last_name
HAVING COUNT(DISTINCT o.order_id) > 0
ORDER BY total_sales DESC;

-- Demo Query 4: Monthly Sales Trends
-- Shows sales trends over time with growth analysis
SELECT 
    EXTRACT(YEAR FROM o.order_date) AS year,
    EXTRACT(MONTH FROM o.order_date) AS month,
    COUNT(DISTINCT o.order_id) AS orders_count,
    SUM(od.unit_price * od.quantity * (1 - od.discount)) AS monthly_sales,
    LAG(SUM(od.unit_price * od.quantity * (1 - od.discount))) OVER (ORDER BY EXTRACT(YEAR FROM o.order_date), EXTRACT(MONTH FROM o.order_date)) AS prev_month_sales,
    ROUND(
        ((SUM(od.unit_price * od.quantity * (1 - od.discount)) - 
          LAG(SUM(od.unit_price * od.quantity * (1 - od.discount))) OVER (ORDER BY EXTRACT(YEAR FROM o.order_date), EXTRACT(MONTH FROM o.order_date))
         ) / 
         LAG(SUM(od.unit_price * od.quantity * (1 - od.discount))) OVER (ORDER BY EXTRACT(YEAR FROM o.order_date), EXTRACT(MONTH FROM o.order_date))
        ) * 100, 2
    )::NUMERIC AS growth_percentage
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
WHERE o.order_date IS NOT NULL
GROUP BY EXTRACT(YEAR FROM o.order_date), EXTRACT(MONTH FROM o.order_date)
ORDER BY year, month;

-- Demo Query 5: Category Performance with Shipping Analysis
-- Shows category performance including shipping costs and delivery times
SELECT 
    c.category_name,
    COUNT(DISTINCT o.order_id) AS orders_count,
    SUM(od.unit_price * od.quantity * (1 - od.discount)) AS category_revenue,
    AVG(o.freight) AS avg_shipping_cost,
    AVG(o.shipped_date - o.order_date) AS avg_delivery_days,
    sh.company_name AS most_used_shipper
FROM categories c
JOIN products p ON c.category_id = p.category_id
JOIN order_details od ON p.product_id = od.product_id
JOIN orders o ON od.order_id = o.order_id
JOIN shippers sh ON o.ship_via = sh.shipper_id
WHERE o.shipped_date IS NOT NULL AND o.order_date IS NOT NULL
GROUP BY c.category_id, c.category_name, sh.company_name
ORDER BY category_revenue DESC;