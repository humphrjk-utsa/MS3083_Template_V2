# Sample Databases for Training

This directory contains several sample databases commonly used for learning SQL and database concepts. Each database includes both schema definitions and sample data.

## Available Databases

### 1. Northwind (`northwind.sql`)
**Classic e-commerce training database**
- **Schema**: `northwind`
- **Tables**: Categories, Suppliers, Products, Customers, Orders, Order Details, Employees, Shippers, Regions, Territories
- **Use Cases**: 
  - Basic SQL queries
  - JOIN operations
  - Aggregate functions
  - Business reporting
  - E-commerce analytics

### 2. AdventureWorks (`adventureworks.sql`)
**Microsoft's flagship sample database (simplified)**
- **Schema**: `adventureworks`
- **Tables**: Person, Customer, Product, Sales, Territory, Address
- **Use Cases**:
  - Complex queries
  - Data warehousing concepts
  - Business intelligence
  - Sales analysis
  - Customer demographics

### 3. World Wide Importers (`worldwideimporters.sql`)
**Modern Microsoft sample database (simplified)**
- **Schema**: `wwi`
- **Tables**: People, Customers, Suppliers, Stock Items, Orders, Invoices, Transactions
- **Use Cases**:
  - Advanced SQL features
  - Temporal data
  - JSON data handling
  - Modern database patterns
  - Supply chain analytics

### 4. Chinook (`chinook.sql`)
**Digital music store database**
- **Schema**: `chinook`
- **Tables**: Artist, Album, Track, Customer, Employee, Invoice, Invoice Line, Playlist
- **Use Cases**:
  - Music industry analytics
  - Sales reporting
  - Customer analysis
  - Complex JOINs
  - Playlist management

### 5. Sakila (`sakila.sql`)
**DVD rental store database**
- **Schema**: `sakila`
- **Tables**: Film, Actor, Customer, Rental, Payment, Category, Language, Address, City, Country
- **Use Cases**:
  - Rental business analytics
  - Movie industry data
  - Geographic analysis
  - Time-based queries
  - Many-to-many relationships

### 6. HR Employees (`hr_employees.sql`)
**Human resources and hierarchical data**
- **Schema**: `hr`
- **Tables**: Employees, Departments, Jobs, Locations, Countries, Regions, Job History
- **Use Cases**:
  - Hierarchical queries
  - Employee management
  - Organizational structure
  - Geographic data
  - Career progression analysis

### 7. Sample Database (`sample.sql`)
**Simple starter database**
- **Schema**: `public`
- **Tables**: Students (basic example)
- **Use Cases**:
  - First SQL queries
  - Basic operations
  - Testing connections

## Loading a Database



### Manual Loading
```bash
# Method 1: Using psql directly
psql -U vscode -d postgres -f /workspaces/data-management-classroom/databases/[filename].sql

# Method 2: Using the setup script
./scripts/setup_database.sh northwind

# Method 3: Load all databases at once
for db in databases/*.sql; do
    echo "Loading $(basename $db)..."
    psql -U student -d student_db -f "$db"
done
```

## Testing Database Connection

After loading a database, test your connection:

```bash
# Test basic connection
python scripts/test_connection.py

# Test with specific database queries
python scripts/test-codespace.py
```

## Sample Queries

### Northwind Examples
```sql
-- Set schema
SET search_path TO northwind, public;

-- Basic product listing
SELECT product_name, unit_price FROM products 
WHERE discontinued = FALSE 
ORDER BY unit_price DESC;

-- Customer orders summary
SELECT c.company_name, COUNT(o.order_id) as order_count
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.company_name
ORDER BY order_count DESC;
```

### AdventureWorks Examples
```sql
-- Set schema
SET search_path TO adventureworks, public;

-- Product sales analysis
SELECT pc.name as category, COUNT(p.product_id) as product_count
FROM product_category pc
LEFT JOIN product_subcategory ps ON pc.product_category_id = ps.product_category_id
LEFT JOIN product p ON ps.product_subcategory_id = p.product_subcategory_id
GROUP BY pc.name
ORDER BY product_count DESC;
```

### Chinook Examples
```sql
-- Set schema
SET search_path TO chinook, public;

-- Top selling tracks
SELECT t.name, ar.name as artist, al.title as album, 
       COUNT(il.invoice_line_id) as times_sold
FROM track t
JOIN album al ON t.album_id = al.album_id
JOIN artist ar ON al.artist_id = ar.artist_id
LEFT JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY t.name, ar.name, al.title
ORDER BY times_sold DESC;

-- Customer purchase summary
SELECT c.first_name || ' ' || c.last_name as customer_name,
       COUNT(i.invoice_id) as total_purchases,
       SUM(i.total) as total_spent
FROM customer c
LEFT JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, customer_name
ORDER BY total_spent DESC;
```

### Sakila Examples
```sql
-- Set schema
SET search_path TO sakila, public;

-- Most popular film categories
SELECT c.name as category, COUNT(r.rental_id) as rental_count
FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
JOIN film f ON fc.film_id = f.film_id
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY c.name
ORDER BY rental_count DESC;

-- Actor filmography
SELECT a.first_name || ' ' || a.last_name as actor_name,
       COUNT(fa.film_id) as film_count,
       string_agg(f.title, ', ') as films
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film f ON fa.film_id = f.film_id
GROUP BY a.actor_id, actor_name
ORDER BY film_count DESC;
```

### HR Employees Examples
```sql
-- Set schema
SET search_path TO hr, public;

-- Employee hierarchy
SELECT e.employee_id, e.first_name || ' ' || e.last_name as employee_name,
       m.first_name || ' ' || m.last_name as manager_name,
       d.department_name, j.job_title, e.salary
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.employee_id
JOIN departments d ON e.department_id = d.department_id
JOIN jobs j ON e.job_id = j.job_id
ORDER BY d.department_name, e.salary DESC;

-- Department salary analysis
SELECT d.department_name,
       COUNT(e.employee_id) as employee_count,
       ROUND(AVG(e.salary), 2) as avg_salary,
       MIN(e.salary) as min_salary,
       MAX(e.salary) as max_salary
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_name
ORDER BY avg_salary DESC;
```

## Database Schemas

Each database uses its own schema to avoid naming conflicts:
- `northwind` - Northwind database
- `adventureworks` - AdventureWorks database  
- `wwi` - World Wide Importers database
- `chinook` - Chinook music store database
- `sakila` - Sakila DVD rental database
- `hr` - HR Employees database
- `public` - Simple sample database

### Schema Management
```sql
-- List all schemas
\dn

-- Set working schema
SET search_path TO northwind, public;

-- Show current schema
SELECT current_schema();

-- Show all tables in a schema
\dt northwind.*
```

## Troubleshooting

### Database Not Found
```bash
# Check if database exists
psql -U student -d student_db -c "\l"

# Check if schemas exist
psql -U student -d student_db -c "\dn"
```

### Permission Issues
```bash
# Grant permissions (run as postgres user)
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE student_db TO student;"
```

### Connection Issues
```bash
# Test PostgreSQL service
sudo systemctl status postgresql

# Check PostgreSQL logs
sudo tail -f /var/log/postgresql/postgresql-*-main.log
```

## Additional Resources

- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [SQL Tutorial](https://www.w3schools.com/sql/)
- [Database Design Best Practices](https://www.databasestar.com/database-design-best-practices/)
- [Northwind Database Guide](https://docs.microsoft.com/en-us/dotnet/framework/data/adonet/sql/linq/downloading-sample-databases)

## Contributing

To add new sample databases:
1. Create a new `.sql` file in this directory
2. Include schema creation and sample data
3. Add documentation to this README
4. Test loading and basic queries
5. Update the setup scripts if needed
