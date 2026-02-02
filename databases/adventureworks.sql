-- AdventureWorks Sample Database (Simplified for Training)
-- Based on Microsoft's AdventureWorks sample database

-- Create schema
CREATE SCHEMA IF NOT EXISTS adventureworks;
SET search_path TO adventureworks, public;

-- Person table
CREATE TABLE person (
    business_entity_id SERIAL PRIMARY KEY,
    person_type CHAR(2) NOT NULL,
    title VARCHAR(8),
    first_name VARCHAR(50) NOT NULL,
    middle_name VARCHAR(50),
    last_name VARCHAR(50) NOT NULL,
    suffix VARCHAR(10),
    email_promotion INTEGER DEFAULT 0,
    modified_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Customer table
CREATE TABLE customer (
    customer_id SERIAL PRIMARY KEY,
    person_id INTEGER REFERENCES person(business_entity_id),
    store_id INTEGER,
    territory_id INTEGER,
    account_number VARCHAR(10),
    modified_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Product Category table
CREATE TABLE product_category (
    product_category_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    modified_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Product Subcategory table
CREATE TABLE product_subcategory (
    product_subcategory_id SERIAL PRIMARY KEY,
    product_category_id INTEGER REFERENCES product_category(product_category_id),
    name VARCHAR(50) NOT NULL,
    modified_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Product table
CREATE TABLE product (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    product_number VARCHAR(25) NOT NULL UNIQUE,
    make_flag BOOLEAN DEFAULT TRUE,
    finished_goods_flag BOOLEAN DEFAULT TRUE,
    color VARCHAR(15),
    safety_stock_level SMALLINT NOT NULL,
    reorder_point SMALLINT NOT NULL,
    standard_cost DECIMAL(19,4) NOT NULL,
    list_price DECIMAL(19,4) NOT NULL,
    size VARCHAR(5),
    size_unit_measure_code CHAR(3),
    weight DECIMAL(8,2),
    weight_unit_measure_code CHAR(3),
    days_to_manufacture INTEGER NOT NULL,
    product_line CHAR(2),
    class CHAR(2),
    style CHAR(2),
    product_subcategory_id INTEGER REFERENCES product_subcategory(product_subcategory_id),
    product_model_id INTEGER,
    sell_start_date TIMESTAMP NOT NULL,
    sell_end_date TIMESTAMP,
    discontinued_date TIMESTAMP,
    modified_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Sales Territory table
CREATE TABLE sales_territory (
    territory_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    country_region_code VARCHAR(3) NOT NULL,
    group_name VARCHAR(50) NOT NULL,
    sales_ytd DECIMAL(19,4) DEFAULT 0.00,
    sales_last_year DECIMAL(19,4) DEFAULT 0.00,
    cost_ytd DECIMAL(19,4) DEFAULT 0.00,
    cost_last_year DECIMAL(19,4) DEFAULT 0.00,
    modified_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Sales Order Header table
CREATE TABLE sales_order_header (
    sales_order_id SERIAL PRIMARY KEY,
    revision_number SMALLINT DEFAULT 0,
    order_date TIMESTAMP NOT NULL,
    due_date TIMESTAMP NOT NULL,
    ship_date TIMESTAMP,
    status SMALLINT NOT NULL DEFAULT 1,
    online_order_flag BOOLEAN DEFAULT FALSE,
    sales_order_number VARCHAR(25) NOT NULL,
    purchase_order_number VARCHAR(25),
    account_number VARCHAR(15),
    customer_id INTEGER NOT NULL REFERENCES customer(customer_id),
    sales_person_id INTEGER,
    territory_id INTEGER REFERENCES sales_territory(territory_id),
    bill_to_address_id INTEGER NOT NULL,
    ship_to_address_id INTEGER NOT NULL,
    ship_method_id INTEGER NOT NULL,
    credit_card_id INTEGER,
    credit_card_approval_code VARCHAR(15),
    currency_rate_id INTEGER,
    sub_total DECIMAL(19,4) NOT NULL DEFAULT 0.00,
    tax_amt DECIMAL(19,4) NOT NULL DEFAULT 0.00,
    freight DECIMAL(19,4) NOT NULL DEFAULT 0.00,
    total_due DECIMAL(19,4) NOT NULL,
    comment TEXT,
    modified_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Sales Order Detail table
CREATE TABLE sales_order_detail (
    sales_order_id INTEGER NOT NULL REFERENCES sales_order_header(sales_order_id),
    sales_order_detail_id SERIAL,
    carrier_tracking_number VARCHAR(25),
    order_qty SMALLINT NOT NULL,
    product_id INTEGER NOT NULL REFERENCES product(product_id),
    special_offer_id INTEGER NOT NULL,
    unit_price DECIMAL(19,4) NOT NULL,
    unit_price_discount DECIMAL(19,4) DEFAULT 0.00,
    line_total DECIMAL(38,6) NOT NULL,
    modified_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (sales_order_id, sales_order_detail_id)
);

-- Insert sample data for Product Categories
INSERT INTO product_category (name) VALUES
('Bikes'),
('Components'),
('Clothing'),
('Accessories');

-- Insert sample data for Product Subcategories
INSERT INTO product_subcategory (product_category_id, name) VALUES
(1, 'Mountain Bikes'),
(1, 'Road Bikes'),
(1, 'Touring Bikes'),
(2, 'Handlebars'),
(2, 'Bottom Brackets'),
(3, 'Jerseys'),
(3, 'Shorts'),
(4, 'Bike Racks'),
(4, 'Cleaners');

-- Insert sample data for Products
INSERT INTO product (name, product_number, standard_cost, list_price, safety_stock_level, reorder_point, days_to_manufacture, product_subcategory_id, sell_start_date) VALUES
('Mountain-100 Silver, 38', 'BK-M18S-38', 1912.1544, 3399.99, 100, 75, 1, 1, '2013-05-30'),
('Mountain-100 Silver, 42', 'BK-M18S-42', 1912.1544, 3399.99, 100, 75, 1, 1, '2013-05-30'),
('Mountain-100 Black, 38', 'BK-M18B-38', 1898.0944, 3374.99, 100, 75, 1, 1, '2013-05-30'),
('Road-150 Red, 62', 'BK-R93R-62', 2171.2942, 3578.27, 100, 75, 2, 2, '2013-05-30'),
('Road-150 Red, 44', 'BK-R93R-44', 2171.2942, 3578.27, 100, 75, 2, 2, '2013-05-30'),
('Touring-1000 Blue, 46', 'BK-T79U-46', 1481.9379, 2384.07, 100, 75, 2, 3, '2013-05-30'),
('HL Mountain Handlebars', 'HB-M918', 53.3999, 120.27, 100, 75, 1, 4, '2013-05-30'),
('ML Mountain Handlebars', 'HB-M763', 27.4925, 61.92, 100, 75, 1, 4, '2013-05-30'),
('Men''s Sports Shorts, S', 'SH-M897-S', 23.7500, 59.99, 100, 75, 1, 7, '2013-05-30'),
('Men''s Sports Shorts, M', 'SH-M897-M', 23.7500, 59.99, 100, 75, 1, 7, '2013-05-30');

-- Insert sample data for Sales Territory
INSERT INTO sales_territory (name, country_region_code, group_name, sales_ytd, sales_last_year) VALUES
('Northwest', 'US', 'North America', 7887186.7882, 3298694.4938),
('Northeast', 'US', 'North America', 2402176.8476, 3607148.9371),
('Central', 'US', 'North America', 3072175.118, 3205014.0767),
('Southwest', 'US', 'North America', 10510853.8739, 5366575.7098),
('Southeast', 'US', 'North America', 2538667.2515, 3925071.4318),
('Canada', 'CA', 'North America', 6771829.1376, 5693988.86),
('France', 'FR', 'Europe', 2396539.7601, 2396539.7601),
('Germany', 'DE', 'Europe', 1307949.7917, 1307949.7917),
('Australia', 'AU', 'Pacific', 4116871.2277, 4116871.2277),
('United Kingdom', 'GB', 'Europe', 1635823.3967, 1635823.3967);

-- Insert sample data for Person
INSERT INTO person (person_type, first_name, last_name) VALUES
('IN', 'Ken', 'Sánchez'),
('IN', 'Terri', 'Duffy'),
('IN', 'Roberto', 'Tamburello'),
('SC', 'Rob', 'Walters'),
('SC', 'Gail', 'Erickson'),
('IN', 'Jossef', 'Goldberg'),
('EM', 'Dylan', 'Miller'),
('EM', 'Diane', 'Margheim'),
('EM', 'Gigi', 'Matthew'),
('EM', 'Michael', 'Raheem');

-- Insert sample data for Customer
INSERT INTO customer (person_id, territory_id, account_number) VALUES
(1, 1, 'AW00000001'),
(2, 1, 'AW00000002'),
(3, 2, 'AW00000003'),
(4, 2, 'AW00000004'),
(5, 3, 'AW00000005'),
(6, 3, 'AW00000006'),
(7, 4, 'AW00000007'),
(8, 4, 'AW00000008'),
(9, 5, 'AW00000009'),
(10, 5, 'AW00000010');

-- Insert sample data for Sales Order Header
INSERT INTO sales_order_header (order_date, due_date, ship_date, status, online_order_flag, sales_order_number, customer_id, territory_id, bill_to_address_id, ship_to_address_id, ship_method_id, sub_total, tax_amt, freight, total_due) VALUES
('2014-07-01', '2014-07-13', '2014-07-08', 5, false, 'SO43659', 1, 1, 1, 1, 1, 20565.6206, 1971.5149, 616.0984, 23153.2339),
('2014-07-01', '2014-07-13', '2014-07-08', 5, false, 'SO43660', 2, 1, 2, 2, 1, 1294.2529, 124.2483, 38.8276, 1457.3288),
('2014-07-01', '2014-07-13', '2014-07-08', 5, false, 'SO43661', 3, 2, 3, 3, 1, 32726.4786, 3153.7696, 985.553, 36865.8012),
('2014-07-01', '2014-07-13', '2014-07-08', 5, false, 'SO43662', 4, 2, 4, 4, 1, 28832.5289, 2775.1646, 867.2389, 32474.9324),
('2014-07-01', '2014-07-13', '2014-07-08', 5, false, 'SO43663', 5, 3, 5, 5, 1, 419.4589, 40.2681, 12.5838, 472.3108);

-- Insert sample data for Sales Order Detail
INSERT INTO sales_order_detail (sales_order_id, order_qty, product_id, special_offer_id, unit_price, unit_price_discount, line_total) VALUES
(1, 1, 1, 1, 3399.99, 0.00, 3399.99),
(1, 3, 2, 1, 3399.99, 0.00, 10199.97),
(2, 1, 3, 1, 3374.99, 0.00, 3374.99),
(3, 2, 4, 1, 3578.27, 0.00, 7156.54),
(4, 1, 5, 1, 3578.27, 0.00, 3578.27),
(5, 4, 9, 1, 59.99, 0.00, 239.96);

-- Grant permissions to vscode user
GRANT ALL PRIVILEGES ON SCHEMA adventureworks TO student;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA adventureworks TO student;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA adventureworks TO student;

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
