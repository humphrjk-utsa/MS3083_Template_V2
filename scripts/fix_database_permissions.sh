#!/bin/bash

# Fix Database Permissions Script
# Changes all vscode user grants to student user grants in database files
# Ensures compatibility with student-primary setup

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 Fixing database permissions to use student user...${NC}"

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

DATABASES_DIR="/workspaces/data-management-classroom/databases"
BACKUP_DIR="/workspaces/data-management-classroom/databases/backup_$(date +%Y%m%d_%H%M%S)"

# Create backup directory
print_status "Creating backup of original database files..."
mkdir -p "$BACKUP_DIR"

# Process each SQL file in the databases directory
for sql_file in "$DATABASES_DIR"/*.sql; do
    if [ -f "$sql_file" ]; then
        filename=$(basename "$sql_file")
        print_status "Processing $filename..."
        
        # Create backup
        cp "$sql_file" "$BACKUP_DIR/"
        
        # Create temporary file for modifications
        temp_file=$(mktemp)
        
        # Replace vscode with student in grants and permissions
        sed -e 's/TO vscode/TO student/g' \
            -e 's/FROM vscode/FROM student/g' \
            -e 's/OWNER vscode/OWNER student/g' \
            -e 's/FOR vscode/FOR student/g' \
            -e 's/= vscode/= student/g' \
            -e 's/vscode\./student\./g' \
            "$sql_file" > "$temp_file"
        
        # Add student grants after any existing vscode grants (in case some remain)
        cat "$temp_file" > "$sql_file"
        
        # Add comprehensive student grants at the end of each file
        cat >> "$sql_file" << 'EOF'

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
EOF
        
        rm "$temp_file"
        print_success "Fixed permissions in $filename"
    fi
done

print_success "Database permission fixes complete!"
print_status "Backup created at: $BACKUP_DIR"

echo -e "\n${GREEN}All database files now grant permissions to 'student' user${NC}"
echo -e "${YELLOW}Original files backed up to: $BACKUP_DIR${NC}"
