#!/bin/bash

# Setup Student as Primary Database User
# This script configures the environment to use 'student' user for all database operations
# Avoids jovyan token authentication issues

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 Setting up student user as primary for database operations...${NC}"

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

# Check if PostgreSQL is running
if ! pgrep -x postgres > /dev/null; then
    print_error "PostgreSQL is not running. Please start it first."
    exit 1
fi

print_status "PostgreSQL is running ✓"

# Try to connect as jovyan first to set up the student user
print_status "Setting up student user and database..."

# Create a temporary SQL file for setup
cat > /tmp/setup_student.sql << 'EOF'
-- Create student user if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'student') THEN
        CREATE USER student WITH PASSWORD 'student123' CREATEDB SUPERUSER;
        RAISE NOTICE 'Created student user';
    ELSE
        ALTER USER student WITH PASSWORD 'student123' CREATEDB SUPERUSER;
        RAISE NOTICE 'Updated student user permissions';
    END IF;
END
$$;

-- Create vscode user if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'vscode') THEN
        CREATE USER vscode WITH PASSWORD 'vscode123' CREATEDB SUPERUSER;
        RAISE NOTICE 'Created vscode user';
    ELSE
        ALTER USER vscode WITH PASSWORD 'vscode123' CREATEDB SUPERUSER;
        RAISE NOTICE 'Updated vscode user permissions';
    END IF;
END
$$;

-- Create student_db database if it doesn't exist
SELECT 'CREATE DATABASE student_db OWNER student'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'student_db')\gexec

-- Grant all privileges
GRANT ALL PRIVILEGES ON DATABASE postgres TO student;
GRANT ALL PRIVILEGES ON DATABASE student_db TO student;
GRANT ALL PRIVILEGES ON DATABASE postgres TO vscode;
GRANT ALL PRIVILEGES ON DATABASE student_db TO vscode;
EOF

# Try different connection methods
print_status "Attempting to connect to PostgreSQL..."

# Method 1: Try as jovyan (current user)
if psql -h localhost -U jovyan -d postgres -f /tmp/setup_student.sql 2>/dev/null; then
    print_success "Connected as jovyan and set up users"
elif psql -h localhost -d postgres -f /tmp/setup_student.sql 2>/dev/null; then
    print_success "Connected with default settings and set up users"
elif psql -U postgres -d postgres -f /tmp/setup_student.sql 2>/dev/null; then
    print_success "Connected as postgres user and set up users"
else
    print_warning "Could not connect with standard methods, trying alternative..."
    # Try with peer authentication
    if sudo -u postgres psql -d postgres -f /tmp/setup_student.sql 2>/dev/null; then
        print_success "Connected via postgres system user"
    else
        print_error "Could not establish database connection. Manual setup may be required."
        exit 1
    fi
fi

# Clean up temp file
rm -f /tmp/setup_student.sql

# Create .pgpass file for password-free access
print_status "Setting up password-free access..."

cat > ~/.pgpass << 'EOF'
localhost:5432:*:student:student123
localhost:5432:*:vscode:vscode123
127.0.0.1:5432:*:student:student123
127.0.0.1:5432:*:vscode:vscode123
*:5432:*:student:student123
*:5432:*:vscode:vscode123
EOF

chmod 600 ~/.pgpass
print_success "Created .pgpass file for automatic authentication"

# Set default PostgreSQL environment variables
print_status "Setting up environment variables..."

# Only add if not already present
if ! grep -q "# PostgreSQL Environment - Student User Primary" ~/.bashrc; then
cat >> ~/.bashrc << 'EOF'

# PostgreSQL Environment - Student User Primary
export PGUSER=student
export PGPASSWORD=student123
export PGDATABASE=postgres
export PGHOST=localhost
export PGPORT=5432

# Aliases for easy database access
alias psql-student='psql -U student -d student_db -h localhost'
alias psql-postgres='psql -U student -d postgres -h localhost'
alias load-northwind='psql -U student -d postgres -h localhost -f /workspaces/data-management-classroom/databases/northwind.sql'
alias load-all-dbs='bash /workspaces/data-management-classroom/scripts/load_all_sample_databases.sh'

EOF
    print_success "Environment variables added to ~/.bashrc"
else
    print_status "Environment variables already configured ✓"
fi

# Source the new environment
source ~/.bashrc 2>/dev/null || true

print_success "Environment variables set in ~/.bashrc"

# Test the connection
print_status "Testing student user connection..."

if psql -U student -d postgres -h localhost -c "SELECT 'Student user connection successful!' as status;" 2>/dev/null; then
    print_success "Student user can connect to PostgreSQL!"
else
    print_warning "Student user connection test failed, but setup is complete"
fi

# Fix database permissions to use student user (only if not already done)
if [ ! -f "/tmp/.db_permissions_fixed" ]; then
    print_status "Fixing database permissions..."
    if bash /workspaces/data-management-classroom/scripts/fix_database_permissions.sh; then
        print_success "Database permissions fixed for student user"
        touch /tmp/.db_permissions_fixed
    else
        print_warning "Some issues fixing database permissions, but continuing..."
    fi
else
    print_status "Database permissions already fixed ✓"
fi

print_success "Setup complete! You can now use:"
echo -e "${GREEN}  • psql${NC} - Connect to postgres db as student user (default)"
echo -e "${GREEN}  • psql-student${NC} - Connect to student_db as student user"  
echo -e "${GREEN}  • psql-postgres${NC} - Connect to postgres db as student user"
echo -e "${GREEN}  • load-northwind${NC} - Load Northwind database"
echo -e "${GREEN}  • load-all-dbs${NC} - Load all sample databases"
echo -e "${GREEN}  • psql -U student -h localhost${NC} - Manual connection"

echo -e "\n${BLUE}Environment variables set:${NC}"
echo -e "  PGUSER=student"
echo -e "  PGDATABASE=postgres (changed to use main postgres db)"
echo -e "  PGHOST=localhost"
echo -e "  PGPORT=5432"

echo -e "\n${YELLOW}Note: Run 'source ~/.bashrc' or restart your terminal to use the new aliases${NC}"
echo -e "${YELLOW}Then run 'load-all-dbs' to load all sample databases${NC}"
