#!/bin/bash
# Quick PostgreSQL starter script for conda-based installation
# Run this if PostgreSQL is not running

echo "🔄 Starting PostgreSQL (conda-based)..."

# Set environment variables
export PGDATA="$HOME/postgres_data"
export PGUSER=jovyan
export PGDATABASE=jovyan
export PGHOST=localhost
export PGPORT=5432

# Check if PostgreSQL is already running
if pg_ctl -D "$PGDATA" status >/dev/null 2>&1; then
    echo "✅ PostgreSQL is already running"
else
    echo "🚀 Starting PostgreSQL server..."
    pg_ctl -D "$PGDATA" start -l "$HOME/postgres.log" -w
    sleep 2
fi

# Create databases if they don't exist
for db in jovyan vscode student; do
    if ! psql -lqt | cut -d \| -f 1 | grep -qw "$db"; then
        echo "📋 Creating $db database..."
        createdb "$db"
    fi
done

# Create student user if it doesn't exist
if ! psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='student'" | grep -q 1; then
    echo "👤 Creating student user (no password)..."
    psql -c "CREATE USER student;"
    psql -c "GRANT ALL PRIVILEGES ON DATABASE student TO student;"
    psql -c "ALTER USER student CREATEDB;"
fi

# Load demo databases if not already loaded
echo "📊 Checking demo databases..."
cd /workspaces/data-management-classroom

# Check if Northwind is loaded
if ! psql -d student -tAc "SELECT 1 FROM information_schema.tables WHERE table_name='customers' LIMIT 1" 2>/dev/null | grep -q 1; then
    if [ -f "databases/northwind.sql" ]; then
        echo "📦 Loading Northwind database..."
        psql -d student -f databases/northwind.sql > /dev/null 2>&1
        echo "✅ Northwind database loaded"
    fi
fi

# Check if Sakila is loaded  
if ! psql -d student -tAc "SELECT 1 FROM information_schema.tables WHERE table_name='actor' LIMIT 1" 2>/dev/null | grep -q 1; then
    if [ -f "databases/sakila.sql" ]; then
        echo "📦 Loading Sakila database..."
        psql -d student -f databases/sakila.sql > /dev/null 2>&1
        echo "✅ Sakila database loaded"
    fi
fi

# Test connection
if psql -c "SELECT 'PostgreSQL is working!' as message, version();" >/dev/null 2>&1; then
    echo "✅ Database connection confirmed"
    echo "🎉 R PostgreSQL connectivity is ready!"
    psql -c "SELECT current_user, current_database();"
else
    echo "⚠️ Connection test failed"
    echo "🔧 Check PostgreSQL logs: tail -f ~/postgres.log"
fi
