-- Database Dashboard - Summary Views Across All Sample Databases
-- This script creates unified views showing data from all loaded databases

-- Create a dashboard schema
CREATE SCHEMA IF NOT EXISTS dashboard;
SET search_path TO dashboard, public;

-- Database inventory view
CREATE OR REPLACE VIEW database_inventory AS
SELECT 
    'Sample' as database_name,
    'public' as schema_name,
    (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'students') as table_count,
    (SELECT CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'students') 
        THEN (SELECT COUNT(*) FROM public.students) 
        ELSE 0 
    END) as record_count,
    'Basic learning database' as description

UNION ALL

SELECT 
    'Northwind' as database_name,
    'northwind' as schema_name,
    (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'northwind') as table_count,
    COALESCE((SELECT COUNT(*) FROM northwind.products), 0) as record_count,
    'E-commerce database' as description
WHERE EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'northwind')

UNION ALL

SELECT 
    'AdventureWorks' as database_name,
    'adventureworks' as schema_name,
    (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'adventureworks') as table_count,
    COALESCE((SELECT COUNT(*) FROM adventureworks.product), 0) as record_count,
    'Microsoft enterprise sample' as description
WHERE EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'adventureworks')

UNION ALL

SELECT 
    'WorldWideImporters' as database_name,
    'wwi' as schema_name,
    (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'wwi') as table_count,
    COALESCE((SELECT COUNT(*) FROM wwi.customers), 0) as record_count,
    'Modern Microsoft sample' as description
WHERE EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'wwi')

UNION ALL

SELECT 
    'Chinook' as database_name,
    'chinook' as schema_name,
    (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'chinook') as table_count,
    COALESCE((SELECT COUNT(*) FROM chinook.track), 0) as record_count,
    'Digital music store' as description
WHERE EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'chinook')

UNION ALL

SELECT 
    'Sakila' as database_name,
    'sakila' as schema_name,
    (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'sakila') as table_count,
    COALESCE((SELECT COUNT(*) FROM sakila.film), 0) as record_count,
    'DVD rental store' as description
WHERE EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'sakila')

UNION ALL

SELECT 
    'HR Employees' as database_name,
    'hr' as schema_name,
    (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'hr') as table_count,
    COALESCE((SELECT COUNT(*) FROM hr.employees), 0) as record_count,
    'HR and hierarchical data' as description
WHERE EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'hr');

-- Cross-database analytics view
CREATE OR REPLACE VIEW cross_database_summary AS
SELECT 
    'Customer Analysis' as analysis_type,
    'Northwind' as source_database,
    COUNT(*) as count,
    'Total customers' as metric
FROM northwind.customers
WHERE EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'northwind')

UNION ALL

SELECT 
    'Customer Analysis' as analysis_type,
    'AdventureWorks' as source_database,
    COUNT(*) as count,
    'Total customers' as metric
FROM adventureworks.customer
WHERE EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'adventureworks')

UNION ALL

SELECT 
    'Customer Analysis' as analysis_type,
    'Chinook' as source_database,
    COUNT(*) as count,
    'Total customers' as metric
FROM chinook.customer
WHERE EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'chinook')

UNION ALL

SELECT 
    'Customer Analysis' as analysis_type,
    'Sakila' as source_database,
    COUNT(*) as count,
    'Total customers' as metric
FROM sakila.customer
WHERE EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'sakila')

UNION ALL

SELECT 
    'Product Analysis' as analysis_type,
    'Northwind' as source_database,
    COUNT(*) as count,
    'Total products' as metric
FROM northwind.products
WHERE EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'northwind')

UNION ALL

SELECT 
    'Product Analysis' as analysis_type,
    'AdventureWorks' as source_database,
    COUNT(*) as count,
    'Total products' as metric
FROM adventureworks.product
WHERE EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'adventureworks')

UNION ALL

SELECT 
    'Product Analysis' as analysis_type,
    'Chinook' as source_database,
    COUNT(*) as count,
    'Total tracks' as metric
FROM chinook.track
WHERE EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'chinook')

UNION ALL

SELECT 
    'Product Analysis' as analysis_type,
    'Sakila' as source_database,
    COUNT(*) as count,
    'Total films' as metric
FROM sakila.film
WHERE EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'sakila')

UNION ALL

SELECT 
    'Employee Analysis' as analysis_type,
    'Northwind' as source_database,
    COUNT(*) as count,
    'Total employees' as metric
FROM northwind.employees
WHERE EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'northwind')

UNION ALL

SELECT 
    'Employee Analysis' as analysis_type,
    'HR Database' as source_database,
    COUNT(*) as count,
    'Total employees' as metric
FROM hr.employees
WHERE EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'hr');

-- Schema overview view
CREATE OR REPLACE VIEW schema_overview AS
SELECT 
    schemaname as schema_name,
    COUNT(*) as table_count,
    string_agg(tablename, ', ' ORDER BY tablename) as table_names
FROM pg_tables 
WHERE schemaname IN ('public', 'northwind', 'adventureworks', 'wwi', 'chinook', 'sakila', 'hr')
GROUP BY schemaname
ORDER BY 
    CASE schemaname
        WHEN 'public' THEN 1
        WHEN 'northwind' THEN 2
        WHEN 'adventureworks' THEN 3
        WHEN 'wwi' THEN 4
        WHEN 'chinook' THEN 5
        WHEN 'sakila' THEN 6
        WHEN 'hr' THEN 7
        ELSE 8
    END;

-- Create a function to get database statistics
CREATE OR REPLACE FUNCTION get_database_stats()
RETURNS TABLE(
    schema_name TEXT,
    table_name TEXT,
    row_count BIGINT,
    size_bytes BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.schemaname::TEXT,
        t.tablename::TEXT,
        CASE 
            WHEN t.schemaname = 'public' AND t.tablename = 'students' THEN 
                (SELECT COUNT(*) FROM public.students)
            WHEN t.schemaname = 'northwind' AND t.tablename = 'products' THEN 
                (SELECT COUNT(*) FROM northwind.products)
            WHEN t.schemaname = 'adventureworks' AND t.tablename = 'product' THEN 
                (SELECT COUNT(*) FROM adventureworks.product)
            WHEN t.schemaname = 'chinook' AND t.tablename = 'track' THEN 
                (SELECT COUNT(*) FROM chinook.track)
            WHEN t.schemaname = 'sakila' AND t.tablename = 'film' THEN 
                (SELECT COUNT(*) FROM sakila.film)
            WHEN t.schemaname = 'hr' AND t.tablename = 'employees' THEN 
                (SELECT COUNT(*) FROM hr.employees)
            ELSE 0
        END AS row_count,
        pg_total_relation_size(t.schemaname||'.'||t.tablename)::BIGINT as size_bytes
    FROM pg_tables t
    WHERE t.schemaname IN ('public', 'northwind', 'adventureworks', 'wwi', 'chinook', 'sakila', 'hr')
    ORDER BY t.schemaname, t.tablename;
END;
$$ LANGUAGE plpgsql;

-- Sample queries view for learning
CREATE OR REPLACE VIEW sample_queries AS
SELECT 
    'Basic SELECT' as query_type,
    'Beginner' as difficulty,
    'Sample Database' as database_name,
    'SELECT * FROM students WHERE grade > 90;' as example_query,
    'Show all students with grades above 90' as description

UNION ALL

SELECT 
    'Simple JOIN' as query_type,
    'Beginner' as difficulty,
    'Northwind' as database_name,
    'SET search_path TO northwind, public; SELECT p.product_name, c.category_name FROM products p JOIN categories c ON p.category_id = c.category_id;' as example_query,
    'Show products with their categories' as description

UNION ALL

SELECT 
    'Aggregate with GROUP BY' as query_type,
    'Intermediate' as difficulty,
    'Chinook' as database_name,
    'SET search_path TO chinook, public; SELECT ar.name, COUNT(t.track_id) as track_count FROM artist ar JOIN album al ON ar.artist_id = al.artist_id JOIN track t ON al.album_id = t.album_id GROUP BY ar.name ORDER BY track_count DESC;' as example_query,
    'Count tracks per artist' as description

UNION ALL

SELECT 
    'Hierarchical Query' as query_type,
    'Advanced' as difficulty,
    'HR Database' as database_name,
    'SET search_path TO hr, public; WITH RECURSIVE org_chart AS (SELECT employee_id, first_name, last_name, manager_id, 0 as level FROM employees WHERE manager_id IS NULL UNION ALL SELECT e.employee_id, e.first_name, e.last_name, e.manager_id, oc.level + 1 FROM employees e JOIN org_chart oc ON e.manager_id = oc.employee_id) SELECT * FROM org_chart ORDER BY level, last_name;' as example_query,
    'Show organizational hierarchy' as description

UNION ALL

SELECT 
    'Complex Analytics' as query_type,
    'Advanced' as difficulty,
    'Sakila' as database_name,
    'SET search_path TO sakila, public; SELECT c.name as category, COUNT(r.rental_id) as rental_count, ROUND(AVG(f.rental_rate), 2) as avg_rental_rate FROM category c JOIN film_category fc ON c.category_id = fc.category_id JOIN film f ON fc.film_id = f.film_id JOIN inventory i ON f.film_id = i.film_id JOIN rental r ON i.inventory_id = r.inventory_id GROUP BY c.name ORDER BY rental_count DESC;' as example_query,
    'Analyze rental patterns by category' as description;

-- Grant permissions
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA dashboard TO vscode;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA dashboard TO vscode;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA dashboard TO vscode;

-- Display instructions
SELECT 'Dashboard views created successfully!' as status;
SELECT 'Available views in dashboard schema:' as info;
SELECT 'database_inventory - Overview of all loaded databases' as view_1;
SELECT 'cross_database_summary - Cross-database analytics' as view_2;
SELECT 'schema_overview - Schema and table summary' as view_3;
SELECT 'sample_queries - Example queries for learning' as view_4;
SELECT 'get_database_stats() - Function for detailed statistics' as function_1;

-- Sample usage
SELECT 'Sample usage:' as usage_info;
SELECT 'SELECT * FROM dashboard.database_inventory;' as usage_1;
SELECT 'SELECT * FROM dashboard.cross_database_summary;' as usage_2;
SELECT 'SELECT * FROM dashboard.schema_overview;' as usage_3;
SELECT 'SELECT * FROM dashboard.sample_queries WHERE difficulty = ''Beginner'';' as usage_4;
SELECT 'SELECT * FROM dashboard.get_database_stats();' as usage_5;
