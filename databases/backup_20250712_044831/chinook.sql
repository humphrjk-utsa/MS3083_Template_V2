-- Chinook Database - Digital Music Store
-- Based on iTunes Store data model

-- Create schema
CREATE SCHEMA IF NOT EXISTS chinook;
SET search_path TO chinook, public;

-- Artist table
CREATE TABLE artist (
    artist_id SERIAL PRIMARY KEY,
    name VARCHAR(120) NOT NULL
);

-- Album table
CREATE TABLE album (
    album_id SERIAL PRIMARY KEY,
    title VARCHAR(160) NOT NULL,
    artist_id INTEGER NOT NULL REFERENCES artist(artist_id)
);

-- MediaType table
CREATE TABLE media_type (
    media_type_id SERIAL PRIMARY KEY,
    name VARCHAR(120)
);

-- Genre table
CREATE TABLE genre (
    genre_id SERIAL PRIMARY KEY,
    name VARCHAR(120)
);

-- Track table
CREATE TABLE track (
    track_id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    album_id INTEGER REFERENCES album(album_id),
    media_type_id INTEGER NOT NULL REFERENCES media_type(media_type_id),
    genre_id INTEGER REFERENCES genre(genre_id),
    composer VARCHAR(220),
    milliseconds INTEGER NOT NULL,
    bytes INTEGER,
    unit_price DECIMAL(10,2) NOT NULL
);

-- Customer table
CREATE TABLE customer (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(40) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
    company VARCHAR(80),
    address VARCHAR(70),
    city VARCHAR(40),
    state VARCHAR(40),
    country VARCHAR(40),
    postal_code VARCHAR(10),
    phone VARCHAR(24),
    fax VARCHAR(24),
    email VARCHAR(60) NOT NULL,
    support_rep_id INTEGER
);

-- Employee table
CREATE TABLE employee (
    employee_id SERIAL PRIMARY KEY,
    last_name VARCHAR(20) NOT NULL,
    first_name VARCHAR(20) NOT NULL,
    title VARCHAR(30),
    reports_to INTEGER REFERENCES employee(employee_id),
    birth_date TIMESTAMP,
    hire_date TIMESTAMP,
    address VARCHAR(70),
    city VARCHAR(40),
    state VARCHAR(40),
    country VARCHAR(40),
    postal_code VARCHAR(10),
    phone VARCHAR(24),
    fax VARCHAR(24),
    email VARCHAR(60)
);

-- Add foreign key for customer support rep
ALTER TABLE customer ADD CONSTRAINT fk_customer_support_rep 
    FOREIGN KEY (support_rep_id) REFERENCES employee(employee_id);

-- Invoice table
CREATE TABLE invoice (
    invoice_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customer(customer_id),
    invoice_date TIMESTAMP NOT NULL,
    billing_address VARCHAR(70),
    billing_city VARCHAR(40),
    billing_state VARCHAR(40),
    billing_country VARCHAR(40),
    billing_postal_code VARCHAR(10),
    total DECIMAL(10,2) NOT NULL
);

-- InvoiceLine table
CREATE TABLE invoice_line (
    invoice_line_id SERIAL PRIMARY KEY,
    invoice_id INTEGER NOT NULL REFERENCES invoice(invoice_id),
    track_id INTEGER NOT NULL REFERENCES track(track_id),
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INTEGER NOT NULL
);

-- Playlist table
CREATE TABLE playlist (
    playlist_id SERIAL PRIMARY KEY,
    name VARCHAR(120)
);

-- PlaylistTrack table
CREATE TABLE playlist_track (
    playlist_id INTEGER NOT NULL REFERENCES playlist(playlist_id),
    track_id INTEGER NOT NULL REFERENCES track(track_id),
    PRIMARY KEY (playlist_id, track_id)
);

-- Sample Data

-- Insert Artists
INSERT INTO artist (name) VALUES 
    ('AC/DC'),
    ('Accept'),
    ('Aerosmith'),
    ('Alanis Morissette'),
    ('Alice In Chains'),
    ('Antônio Carlos Jobim'),
    ('Apocalyptica'),
    ('Audioslave'),
    ('BackBeat'),
    ('The Beatles');

-- Insert Albums
INSERT INTO album (title, artist_id) VALUES 
    ('For Those About To Rock We Salute You', 1),
    ('Balls to the Wall', 2),
    ('Restless and Wild', 2),
    ('Let There Be Rock', 1),
    ('Big Ones', 3),
    ('Jagged Little Pill', 4),
    ('Facelift', 5),
    ('Warner 25 Anos', 6),
    ('Plays Metallica By Four Cellos', 7),
    ('Audioslave', 8);

-- Insert Media Types
INSERT INTO media_type (name) VALUES 
    ('MPEG audio file'),
    ('Protected AAC audio file'),
    ('Protected MPEG-4 video file'),
    ('Purchased AAC audio file'),
    ('AAC audio file');

-- Insert Genres
INSERT INTO genre (name) VALUES 
    ('Rock'),
    ('Jazz'),
    ('Metal'),
    ('Alternative & Punk'),
    ('Rock And Roll'),
    ('Blues'),
    ('Latin'),
    ('Reggae'),
    ('Pop'),
    ('Soundtrack');

-- Insert Tracks
INSERT INTO track (name, album_id, media_type_id, genre_id, composer, milliseconds, bytes, unit_price) VALUES 
    ('For Those About To Rock (We Salute You)', 1, 1, 1, 'Angus Young, Malcolm Young, Brian Johnson', 343719, 11170334, 0.99),
    ('Balls to the Wall', 2, 2, 1, NULL, 342562, 5510424, 0.99),
    ('Fast As a Shark', 3, 2, 1, 'F. Baltes, S. Kaufman, U. Dirkscneider & W. Hoffmann', 230619, 3990994, 0.99),
    ('Restless and Wild', 3, 2, 1, 'F. Baltes, R.A. Smith-Diesel, S. Kaufman, U. Dirkscneider & W. Hoffmann', 252051, 4331779, 0.99),
    ('Princess of the Dawn', 3, 2, 1, 'Deaffy & R.A. Smith-Diesel', 375418, 6290521, 0.99),
    ('Put The Finger On You', 1, 1, 1, 'Angus Young, Malcolm Young, Brian Johnson', 205662, 6713451, 0.99),
    ('Let There Be Rock', 4, 1, 1, 'Angus Young, Malcolm Young, Bon Scott', 366654, 12021261, 0.99),
    ('Inject The Venom', 4, 1, 1, 'Angus Young, Malcolm Young, Brian Johnson', 210834, 6852860, 0.99),
    ('Snowballed', 4, 1, 1, 'Angus Young, Malcolm Young, Brian Johnson', 203102, 6599424, 0.99),
    ('Evil Walks', 4, 1, 1, 'Angus Young, Malcolm Young, Brian Johnson', 263497, 8611245, 0.99);

-- Insert Employees
INSERT INTO employee (last_name, first_name, title, reports_to, birth_date, hire_date, address, city, state, country, postal_code, phone, fax, email) VALUES 
    ('Adams', 'Andrew', 'General Manager', NULL, '1962-02-18 00:00:00', '2002-08-14 00:00:00', '11120 Jasper Ave NW', 'Edmonton', 'AB', 'Canada', 'T5K 2N1', '+1 (780) 428-9482', '+1 (780) 428-3457', 'andrew@chinookcorp.com'),
    ('Edwards', 'Nancy', 'Sales Manager', 1, '1958-12-08 00:00:00', '2002-05-01 00:00:00', '825 8 Ave SW', 'Calgary', 'AB', 'Canada', 'T2P 2T3', '+1 (403) 262-3443', '+1 (403) 262-3322', 'nancy@chinookcorp.com'),
    ('Peacock', 'Jane', 'Sales Support Agent', 2, '1973-08-29 00:00:00', '2002-04-01 00:00:00', '1111 6 Ave SW', 'Calgary', 'AB', 'Canada', 'T2P 5M5', '+1 (403) 262-3443', '+1 (403) 262-6712', 'jane@chinookcorp.com'),
    ('Park', 'Margaret', 'Sales Support Agent', 2, '1947-09-19 00:00:00', '2003-05-03 00:00:00', '683 10 Street SW', 'Calgary', 'AB', 'Canada', 'T2P 5G3', '+1 (403) 263-4423', '+1 (403) 263-4289', 'margaret@chinookcorp.com'),
    ('Johnson', 'Steve', 'Sales Support Agent', 2, '1965-03-03 00:00:00', '2003-10-17 00:00:00', '7727B 41 Ave', 'Calgary', 'AB', 'Canada', 'T3B 1Y7', '1 (780) 836-9987', '1 (780) 836-9543', 'steve@chinookcorp.com');

-- Insert Customers
INSERT INTO customer (first_name, last_name, company, address, city, state, country, postal_code, phone, fax, email, support_rep_id) VALUES 
    ('Luís', 'Gonçalves', 'Embraer - Empresa Brasileira de Aeronáutica S.A.', 'Av. Brigadeiro Faria Lima, 2170', 'São José dos Campos', 'SP', 'Brazil', '12227-000', '+55 (12) 3923-5555', '+55 (12) 3923-5566', 'luisg@embraer.com.br', 3),
    ('Leonie', 'Köhler', NULL, 'Theodor-Heuss-Straße 34', 'Stuttgart', NULL, 'Germany', '70174', '+49 0711 2842222', NULL, 'leonekohler@surfeu.de', 5),
    ('François', 'Tremblay', NULL, '1498 rue Bélanger', 'Montréal', 'QC', 'Canada', 'H2G 1A7', '+1 (514) 721-4711', NULL, 'ftremblay@gmail.com', 3),
    ('Bjørn', 'Hansen', NULL, 'Ullevålsveien 14', 'Oslo', NULL, 'Norway', '0171', '+47 22 44 22 22', NULL, 'bjorn.hansen@yahoo.no', 4),
    ('František', 'Wichterlová', 'JetBrains s.r.o.', 'Klanova 9/506', 'Prague', NULL, 'Czech Republic', '14700', '+420 2 4172 5555', '+420 2 4172 5555', 'frantisekw@jetbrains.com', 4);

-- Insert Invoices
INSERT INTO invoice (customer_id, invoice_date, billing_address, billing_city, billing_state, billing_country, billing_postal_code, total) VALUES 
    (1, '2009-01-01 00:00:00', 'Av. Brigadeiro Faria Lima, 2170', 'São José dos Campos', 'SP', 'Brazil', '12227-000', 1.98),
    (2, '2009-01-02 00:00:00', 'Theodor-Heuss-Straße 34', 'Stuttgart', NULL, 'Germany', '70174', 3.96),
    (3, '2009-01-03 00:00:00', '1498 rue Bélanger', 'Montréal', 'QC', 'Canada', 'H2G 1A7', 5.94),
    (4, '2009-01-06 00:00:00', 'Ullevålsveien 14', 'Oslo', NULL, 'Norway', '0171', 8.91),
    (5, '2009-01-11 00:00:00', 'Klanova 9/506', 'Prague', NULL, 'Czech Republic', '14700', 13.86);

-- Insert Invoice Lines
INSERT INTO invoice_line (invoice_id, track_id, unit_price, quantity) VALUES 
    (1, 1, 0.99, 1),
    (1, 2, 0.99, 1),
    (2, 3, 0.99, 1),
    (2, 4, 0.99, 1),
    (2, 5, 0.99, 1),
    (2, 6, 0.99, 1),
    (3, 7, 0.99, 1),
    (3, 8, 0.99, 1),
    (3, 9, 0.99, 1),
    (3, 10, 0.99, 1);

-- Insert Playlists
INSERT INTO playlist (name) VALUES 
    ('Music'),
    ('Movies'),
    ('TV Shows'),
    ('Audiobooks'),
    ('90's Music'),
    ('Audiobooks'),
    ('Movies'),
    ('Music'),
    ('Music Videos'),
    ('TV Shows');

-- Insert Playlist Tracks
INSERT INTO playlist_track (playlist_id, track_id) VALUES 
    (1, 1),
    (1, 2),
    (1, 3),
    (1, 4),
    (1, 5),
    (5, 1),
    (5, 2),
    (5, 3),
    (5, 4),
    (5, 5);

-- Grant permissions
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA chinook TO vscode;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA chinook TO vscode;

-- Display summary
SELECT 'Chinook database loaded successfully!' as status;
SELECT 'Artists: ' || COUNT(*) as summary FROM artist
UNION ALL
SELECT 'Albums: ' || COUNT(*) FROM album
UNION ALL
SELECT 'Tracks: ' || COUNT(*) FROM track
UNION ALL
SELECT 'Customers: ' || COUNT(*) FROM customer
UNION ALL
SELECT 'Employees: ' || COUNT(*) FROM employee
UNION ALL
SELECT 'Invoices: ' || COUNT(*) FROM invoice;
