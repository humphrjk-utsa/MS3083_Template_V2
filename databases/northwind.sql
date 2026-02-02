-- Northwind Database Schema and Sample Data
-- Classic e-commerce training database

-- Create schema
CREATE SCHEMA IF NOT EXISTS northwind;
SET search_path TO northwind, public;

-- Categories table
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(15) NOT NULL,
    description TEXT,
    picture BYTEA
);

-- Suppliers table
CREATE TABLE suppliers (
    supplier_id SERIAL PRIMARY KEY,
    company_name VARCHAR(40) NOT NULL,
    contact_name VARCHAR(30),
    contact_title VARCHAR(30),
    address VARCHAR(60),
    city VARCHAR(15),
    region VARCHAR(15),
    postal_code VARCHAR(10),
    country VARCHAR(15),
    phone VARCHAR(24),
    fax VARCHAR(24),
    home_page TEXT
);

-- Products table
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(40) NOT NULL,
    supplier_id INTEGER REFERENCES suppliers(supplier_id),
    category_id INTEGER REFERENCES categories(category_id),
    quantity_per_unit VARCHAR(20),
    unit_price DECIMAL(10,4) DEFAULT 0,
    units_in_stock SMALLINT DEFAULT 0,
    units_on_order SMALLINT DEFAULT 0,
    reorder_level SMALLINT DEFAULT 0,
    discontinued BOOLEAN NOT NULL DEFAULT FALSE
);

-- Customers table
CREATE TABLE customers (
    customer_id CHAR(5) PRIMARY KEY,
    company_name VARCHAR(40) NOT NULL,
    contact_name VARCHAR(30),
    contact_title VARCHAR(30),
    address VARCHAR(60),
    city VARCHAR(15),
    region VARCHAR(15),
    postal_code VARCHAR(10),
    country VARCHAR(15),
    phone VARCHAR(24),
    fax VARCHAR(24)
);

-- Employees table
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    last_name VARCHAR(20) NOT NULL,
    first_name VARCHAR(10) NOT NULL,
    title VARCHAR(30),
    title_of_courtesy VARCHAR(25),
    birth_date DATE,
    hire_date DATE,
    address VARCHAR(60),
    city VARCHAR(15),
    region VARCHAR(15),
    postal_code VARCHAR(10),
    country VARCHAR(15),
    home_phone VARCHAR(24),
    extension VARCHAR(4),
    photo BYTEA,
    notes TEXT,
    reports_to INTEGER REFERENCES employees(employee_id)
);

-- Shippers table
CREATE TABLE shippers (
    shipper_id SERIAL PRIMARY KEY,
    company_name VARCHAR(40) NOT NULL,
    phone VARCHAR(24)
);

-- Orders table
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id CHAR(5) REFERENCES customers(customer_id),
    employee_id INTEGER REFERENCES employees(employee_id),
    order_date DATE,
    required_date DATE,
    shipped_date DATE,
    ship_via INTEGER REFERENCES shippers(shipper_id),
    freight DECIMAL(10,4) DEFAULT 0,
    ship_name VARCHAR(40),
    ship_address VARCHAR(60),
    ship_city VARCHAR(15),
    ship_region VARCHAR(15),
    ship_postal_code VARCHAR(10),
    ship_country VARCHAR(15)
);

-- Order Details table
CREATE TABLE order_details (
    order_id INTEGER REFERENCES orders(order_id),
    product_id INTEGER REFERENCES products(product_id),
    unit_price DECIMAL(10,4) NOT NULL DEFAULT 0,
    quantity SMALLINT NOT NULL DEFAULT 1,
    discount REAL NOT NULL DEFAULT 0,
    PRIMARY KEY (order_id, product_id)
);

-- Insert sample data for Categories
INSERT INTO categories (category_name, description) VALUES
('Beverages', 'Soft drinks, coffees, teas, beers, and ales'),
('Condiments', 'Sweet and savory sauces, relishes, spreads, and seasonings'),
('Dairy Products', 'Cheeses'),
('Grains/Cereals', 'Breads, crackers, pasta, and cereal'),
('Meat/Poultry', 'Prepared meats'),
('Produce', 'Dried fruit and bean curd'),
('Seafood', 'Seaweed and fish'),
('Confections', 'Desserts, candies, and sweet breads');

-- Insert sample data for Suppliers
INSERT INTO suppliers (company_name, contact_name, city, country, phone) VALUES
('Exotic Liquids', 'Charlotte Cooper', 'London', 'UK', '(171) 555-2222'),
('New Orleans Cajun Delights', 'Shelley Burke', 'New Orleans', 'USA', '(100) 555-4822'),
('Grandma Kelly''s Homestead', 'Regina Murphy', 'Ann Arbor', 'USA', '(313) 555-5735'),
('Tokyo Traders', 'Yoshi Nagase', 'Tokyo', 'Japan', '(03) 3555-5011'),
('Cooperativa de Quesos ''Las Cabras''', 'Antonio del Valle Saavedra', 'Oviedo', 'Spain', '(98) 598 76 54');

-- Insert sample data for Products
INSERT INTO products (product_name, supplier_id, category_id, unit_price, units_in_stock) VALUES
('Chai', 1, 1, 18.00, 39),
('Chang', 1, 1, 19.00, 17),
('Aniseed Syrup', 1, 2, 10.00, 13),
('Chef Anton''s Cajun Seasoning', 2, 2, 22.00, 53),
('Chef Anton''s Gumbo Mix', 2, 2, 21.35, 0),
('Grandma''s Boysenberry Spread', 3, 2, 25.00, 120),
('Uncle Bob''s Organic Dried Pears', 3, 7, 30.00, 15),
('Northwoods Cranberry Sauce', 3, 2, 40.00, 6),
('Mishi Kobe Niku', 4, 6, 97.00, 29),
('Ikura', 4, 8, 31.00, 31);

-- Insert sample data for Customers
INSERT INTO customers (customer_id, company_name, contact_name, city, country) VALUES
('ALFKI', 'Alfreds Futterkiste', 'Maria Anders', 'Berlin', 'Germany'),
('ANATR', 'Ana Trujillo Emparedados y helados', 'Ana Trujillo', 'México D.F.', 'Mexico'),
('ANTON', 'Antonio Moreno Taquería', 'Antonio Moreno', 'México D.F.', 'Mexico'),
('AROUT', 'Around the Horn', 'Thomas Hardy', 'London', 'UK'),
('BERGS', 'Berglunds snabbköp', 'Christina Berglund', 'Luleå', 'Sweden');

-- Insert sample data for Employees
INSERT INTO employees (last_name, first_name, title, hire_date, city, country) VALUES
('Davolio', 'Nancy', 'Sales Representative', '1992-05-01', 'Seattle', 'USA'),
('Fuller', 'Andrew', 'Vice President, Sales', '1992-08-14', 'Tacoma', 'USA'),
('Leverling', 'Janet', 'Sales Representative', '1992-04-01', 'Kirkland', 'USA'),
('Peacock', 'Margaret', 'Sales Representative', '1993-05-03', 'Redmond', 'USA'),
('Buchanan', 'Steven', 'Sales Manager', '1993-10-17', 'London', 'UK');

-- Insert sample data for Shippers
INSERT INTO shippers (company_name, phone) VALUES
('Speedy Express', '(503) 555-9831'),
('United Package', '(503) 555-3199'),
('Federal Shipping', '(503) 555-9931');

-- Insert sample data for Orders
INSERT INTO orders (customer_id, employee_id, order_date, ship_city, ship_country) VALUES
('ALFKI', 1, '1996-07-04', 'Berlin', 'Germany'),
('ANATR', 2, '1996-07-05', 'México D.F.', 'Mexico'),
('ANTON', 3, '1996-07-08', 'México D.F.', 'Mexico'),
('AROUT', 4, '1996-07-08', 'London', 'UK'),
('BERGS', 5, '1996-07-09', 'Luleå', 'Sweden');

-- Insert sample data for Order Details
INSERT INTO order_details (order_id, product_id, unit_price, quantity, discount) VALUES
(1, 1, 18.00, 12, 0.0),
(1, 2, 19.00, 10, 0.0),
(2, 3, 10.00, 5, 0.0),
(3, 4, 22.00, 9, 0.0),
(4, 5, 21.35, 40, 0.0);

-- Grant permissions to vscode user
GRANT ALL PRIVILEGES ON SCHEMA northwind TO student;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA northwind TO student;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA northwind TO student;

-- Additional grants for student user (auto-added by fix script)
DO $$
DECLARE
    schema_name text;
BEGIN
    -- Grant permissions on all schemas in this database to student
    FOR schema_name IN 
        SELECT nspname FROM pg_namespace 
        WHERE nspname NOT IN ('information_schema', 'pg_catalog', 'pg_toast')
        AND nspname NOT LIKE 'pg_temp_%'
        AND nspname NOT LIKE 'pg_toast_temp_%'
    LOOP
        EXECUTE format('GRANT ALL PRIVILEGES ON SCHEMA %I TO student', schema_name);
        EXECUTE format('GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA %I TO student', schema_name);
        EXECUTE format('GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA %I TO student', schema_name);
        EXECUTE format('GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA %I TO student', schema_name);
    END LOOP;
END
$$;

-- Additional grants for student user (auto-added by fix script)
DO $$
DECLARE
    schema_name text;
BEGIN
    -- Grant permissions on all schemas in this database to student
    FOR schema_name IN 
        SELECT nspname FROM pg_namespace 
        WHERE nspname NOT IN ('information_schema', 'pg_catalog', 'pg_toast')
        AND nspname NOT LIKE 'pg_temp_%'
        AND nspname NOT LIKE 'pg_toast_temp_%'
    LOOP
        EXECUTE format('GRANT ALL PRIVILEGES ON SCHEMA %I TO student', schema_name);
        EXECUTE format('GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA %I TO student', schema_name);
        EXECUTE format('GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA %I TO student', schema_name);
        EXECUTE format('GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA %I TO student', schema_name);
    END LOOP;
END
$$;

-- Additional grants for student user (auto-added by fix script)
DO $$
DECLARE
    schema_name text;
BEGIN
    -- Grant permissions on all schemas in this database to student
    FOR schema_name IN 
        SELECT nspname FROM pg_namespace 
        WHERE nspname NOT IN ('information_schema', 'pg_catalog', 'pg_toast')
        AND nspname NOT LIKE 'pg_temp_%'
        AND nspname NOT LIKE 'pg_toast_temp_%'
    LOOP
        EXECUTE format('GRANT ALL PRIVILEGES ON SCHEMA %I TO student', schema_name);
        EXECUTE format('GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA %I TO student', schema_name);
        EXECUTE format('GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA %I TO student', schema_name);
        EXECUTE format('GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA %I TO student', schema_name);
    END LOOP;
END
$$;
