#!/bin/bash

# Load All Sample Databases Script
# Loads all sample databases as schemas in the postgres database
# Works with student user as primary

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📊 Loading all sample databases into postgres database...${NC}"

# Function to print status
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Configuration
DB_USER="student"
DB_NAME="postgres"
DB_HOST="localhost"
DB_PORT="5432"
DATABASES_DIR="/workspaces/data-management-classroom/databases"

# Set environment variables for this session
export PGUSER="$DB_USER"
export PGDATABASE="$DB_NAME" 
export PGHOST="$DB_HOST"
export PGPORT="$DB_PORT"

# Check if databases directory exists
if [ ! -d "$DATABASES_DIR" ]; then
    print_error "Databases directory not found: $DATABASES_DIR"
    exit 1
fi

# Test connection
print_status "Testing database connection..."
if ! psql -c "SELECT 'Connection successful!' as status;" 2>/dev/null; then
    print_error "Cannot connect to PostgreSQL. Please run setup_student_primary.sh first."
    exit 1
fi

print_success "Connected to PostgreSQL as $DB_USER"

# List of databases to load in proper dependency order
declare -a databases=(
    "sample.sql"           # Load first - dashboard depends on this
    "northwind.sql" 
    "hr_employees.sql"
    "adventureworks.sql"
    "chinook.sql"
    "sakila.sql"
    "worldwideimporters.sql"
    "dashboard.sql"        # Load last - depends on sample.sql
)

# Load each database
for db_file in "${databases[@]}"; do
    db_path="$DATABASES_DIR/$db_file"
    
    if [ -f "$db_path" ]; then
        db_name=$(basename "$db_file" .sql)
        print_status "Loading $db_name database..."
        
        # Load the database
        if psql -f "$db_path" 2>/dev/null; then
            print_success "✓ $db_name loaded successfully"
        else
            print_warning "⚠ $db_name had some issues but continued"
        fi
    else
        print_warning "Database file not found: $db_file"
    fi
done

# Show available schemas
print_status "Available schemas in postgres database:"
psql -c "SELECT schema_name FROM information_schema.schemata WHERE schema_name NOT IN ('information_schema', 'pg_catalog', 'pg_toast') ORDER BY schema_name;" 2>/dev/null

# Create helpful views for easy access
print_status "Creating helpful shortcuts..."

psql << 'EOF' 2>/dev/null || true
-- Create a schema for convenience views
CREATE SCHEMA IF NOT EXISTS shortcuts;

-- Create view to see all available tables across schemas
CREATE OR REPLACE VIEW shortcuts.all_tables AS
SELECT 
    schemaname as schema,
    tablename as table_name,
    schemaname || '.' || tablename as full_name
FROM pg_tables 
WHERE schemaname NOT IN ('information_schema', 'pg_catalog')
ORDER BY schemaname, tablename;

-- Grant access to shortcuts schema
GRANT ALL PRIVILEGES ON SCHEMA shortcuts TO student;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA shortcuts TO student;

-- Set search path to include common schemas
ALTER USER student SET search_path = northwind, hr, public, shortcuts;
EOF

print_success "Database loading complete!"

echo -e "\n${GREEN}🎉 All sample databases loaded as schemas in postgres database${NC}"
echo -e "\n${BLUE}Quick reference:${NC}"
echo -e "  • ${GREEN}psql${NC} - Connect to postgres database (with all schemas)"
echo -e "  • ${GREEN}\\dn${NC} - List all schemas"
echo -e "  • ${GREEN}SELECT * FROM shortcuts.all_tables;${NC} - See all available tables"
echo -e "  • ${GREEN}SET search_path = northwind, public;${NC} - Switch to northwind schema"
echo -e "  • ${GREEN}SELECT * FROM customers;${NC} - Query northwind customers (after setting path)"

echo -e "\n${YELLOW}Example queries:${NC}"
echo -e "  ${BLUE}Northwind customers:${NC} SELECT * FROM northwind.customers LIMIT 5;"
echo -e "  ${BLUE}HR employees:${NC} SELECT * FROM hr.employees LIMIT 5;"
echo -e "  ${BLUE}All schemas:${NC} SELECT schema_name FROM information_schema.schemata;"
