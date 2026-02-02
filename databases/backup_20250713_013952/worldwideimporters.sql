-- World Wide Importers Sample Database (Simplified for Training)
-- Based on Microsoft's World Wide Importers sample database

-- Create schema
CREATE SCHEMA IF NOT EXISTS wwi;
SET search_path TO wwi, public;

-- Application.People table
CREATE TABLE people (
    person_id SERIAL PRIMARY KEY,
    full_name VARCHAR(50) NOT NULL,
    preferred_name VARCHAR(50) NOT NULL,
    search_name VARCHAR(101) NOT NULL,
    is_permitted_to_logon BOOLEAN NOT NULL,
    logon_name VARCHAR(50),
    is_external_logon_provider BOOLEAN NOT NULL,
    hashed_password BYTEA,
    is_system_user BOOLEAN NOT NULL,
    is_employee BOOLEAN NOT NULL,
    is_salesperson BOOLEAN NOT NULL,
    user_preferences TEXT,
    phone_number VARCHAR(20),
    fax_number VARCHAR(20),
    email_address VARCHAR(256),
    photo BYTEA,
    custom_fields TEXT,
    other_languages TEXT,
    valid_from TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_to TIMESTAMP NOT NULL DEFAULT '9999-12-31 23:59:59'
);

-- Sales.Customers table
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    bill_to_customer_id INTEGER NOT NULL,
    customer_category_id INTEGER NOT NULL,
    buying_group_id INTEGER,
    primary_contact_person_id INTEGER NOT NULL REFERENCES people(person_id),
    alternate_contact_person_id INTEGER REFERENCES people(person_id),
    delivery_method_id INTEGER NOT NULL,
    delivery_city_id INTEGER NOT NULL,
    postal_city_id INTEGER NOT NULL,
    credit_limit DECIMAL(18,2),
    account_opened_date DATE NOT NULL,
    standard_discount_percentage DECIMAL(18,3) NOT NULL,
    is_statement_sent BOOLEAN NOT NULL,
    is_on_credit_hold BOOLEAN NOT NULL,
    payment_days INTEGER NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    fax_number VARCHAR(20) NOT NULL,
    delivery_run VARCHAR(5),
    run_position VARCHAR(5),
    website_url VARCHAR(256) NOT NULL,
    delivery_address_line_1 VARCHAR(60) NOT NULL,
    delivery_address_line_2 VARCHAR(60),
    delivery_postal_code VARCHAR(10) NOT NULL,
    postal_address_line_1 VARCHAR(60) NOT NULL,
    postal_address_line_2 VARCHAR(60),
    postal_postal_code VARCHAR(10) NOT NULL,
    valid_from TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_to TIMESTAMP NOT NULL DEFAULT '9999-12-31 23:59:59'
);

-- Warehouse.StockItems table
CREATE TABLE stock_items (
    stock_item_id SERIAL PRIMARY KEY,
    stock_item_name VARCHAR(100) NOT NULL,
    supplier_id INTEGER NOT NULL,
    color_id INTEGER,
    unit_package_id INTEGER NOT NULL,
    outer_package_id INTEGER NOT NULL,
    brand VARCHAR(50),
    size VARCHAR(20),
    lead_time_days INTEGER NOT NULL,
    quantity_per_outer INTEGER NOT NULL,
    is_chiller_stock BOOLEAN NOT NULL,
    barcode VARCHAR(50),
    tax_rate DECIMAL(18,3) NOT NULL,
    unit_price DECIMAL(18,2) NOT NULL,
    recommended_retail_price DECIMAL(18,2),
    typical_weight_per_unit DECIMAL(18,3) NOT NULL,
    marketing_comments TEXT,
    internal_comments TEXT,
    photo BYTEA,
    custom_fields TEXT,
    tags TEXT,
    search_details TEXT NOT NULL,
    valid_from TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_to TIMESTAMP NOT NULL DEFAULT '9999-12-31 23:59:59'
);

-- Sales.Orders table
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(customer_id),
    salesperson_person_id INTEGER NOT NULL REFERENCES people(person_id),
    picked_by_person_id INTEGER REFERENCES people(person_id),
    contact_person_id INTEGER NOT NULL REFERENCES people(person_id),
    backorder_order_id INTEGER,
    order_date DATE NOT NULL,
    expected_delivery_date DATE NOT NULL,
    customer_purchase_order_number VARCHAR(20),
    is_undersupply_backordered BOOLEAN NOT NULL,
    comments TEXT,
    delivery_instructions TEXT,
    internal_comments TEXT,
    picking_completed_when TIMESTAMP,
    valid_from TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_to TIMESTAMP NOT NULL DEFAULT '9999-12-31 23:59:59'
);

-- Sales.OrderLines table
CREATE TABLE order_lines (
    order_line_id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders(order_id),
    stock_item_id INTEGER NOT NULL REFERENCES stock_items(stock_item_id),
    description VARCHAR(100) NOT NULL,
    package_type_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(18,2),
    tax_rate DECIMAL(18,3) NOT NULL,
    picked_quantity INTEGER NOT NULL,
    picking_completed_when TIMESTAMP,
    valid_from TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_to TIMESTAMP NOT NULL DEFAULT '9999-12-31 23:59:59'
);

-- Sales.Invoices table
CREATE TABLE invoices (
    invoice_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(customer_id),
    bill_to_customer_id INTEGER NOT NULL,
    order_id INTEGER REFERENCES orders(order_id),
    delivery_method_id INTEGER NOT NULL,
    contact_person_id INTEGER NOT NULL REFERENCES people(person_id),
    accounts_person_id INTEGER NOT NULL REFERENCES people(person_id),
    salesperson_person_id INTEGER NOT NULL REFERENCES people(person_id),
    packed_by_person_id INTEGER NOT NULL REFERENCES people(person_id),
    invoice_date DATE NOT NULL,
    customer_purchase_order_number VARCHAR(20),
    is_credit_note BOOLEAN NOT NULL,
    credit_note_reason TEXT,
    comments TEXT,
    delivery_instructions TEXT,
    internal_comments TEXT,
    total_dry_items INTEGER NOT NULL,
    total_chiller_items INTEGER NOT NULL,
    delivery_run VARCHAR(5),
    run_position VARCHAR(5),
    returned_delivery_data TEXT,
    confirmed_delivery_time TIMESTAMP,
    confirmed_received_by VARCHAR(4000),
    valid_from TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_to TIMESTAMP NOT NULL DEFAULT '9999-12-31 23:59:59'
);

-- Sales.InvoiceLines table
CREATE TABLE invoice_lines (
    invoice_line_id SERIAL PRIMARY KEY,
    invoice_id INTEGER NOT NULL REFERENCES invoices(invoice_id),
    stock_item_id INTEGER NOT NULL REFERENCES stock_items(stock_item_id),
    description VARCHAR(100) NOT NULL,
    package_type_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(18,2),
    tax_rate DECIMAL(18,3) NOT NULL,
    tax_amount DECIMAL(18,2) NOT NULL,
    line_profit DECIMAL(18,2) NOT NULL,
    extended_price DECIMAL(18,2) NOT NULL,
    valid_from TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_to TIMESTAMP NOT NULL DEFAULT '9999-12-31 23:59:59'
);

-- Insert sample data for People
INSERT INTO people (full_name, preferred_name, search_name, is_permitted_to_logon, is_external_logon_provider, is_system_user, is_employee, is_salesperson, phone_number, email_address) VALUES
('Data Conversion Only', 'Data Conversion Only', 'DATA CONVERSION ONLY', false, false, true, false, false, 'N/A', 'N/A'),
('Unknown', 'Unknown', 'UNKNOWN', false, false, true, false, false, 'N/A', 'N/A'),
('Kayla Woodcock', 'Kayla', 'KAYLA WOODCOCK', true, false, false, true, true, '(206) 555-8122', 'kayla@worldwideimporters.com'),
('Hudson Onslow', 'Hudson', 'HUDSON ONSLOW', true, false, false, true, true, '(206) 555-8123', 'hudson@worldwideimporters.com'),
('Isabella Rupp', 'Isabella', 'ISABELLA RUPP', true, false, false, true, false, '(206) 555-8124', 'isabella@worldwideimporters.com'),
('Sophia Hinton', 'Sophia', 'SOPHIA HINTON', true, false, false, false, false, '(425) 555-8125', 'sophia@tailspintoys.com'),
('Aakriti Byrraju', 'Aakriti', 'AAKRITI BYRRAJU', true, false, false, false, false, '(425) 555-8126', 'aakriti@tailspintoys.com'),
('Archer Lamble', 'Archer', 'ARCHER LAMBLE', true, false, false, false, false, '(425) 555-8127', 'archer@wingtiptoys.com'),
('Ainsley Brown', 'Ainsley', 'AINSLEY BROWN', true, false, false, false, false, '(425) 555-8128', 'ainsley@wingtiptoys.com'),
('Lila Bywater', 'Lila', 'LILA BYWATER', true, false, false, false, false, '(425) 555-8129', 'lila@contosoltd.com');

-- Insert sample data for Stock Items
INSERT INTO stock_items (stock_item_name, supplier_id, unit_package_id, outer_package_id, lead_time_days, quantity_per_outer, is_chiller_stock, tax_rate, unit_price, recommended_retail_price, typical_weight_per_unit, search_details) VALUES
('USB missile launcher (Green)', 12, 7, 7, 14, 1, false, 15.000, 8.00, 12.00, 0.300, 'USB missile launcher (Green)'),
('USB rocket launcher (Gray)', 12, 7, 7, 14, 1, false, 15.000, 8.00, 12.00, 0.300, 'USB rocket launcher (Gray)'),
('The Gu red shirt XML tag t-shirt (White) 3XL', 12, 7, 9, 14, 10, false, 15.000, 18.00, 27.00, 0.200, 'The Gu red shirt XML tag t-shirt (White) 3XL'),
('DBA joke mug (White)', 12, 7, 9, 14, 36, false, 15.000, 13.00, 19.50, 0.300, 'DBA joke mug (White)'),
('Smartphone holder (Black)', 12, 7, 7, 14, 1, false, 15.000, 18.00, 27.00, 0.050, 'Smartphone holder (Black)'),
('Air cushion film (Blue)', 12, 7, 6, 14, 20, false, 15.000, 2.50, 3.75, 0.050, 'Air cushion film (Blue)'),
('Courier post bag (White)', 12, 7, 6, 14, 20, false, 15.000, 2.50, 3.75, 0.050, 'Courier post bag (White)'),
('Packaging tape (Brown)', 12, 7, 6, 14, 20, false, 15.000, 1.90, 2.85, 0.050, 'Packaging tape (Brown)'),
('Bubble wrap suits', 12, 7, 6, 14, 20, false, 15.000, 2.50, 3.75, 0.050, 'Bubble wrap suits'),
('USB food flash drive - sushi roll', 12, 7, 7, 14, 1, false, 15.000, 32.00, 48.00, 0.050, 'USB food flash drive - sushi roll');

-- Insert sample data for Customers
INSERT INTO customers (customer_name, bill_to_customer_id, customer_category_id, primary_contact_person_id, alternate_contact_person_id, delivery_method_id, delivery_city_id, postal_city_id, credit_limit, account_opened_date, standard_discount_percentage, is_statement_sent, is_on_credit_hold, payment_days, phone_number, fax_number, website_url, delivery_address_line_1, delivery_postal_code, postal_address_line_1, postal_postal_code) VALUES
('Tailspin Toys (Head Office)', 1, 3, 6, 7, 3, 19586, 19586, 2000.00, '2013-01-01', 0.000, true, false, 7, '(425) 555-5555', '(425) 555-5556', 'http://www.tailspintoys.com', 'Shop 38', '90410', 'PO Box 8975', '90410'),
('Wingtip Toys', 2, 3, 8, 9, 3, 19586, 19586, 2000.00, '2013-01-01', 0.000, true, false, 7, '(425) 555-5557', '(425) 555-5558', 'http://www.wingtiptoys.com', 'Unit 6', '90410', 'PO Box 7949', '90410'),
('Contoso, Ltd.', 3, 4, 10, null, 3, 19586, 19586, 5000.00, '2013-01-01', 0.000, true, false, 30, '(425) 555-5559', '(425) 555-5560', 'http://www.contoso.com', '1877 Fort Street', '90410', 'PO Box 555', '90410');

-- Insert sample data for Orders
INSERT INTO orders (customer_id, salesperson_person_id, contact_person_id, order_date, expected_delivery_date, customer_purchase_order_number, is_undersupply_backordered) VALUES
(1, 3, 6, '2016-01-01', '2016-01-02', 'PO-18947', false),
(2, 4, 8, '2016-01-01', '2016-01-02', 'PO-18948', false),
(3, 3, 10, '2016-01-01', '2016-01-03', 'PO-18949', false),
(1, 4, 6, '2016-01-02', '2016-01-03', 'PO-18950', false),
(2, 3, 8, '2016-01-02', '2016-01-03', 'PO-18951', false);

-- Insert sample data for Order Lines
INSERT INTO order_lines (order_id, stock_item_id, description, package_type_id, quantity, unit_price, tax_rate, picked_quantity) VALUES
(1, 1, 'USB missile launcher (Green)', 7, 2, 8.00, 15.000, 2),
(1, 2, 'USB rocket launcher (Gray)', 7, 1, 8.00, 15.000, 1),
(2, 3, 'The Gu red shirt XML tag t-shirt (White) 3XL', 7, 5, 18.00, 15.000, 5),
(3, 4, 'DBA joke mug (White)', 7, 10, 13.00, 15.000, 10),
(4, 5, 'Smartphone holder (Black)', 7, 3, 18.00, 15.000, 3),
(5, 6, 'Air cushion film (Blue)', 7, 20, 2.50, 15.000, 20);

-- Grant permissions to vscode user
GRANT ALL PRIVILEGES ON SCHEMA wwi TO student;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA wwi TO student;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA wwi TO student;

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
