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
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO student;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO student;

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
