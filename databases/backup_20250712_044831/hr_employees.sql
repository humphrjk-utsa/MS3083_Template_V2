-- Employees Database - HR and Hierarchical Data
-- Common HR database for learning SQL with hierarchical queries

-- Create schema
CREATE SCHEMA IF NOT EXISTS hr;
SET search_path TO hr, public;

-- Departments table
CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(30) NOT NULL,
    manager_id INTEGER,
    location_id INTEGER
);

-- Locations table
CREATE TABLE locations (
    location_id SERIAL PRIMARY KEY,
    street_address VARCHAR(40),
    postal_code VARCHAR(12),
    city VARCHAR(30) NOT NULL,
    state_province VARCHAR(25),
    country_id CHAR(2)
);

-- Countries table
CREATE TABLE countries (
    country_id CHAR(2) PRIMARY KEY,
    country_name VARCHAR(40),
    region_id INTEGER
);

-- Regions table
CREATE TABLE regions (
    region_id SERIAL PRIMARY KEY,
    region_name VARCHAR(25)
);

-- Job titles table
CREATE TABLE jobs (
    job_id VARCHAR(10) PRIMARY KEY,
    job_title VARCHAR(35) NOT NULL,
    min_salary INTEGER,
    max_salary INTEGER
);

-- Employees table
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(20),
    last_name VARCHAR(25) NOT NULL,
    email VARCHAR(25) NOT NULL UNIQUE,
    phone_number VARCHAR(20),
    hire_date DATE NOT NULL,
    job_id VARCHAR(10) NOT NULL REFERENCES jobs(job_id),
    salary DECIMAL(8,2),
    commission_pct DECIMAL(2,2),
    manager_id INTEGER REFERENCES employees(employee_id),
    department_id INTEGER REFERENCES departments(department_id)
);

-- Job history table
CREATE TABLE job_history (
    employee_id INTEGER NOT NULL REFERENCES employees(employee_id),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    job_id VARCHAR(10) NOT NULL REFERENCES jobs(job_id),
    department_id INTEGER REFERENCES departments(department_id),
    PRIMARY KEY (employee_id, start_date)
);

-- Add foreign key constraints
ALTER TABLE departments ADD CONSTRAINT fk_dept_manager 
    FOREIGN KEY (manager_id) REFERENCES employees(employee_id);

ALTER TABLE locations ADD CONSTRAINT fk_loc_country 
    FOREIGN KEY (country_id) REFERENCES countries(country_id);

ALTER TABLE countries ADD CONSTRAINT fk_country_region 
    FOREIGN KEY (region_id) REFERENCES regions(region_id);

ALTER TABLE departments ADD CONSTRAINT fk_dept_location 
    FOREIGN KEY (location_id) REFERENCES locations(location_id);

-- Sample Data

-- Insert Regions
INSERT INTO regions (region_name) VALUES 
    ('North America'),
    ('Europe'),
    ('Asia'),
    ('South America');

-- Insert Countries
INSERT INTO countries (country_id, country_name, region_id) VALUES 
    ('US', 'United States', 1),
    ('CA', 'Canada', 1),
    ('UK', 'United Kingdom', 2),
    ('DE', 'Germany', 2),
    ('FR', 'France', 2),
    ('JP', 'Japan', 3),
    ('CN', 'China', 3),
    ('BR', 'Brazil', 4),
    ('MX', 'Mexico', 1),
    ('AU', 'Australia', 3);

-- Insert Locations
INSERT INTO locations (street_address, postal_code, city, state_province, country_id) VALUES 
    ('1297 Via Cola di Rie', '00989', 'Roma', NULL, 'IT'),
    ('93091 Calle della Testa', '10934', 'Venice', NULL, 'IT'),
    ('2017 Shinjuku-ku', '1689', 'Tokyo', 'Tokyo Prefecture', 'JP'),
    ('9450 Kamiya-cho', '6823', 'Hiroshima', NULL, 'JP'),
    ('2014 Jabberwocky Rd', '26192', 'Southlake', 'Texas', 'US'),
    ('2011 Interiors Blvd', '99236', 'South San Francisco', 'California', 'US'),
    ('2007 Zagora St', '50090', 'South Brunswick', 'New Jersey', 'US'),
    ('2004 Charade Rd', '98199', 'Seattle', 'Washington', 'US'),
    ('147 Spadina Ave', 'M5V 2L7', 'Toronto', 'Ontario', 'CA'),
    ('6092 Boxwood St', 'YSW 9T2', 'Whitehorse', 'Yukon', 'CA'),
    ('40-5-12 Laogianggen', '190518', 'Beijing', NULL, 'CN'),
    ('1298 Vileparle (E)', '490231', 'Bombay', 'Maharashtra', 'IN'),
    ('12-98 Victoria Street', '2901', 'Sydney', 'New South Wales', 'AU'),
    ('198 Clementi North', '540198', 'Singapore', NULL, 'SG'),
    ('8204 Arthur St', NULL, 'London', NULL, 'UK'),
    ('Magdalen Centre, The Oxford Science Park', 'OX9 9ZB', 'Oxford', 'Oxford', 'UK'),
    ('9702 Chester Road', '09629850293', 'Stretford', 'Manchester', 'UK'),
    ('Schwanthalerstr. 7031', '80925', 'Munich', 'Bavaria', 'DE'),
    ('Rua Frei Caneca 1360', '01307-002', 'Sao Paulo', 'Sao Paulo', 'BR'),
    ('20 Rue des Corps-Saints', '1730', 'Geneva', 'Geneve', 'CH'),
    ('Murtenstrasse 921', '3095', 'Bern', 'BE', 'CH'),
    ('Pieter Breughelstraat 837', '3029SK', 'Utrecht', 'Utrecht', 'NL'),
    ('Mariano Escobedo 9991', '11932', 'Mexico City', 'Distrito Federal', 'MX');

-- Insert Jobs
INSERT INTO jobs (job_id, job_title, min_salary, max_salary) VALUES 
    ('AD_PRES', 'President', 20000, 40000),
    ('AD_VP', 'Vice President', 15000, 30000),
    ('AD_ASST', 'Administration Assistant', 3000, 6000),
    ('FI_MGR', 'Finance Manager', 8200, 16000),
    ('FI_ACCOUNT', 'Accountant', 4200, 9000),
    ('AC_MGR', 'Accounting Manager', 8200, 16000),
    ('AC_ACCOUNT', 'Public Accountant', 4200, 9000),
    ('SA_MAN', 'Sales Manager', 10000, 20000),
    ('SA_REP', 'Sales Representative', 6000, 12000),
    ('PU_MAN', 'Purchasing Manager', 8000, 15000),
    ('PU_CLERK', 'Purchasing Clerk', 2500, 5500),
    ('ST_MAN', 'Stock Manager', 5500, 8500),
    ('ST_CLERK', 'Stock Clerk', 2000, 5000),
    ('SH_CLERK', 'Shipping Clerk', 2500, 5500),
    ('IT_PROG', 'Programmer', 4000, 10000),
    ('MK_MAN', 'Marketing Manager', 9000, 15000),
    ('MK_REP', 'Marketing Representative', 4000, 9000),
    ('HR_REP', 'Human Resources Representative', 4000, 9000),
    ('PR_REP', 'Public Relations Representative', 4500, 10500);

-- Insert Employees
INSERT INTO employees (employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, commission_pct, manager_id, department_id) VALUES 
    (100, 'Steven', 'King', 'SKING', '515.123.4567', '1987-06-17', 'AD_PRES', 24000, NULL, NULL, 90),
    (101, 'Neena', 'Kochhar', 'NKOCHHAR', '515.123.4568', '1989-09-21', 'AD_VP', 17000, NULL, 100, 90),
    (102, 'Lex', 'De Haan', 'LDEHAAN', '515.123.4569', '1993-01-13', 'AD_VP', 17000, NULL, 100, 90),
    (103, 'Alexander', 'Hunold', 'AHUNOLD', '590.423.4567', '1990-01-03', 'IT_PROG', 9000, NULL, 102, 60),
    (104, 'Bruce', 'Ernst', 'BERNST', '590.423.4568', '1991-05-21', 'IT_PROG', 6000, NULL, 103, 60),
    (105, 'David', 'Austin', 'DAUSTIN', '590.423.4569', '1997-06-25', 'IT_PROG', 4800, NULL, 103, 60),
    (106, 'Valli', 'Pataballa', 'VPATABAL', '590.423.4560', '1998-02-05', 'IT_PROG', 4800, NULL, 103, 60),
    (107, 'Diana', 'Lorentz', 'DLORENTZ', '590.423.5567', '1999-02-07', 'IT_PROG', 4200, NULL, 103, 60),
    (108, 'Nancy', 'Greenberg', 'NGREENBE', '515.124.4569', '1994-08-17', 'FI_MGR', 12000, NULL, 101, 100),
    (109, 'Daniel', 'Faviet', 'DFAVIET', '515.124.4169', '1994-08-16', 'FI_ACCOUNT', 9000, NULL, 108, 100),
    (110, 'John', 'Chen', 'JCHEN', '515.124.4269', '1997-09-28', 'FI_ACCOUNT', 8200, NULL, 108, 100),
    (111, 'Ismael', 'Sciarra', 'ISCIARRA', '515.124.4369', '1997-09-30', 'FI_ACCOUNT', 7700, NULL, 108, 100),
    (112, 'Jose Manuel', 'Urman', 'JMURMAN', '515.124.4469', '1998-03-07', 'FI_ACCOUNT', 7800, NULL, 108, 100),
    (113, 'Luis', 'Popp', 'LPOPP', '515.124.4567', '1999-12-07', 'FI_ACCOUNT', 6900, NULL, 108, 100),
    (114, 'Den', 'Raphaely', 'DRAPHEAL', '515.127.4561', '1994-12-07', 'PU_MAN', 11000, NULL, 100, 30),
    (115, 'Alexander', 'Khoo', 'AKHOO', '515.127.4562', '1995-05-18', 'PU_CLERK', 3100, NULL, 114, 30),
    (116, 'Shelli', 'Baida', 'SBAIDA', '515.127.4563', '1997-12-24', 'PU_CLERK', 2900, NULL, 114, 30),
    (117, 'Sigal', 'Tobias', 'STOBIAS', '515.127.4564', '1997-07-24', 'PU_CLERK', 2800, NULL, 114, 30),
    (118, 'Guy', 'Himuro', 'GHIMURO', '515.127.4565', '1998-11-15', 'PU_CLERK', 2600, NULL, 114, 30),
    (119, 'Karen', 'Colmenares', 'KCOLMENA', '515.127.4566', '1999-08-10', 'PU_CLERK', 2500, NULL, 114, 30),
    (120, 'Matthew', 'Weiss', 'MWEISS', '650.123.1234', '1996-07-18', 'ST_MAN', 8000, NULL, 100, 50),
    (121, 'Adam', 'Fripp', 'AFRIPP', '650.123.2234', '1997-04-10', 'ST_MAN', 8200, NULL, 100, 50),
    (122, 'Payam', 'Kaufling', 'PKAUFLIN', '650.123.3234', '1995-05-01', 'ST_MAN', 7900, NULL, 100, 50),
    (123, 'Shanta', 'Vollman', 'SVOLLMAN', '650.123.4234', '1997-10-10', 'ST_MAN', 6500, NULL, 100, 50),
    (124, 'Kevin', 'Mourgos', 'KMOURGOS', '650.123.5234', '1999-11-16', 'ST_MAN', 5800, NULL, 100, 50);

-- Insert Departments
INSERT INTO departments (department_id, department_name, manager_id, location_id) VALUES 
    (10, 'Administration', 200, 1700),
    (20, 'Marketing', 201, 1800),
    (30, 'Purchasing', 114, 1700),
    (40, 'Human Resources', 203, 2400),
    (50, 'Shipping', 121, 1500),
    (60, 'IT', 103, 1400),
    (70, 'Public Relations', 204, 2700),
    (80, 'Sales', 145, 2500),
    (90, 'Executive', 100, 1700),
    (100, 'Finance', 108, 1700),
    (110, 'Accounting', 205, 1700),
    (120, 'Treasury', NULL, 1700),
    (130, 'Corporate Tax', NULL, 1700),
    (140, 'Control And Credit', NULL, 1700),
    (150, 'Shareholder Services', NULL, 1700),
    (160, 'Benefits', NULL, 1700),
    (170, 'Manufacturing', NULL, 1700),
    (180, 'Construction', NULL, 1700),
    (190, 'Contracting', NULL, 1700),
    (200, 'Operations', NULL, 1700),
    (210, 'IT Support', NULL, 1700),
    (220, 'NOC', NULL, 1700),
    (230, 'IT Helpdesk', NULL, 1700),
    (240, 'Government Sales', NULL, 1700),
    (250, 'Retail Sales', NULL, 1700),
    (260, 'Recruiting', NULL, 1700),
    (270, 'Payroll', NULL, 1700);

-- Insert Job History
INSERT INTO job_history (employee_id, start_date, end_date, job_id, department_id) VALUES 
    (102, '1993-01-13', '1998-07-24', 'IT_PROG', 60),
    (101, '1989-09-21', '1993-10-27', 'AC_ACCOUNT', 110),
    (101, '1993-10-28', '1997-03-15', 'AC_MGR', 110),
    (201, '1996-02-17', '1999-12-19', 'MK_REP', 20),
    (114, '1998-03-24', '1999-12-31', 'ST_CLERK', 50),
    (122, '1999-01-01', '1999-12-31', 'ST_CLERK', 50),
    (200, '1987-09-17', '1993-06-17', 'AD_ASST', 90),
    (176, '1998-03-24', '1998-12-31', 'SA_REP', 80),
    (176, '1999-01-01', '1999-12-31', 'SA_MAN', 80),
    (200, '1994-07-01', '1998-12-31', 'AC_ACCOUNT', 90);

-- Grant permissions
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA hr TO vscode;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA hr TO vscode;

-- Create useful views for learning
CREATE VIEW employee_details AS
SELECT e.employee_id, e.first_name, e.last_name, e.email, e.phone_number,
       e.hire_date, j.job_title, e.salary, e.commission_pct,
       m.first_name || ' ' || m.last_name as manager_name,
       d.department_name, l.city, c.country_name, r.region_name
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.employee_id
LEFT JOIN jobs j ON e.job_id = j.job_id
LEFT JOIN departments d ON e.department_id = d.department_id
LEFT JOIN locations l ON d.location_id = l.location_id
LEFT JOIN countries c ON l.country_id = c.country_id
LEFT JOIN regions r ON c.region_id = r.region_id;

CREATE VIEW department_summary AS
SELECT d.department_id, d.department_name,
       COUNT(e.employee_id) as employee_count,
       AVG(e.salary) as avg_salary,
       MAX(e.salary) as max_salary,
       MIN(e.salary) as min_salary,
       l.city, c.country_name
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
LEFT JOIN locations l ON d.location_id = l.location_id
LEFT JOIN countries c ON l.country_id = c.country_id
GROUP BY d.department_id, d.department_name, l.city, c.country_name;

GRANT SELECT ON employee_details TO vscode;
GRANT SELECT ON department_summary TO vscode;

-- Display summary
SELECT 'HR database loaded successfully!' as status;
