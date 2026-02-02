#!/bin/bash
# Auto-start PostgreSQL script
# This should be run every time the container starts

echo "🔄 Checking PostgreSQL status..."

# Set environment variables
export PGDATA="$HOME/postgres_data"
export PGUSER=jovyan
export PGDATABASE=jovyan
export PGHOST=localhost
export PGPORT=5432

# Check if PostgreSQL is running
if pg_ctl -D "$PGDATA" status >/dev/null 2>&1; then
    echo "✅ PostgreSQL is already running"
else
    echo "🚀 Starting PostgreSQL..."
    pg_ctl -D "$PGDATA" start -l "$HOME/postgres.log" -w
    echo "✅ PostgreSQL started successfully"
fi

# Verify connection
if psql -c "SELECT current_user, current_database();" >/dev/null 2>&1; then
    echo "✅ Database connection verified"
else
    echo "❌ Database connection failed"
fi
