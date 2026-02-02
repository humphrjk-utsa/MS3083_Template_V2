-- Sakila Database - DVD Rental Store
-- Based on the classic Sakila sample database

-- Create schema
CREATE SCHEMA IF NOT EXISTS sakila;
SET search_path TO sakila, public;

-- Category table
CREATE TABLE category (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(25) NOT NULL,
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Language table
CREATE TABLE language (
    language_id SERIAL PRIMARY KEY,
    name CHAR(20) NOT NULL,
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Actor table
CREATE TABLE actor (
    actor_id SERIAL PRIMARY KEY,
    first_name VARCHAR(45) NOT NULL,
    last_name VARCHAR(45) NOT NULL,
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Film table
CREATE TABLE film (
    film_id SERIAL PRIMARY KEY,
    title VARCHAR(128) NOT NULL,
    description TEXT,
    release_year SMALLINT,
    language_id INTEGER NOT NULL REFERENCES language(language_id),
    original_language_id INTEGER REFERENCES language(language_id),
    rental_duration SMALLINT NOT NULL DEFAULT 3,
    rental_rate DECIMAL(4,2) NOT NULL DEFAULT 4.99,
    length SMALLINT,
    replacement_cost DECIMAL(5,2) NOT NULL DEFAULT 19.99,
    rating VARCHAR(10) DEFAULT 'G',
    special_features TEXT,
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Film-Actor junction table
CREATE TABLE film_actor (
    actor_id INTEGER NOT NULL REFERENCES actor(actor_id),
    film_id INTEGER NOT NULL REFERENCES film(film_id),
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (actor_id, film_id)
);

-- Film-Category junction table
CREATE TABLE film_category (
    film_id INTEGER NOT NULL REFERENCES film(film_id),
    category_id INTEGER NOT NULL REFERENCES category(category_id),
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (film_id, category_id)
);

-- Country table
CREATE TABLE country (
    country_id SERIAL PRIMARY KEY,
    country VARCHAR(50) NOT NULL,
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- City table
CREATE TABLE city (
    city_id SERIAL PRIMARY KEY,
    city VARCHAR(50) NOT NULL,
    country_id INTEGER NOT NULL REFERENCES country(country_id),
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Address table
CREATE TABLE address (
    address_id SERIAL PRIMARY KEY,
    address VARCHAR(50) NOT NULL,
    address2 VARCHAR(50),
    district VARCHAR(20) NOT NULL,
    city_id INTEGER NOT NULL REFERENCES city(city_id),
    postal_code VARCHAR(10),
    phone VARCHAR(20) NOT NULL,
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Staff table
CREATE TABLE staff (
    staff_id SERIAL PRIMARY KEY,
    first_name VARCHAR(45) NOT NULL,
    last_name VARCHAR(45) NOT NULL,
    address_id INTEGER NOT NULL REFERENCES address(address_id),
    picture BYTEA,
    email VARCHAR(50),
    store_id INTEGER NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    username VARCHAR(16) NOT NULL,
    password VARCHAR(40),
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Store table
CREATE TABLE store (
    store_id SERIAL PRIMARY KEY,
    manager_staff_id INTEGER NOT NULL REFERENCES staff(staff_id),
    address_id INTEGER NOT NULL REFERENCES address(address_id),
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Add store_id FK to staff after store table is created
ALTER TABLE staff ADD CONSTRAINT fk_staff_store 
    FOREIGN KEY (store_id) REFERENCES store(store_id);

-- Customer table
CREATE TABLE customer (
    customer_id SERIAL PRIMARY KEY,
    store_id INTEGER NOT NULL REFERENCES store(store_id),
    first_name VARCHAR(45) NOT NULL,
    last_name VARCHAR(45) NOT NULL,
    email VARCHAR(50),
    address_id INTEGER NOT NULL REFERENCES address(address_id),
    active BOOLEAN NOT NULL DEFAULT TRUE,
    create_date DATE NOT NULL DEFAULT CURRENT_DATE,
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Inventory table
CREATE TABLE inventory (
    inventory_id SERIAL PRIMARY KEY,
    film_id INTEGER NOT NULL REFERENCES film(film_id),
    store_id INTEGER NOT NULL REFERENCES store(store_id),
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Rental table
CREATE TABLE rental (
    rental_id SERIAL PRIMARY KEY,
    rental_date TIMESTAMP NOT NULL,
    inventory_id INTEGER NOT NULL REFERENCES inventory(inventory_id),
    customer_id INTEGER NOT NULL REFERENCES customer(customer_id),
    return_date TIMESTAMP,
    staff_id INTEGER NOT NULL REFERENCES staff(staff_id),
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Payment table
CREATE TABLE payment (
    payment_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customer(customer_id),
    staff_id INTEGER NOT NULL REFERENCES staff(staff_id),
    rental_id INTEGER NOT NULL REFERENCES rental(rental_id),
    amount DECIMAL(5,2) NOT NULL,
    payment_date TIMESTAMP NOT NULL,
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Sample Data

-- Insert Languages
INSERT INTO language (name) VALUES 
    ('English'),
    ('Italian'),
    ('Japanese'),
    ('Mandarin'),
    ('French'),
    ('German'),
    ('Spanish');

-- Insert Categories
INSERT INTO category (name) VALUES 
    ('Action'),
    ('Animation'),
    ('Children'),
    ('Classics'),
    ('Comedy'),
    ('Documentary'),
    ('Drama'),
    ('Family'),
    ('Foreign'),
    ('Games'),
    ('Horror'),
    ('Music'),
    ('New'),
    ('Sci-Fi'),
    ('Sports'),
    ('Travel');

-- Insert Actors
INSERT INTO actor (first_name, last_name) VALUES 
    ('PENELOPE', 'GUINESS'),
    ('NICK', 'WAHLBERG'),
    ('ED', 'CHASE'),
    ('JENNIFER', 'DAVIS'),
    ('JOHNNY', 'LOLLOBRIGIDA'),
    ('BETTE', 'NICHOLSON'),
    ('GRACE', 'MOSTEL'),
    ('MATTHEW', 'JOHANSSON'),
    ('JOE', 'SWANK'),
    ('CHRISTIAN', 'GABLE');

-- Insert Countries
INSERT INTO country (country) VALUES 
    ('United States'),
    ('Canada'),
    ('Mexico'),
    ('United Kingdom'),
    ('France'),
    ('Germany'),
    ('Italy'),
    ('Spain'),
    ('Australia'),
    ('Japan');

-- Insert Cities
INSERT INTO city (city, country_id) VALUES 
    ('New York', 1),
    ('Los Angeles', 1),
    ('Toronto', 2),
    ('London', 4),
    ('Paris', 5),
    ('Berlin', 6),
    ('Rome', 7),
    ('Madrid', 8),
    ('Sydney', 9),
    ('Tokyo', 10);

-- Insert Addresses
INSERT INTO address (address, district, city_id, postal_code, phone) VALUES 
    ('123 Main St', 'Manhattan', 1, '10001', '555-1234'),
    ('456 Oak Ave', 'Hollywood', 2, '90210', '555-5678'),
    ('789 Maple Dr', 'Downtown', 3, 'M5V 3A1', '555-9876'),
    ('321 Baker St', 'Westminster', 4, 'SW1A 1AA', '555-4321'),
    ('654 Champs Elysees', 'Paris Center', 5, '75001', '555-8765'),
    ('987 Brandenburg', 'Mitte', 6, '10115', '555-2468'),
    ('147 Via Roma', 'Centro', 7, '00118', '555-1357'),
    ('258 Gran Via', 'Centro', 8, '28013', '555-9753'),
    ('369 George St', 'CBD', 9, '2000', '555-8642'),
    ('741 Shibuya', 'Shibuya', 10, '150-0002', '555-7531');

-- Insert Stores
INSERT INTO store (manager_staff_id, address_id) VALUES 
    (1, 1),
    (2, 2);

-- Insert Staff
INSERT INTO staff (first_name, last_name, address_id, email, store_id, username, password) VALUES 
    ('Mike', 'Hillyer', 1, 'mike@sakilastore.com', 1, 'mike', 'password123'),
    ('Jon', 'Stephens', 2, 'jon@sakilastore.com', 2, 'jon', 'password456');

-- Insert Films
INSERT INTO film (title, description, release_year, language_id, rental_duration, rental_rate, length, replacement_cost, rating) VALUES 
    ('ACADEMY DINOSAUR', 'A Epic Drama of a Feminist And a Mad Scientist who must Battle a Teacher in The Canadian Rockies', 2006, 1, 6, 0.99, 86, 20.99, 'PG'),
    ('ACE GOLDFINGER', 'A Astounding Epistle of a Database Administrator And a Explorer who must Find a Car in Ancient China', 2006, 1, 3, 4.99, 48, 12.99, 'G'),
    ('ADAPTATION HOLES', 'A Astounding Reflection of a Lumberjack And a Car who must Sink a Lumberjack in A Baloon Factory', 2006, 1, 7, 2.99, 50, 18.99, 'NC-17'),
    ('AFFAIR PREJUDICE', 'A Fanciful Documentary of a Frisbee And a Lumberjack who must Chase a Monkey in A Shark Tank', 2006, 1, 5, 2.99, 117, 26.99, 'G'),
    ('AFRICAN EGG', 'A Fast-Paced Documentary of a Pastry Chef And a Dentist who must Pursue a Forensic Psychologist in The Gulf of Mexico', 2006, 1, 6, 2.99, 130, 22.99, 'G'),
    ('AGENT TRUMAN', 'A Intrepid Panorama of a Robot And a Boy who must Escape a Sumo Wrestler in Ancient China', 2006, 1, 3, 2.99, 169, 17.99, 'PG'),
    ('AIRPLANE SIERRA', 'A Touching Saga of a Hunter And a Butler who must Discover a Butler in A Jet Boat', 2006, 1, 6, 4.99, 62, 28.99, 'PG-13'),
    ('AIRPORT POLLOCK', 'A Epic Tale of a Moose And a Girl who must Confront a Monkey in Ancient India', 2006, 1, 6, 4.99, 54, 15.99, 'R'),
    ('ALABAMA DEVIL', 'A Thoughtful Panorama of a Database Administrator And a Mad Scientist who must Outgun a Mad Scientist in A Jet Boat', 2006, 1, 3, 2.99, 114, 21.99, 'PG-13'),
    ('ALADDIN CALENDAR', 'A Action-Packed Tale of a Man And a Lumberjack who must Reach a Feminist in Ancient China', 2006, 1, 6, 4.99, 63, 24.99, 'NC-17');

-- Insert Customers
INSERT INTO customer (store_id, first_name, last_name, email, address_id) VALUES 
    (1, 'MARY', 'SMITH', 'mary.smith@sakilacustomer.org', 1),
    (1, 'PATRICIA', 'JOHNSON', 'patricia.johnson@sakilacustomer.org', 2),
    (1, 'LINDA', 'WILLIAMS', 'linda.williams@sakilacustomer.org', 3),
    (2, 'BARBARA', 'JONES', 'barbara.jones@sakilacustomer.org', 4),
    (2, 'ELIZABETH', 'BROWN', 'elizabeth.brown@sakilacustomer.org', 5),
    (2, 'JENNIFER', 'DAVIS', 'jennifer.davis@sakilacustomer.org', 6),
    (1, 'MARIA', 'MILLER', 'maria.miller@sakilacustomer.org', 7),
    (1, 'SUSAN', 'WILSON', 'susan.wilson@sakilacustomer.org', 8),
    (2, 'MARGARET', 'MOORE', 'margaret.moore@sakilacustomer.org', 9),
    (2, 'DOROTHY', 'TAYLOR', 'dorothy.taylor@sakilacustomer.org', 10);

-- Insert Inventory
INSERT INTO inventory (film_id, store_id) VALUES 
    (1, 1), (1, 1), (1, 2), (1, 2),
    (2, 1), (2, 2), (2, 2),
    (3, 1), (3, 1), (3, 2),
    (4, 1), (4, 2), (4, 2),
    (5, 1), (5, 1), (5, 2);

-- Insert Film-Actor relationships
INSERT INTO film_actor (actor_id, film_id) VALUES 
    (1, 1), (1, 2), (1, 3),
    (2, 1), (2, 4), (2, 5),
    (3, 2), (3, 3), (3, 4),
    (4, 1), (4, 5), (4, 6),
    (5, 2), (5, 3), (5, 7);

-- Insert Film-Category relationships
INSERT INTO film_category (film_id, category_id) VALUES 
    (1, 1), (1, 7),
    (2, 1), (2, 14),
    (3, 7), (3, 11),
    (4, 6), (4, 7),
    (5, 6), (5, 16);

-- Insert Rentals
INSERT INTO rental (rental_date, inventory_id, customer_id, staff_id) VALUES 
    ('2023-01-01 10:00:00', 1, 1, 1),
    ('2023-01-01 14:30:00', 5, 2, 1),
    ('2023-01-02 09:15:00', 8, 3, 1),
    ('2023-01-02 16:45:00', 11, 4, 2),
    ('2023-01-03 11:20:00', 14, 5, 2);

-- Insert Payments
INSERT INTO payment (customer_id, staff_id, rental_id, amount, payment_date) VALUES 
    (1, 1, 1, 2.99, '2023-01-01 10:00:00'),
    (2, 1, 2, 4.99, '2023-01-01 14:30:00'),
    (3, 1, 3, 2.99, '2023-01-02 09:15:00'),
    (4, 2, 4, 2.99, '2023-01-02 16:45:00'),
    (5, 2, 5, 2.99, '2023-01-03 11:20:00');

-- Grant permissions
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA sakila TO vscode;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA sakila TO vscode;

-- Display summary
SELECT 'Sakila database loaded successfully!' as status;

-- Create useful views
CREATE VIEW film_list AS
SELECT f.film_id, f.title, f.description, 
       c.name as category, f.rental_rate, f.length, f.rating,
       string_agg(a.first_name || ' ' || a.last_name, ', ') as actors
FROM film f
LEFT JOIN film_category fc ON f.film_id = fc.film_id
LEFT JOIN category c ON fc.category_id = c.category_id
LEFT JOIN film_actor fa ON f.film_id = fa.film_id
LEFT JOIN actor a ON fa.actor_id = a.actor_id
GROUP BY f.film_id, f.title, f.description, c.name, f.rental_rate, f.length, f.rating;

CREATE VIEW customer_list AS
SELECT c.customer_id, c.first_name, c.last_name, c.email,
       a.address, a.postal_code, a.phone, ci.city, co.country
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id;

GRANT SELECT ON film_list TO vscode;
GRANT SELECT ON customer_list TO vscode;
