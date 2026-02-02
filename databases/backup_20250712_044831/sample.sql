-- Sample database setup for classroom
CREATE TABLE IF NOT EXISTS students (
    id SERIAL PRIMARY KEY, 
    name VARCHAR(100), 
    grade INTEGER
);

INSERT INTO students (name, grade) VALUES 
    ('Alice', 95), 
    ('Bob', 87),
    ('Carol', 92)
ON CONFLICT DO NOTHING;

-- Grant permissions
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO vscode;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO vscode;
