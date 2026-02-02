#!/bin/bash.
# Conda-based post-start script - NO SUDO REQUIRED!
# This runs every time the codespace is started/resumed

echo "🔄 Post-start: Checking conda environment..."
echo "📋 Current user: $(whoami)"

# Source environment
source ~/.bashrc 2>/dev/null || true

# Check if PostgreSQL data directory exists
if [ ! -d "$HOME/postgres_data" ]; then
    echo "⚠️ PostgreSQL data directory not found, running setup..."
    bash .devcontainer/conda_setup.sh
    source ~/.bashrc
fi

# Set PostgreSQL environment variables for this session
export PGDATA="$HOME/postgres_data"
export PGUSER=jovyan
export PGDATABASE=jovyan
export PGHOST=localhost
export PGPORT=5432

# Start PostgreSQL if not running
if ! pg_ctl -D "$PGDATA" status >/dev/null 2>&1; then
    echo "🚀 Starting PostgreSQL..."
    pg_ctl -D "$PGDATA" start -l "$HOME/postgres.log" -w
    sleep 2
    
    # Create initial databases if they don't exist
    for db in jovyan vscode student; do
        if ! psql -lqt | cut -d \| -f 1 | grep -qw "$db"; then
            echo "📋 Creating $db database..."
            createdb "$db"
        fi
    done
    
    echo "✅ PostgreSQL started"
else
    echo "✅ PostgreSQL already running"
fi

# Configure student as primary database user (final step)
echo "� Configuring student user as primary for database operations..."
if [ -f "/workspaces/data-management-classroom/scripts/setup_student_primary.sh" ]; then
    # Run our comprehensive student setup script
    bash /workspaces/data-management-classroom/scripts/setup_student_primary.sh
    
    # Source the new environment for this session
    source ~/.bashrc 2>/dev/null || true
    
    # Load all sample databases as the final step
    echo "� Loading all sample databases..."
    if [ -f "/workspaces/data-management-classroom/scripts/load_all_sample_databases.sh" ]; then
        bash /workspaces/data-management-classroom/scripts/load_all_sample_databases.sh
        echo "✅ All sample databases loaded and ready"
    else
        echo "⚠️ Sample database loader not found"
    fi
else
    echo "⚠️ Student primary setup script not found, using fallback..."
    
    # Fallback: Basic student user setup
    if ! psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='student'" | grep -q 1; then
        echo "� Creating student user..."
        psql -c "CREATE USER student WITH PASSWORD 'student123' CREATEDB SUPERUSER;"
        psql -c "GRANT ALL PRIVILEGES ON DATABASE student TO student;"
        psql -c "GRANT ALL PRIVILEGES ON DATABASE postgres TO student;"
    fi
fi

# Test database connectivity with student user
echo "🔍 Testing database connection..."
if psql -U student -h localhost -d postgres -c "SELECT current_user, current_database(), version();" >/dev/null 2>&1; then
    echo "✅ Student user database connection working"
    psql -U student -h localhost -d postgres -c "SELECT 
        '🗄️ Connected as: ' || current_user as user_info,
        '📊 Database: ' || current_database() as db_info;" 2>/dev/null
    
    # Show available schemas
    echo "📋 Available database schemas:"
    psql -U student -h localhost -d postgres -c "SELECT '  • ' || schema_name as schemas FROM information_schema.schemata WHERE schema_name NOT IN ('information_schema', 'pg_catalog', 'pg_toast') ORDER BY schema_name;" -t 2>/dev/null
else
    echo "⚠️ Student user database connection failed, trying fallback..."
    if psql -c "SELECT current_user, current_database(), version();" >/dev/null 2>&1; then
        echo "✅ Fallback database connection working (jovyan user)"
        psql -c "SELECT 
            '🗄️ Connected as: ' || current_user as user_info,
            '📊 Database: ' || current_database() as db_info;" 2>/dev/null
    else
        echo "⚠️ Database connection failed"
        echo "🔧 Check PostgreSQL status with: pg_status"
        echo "🔧 Start PostgreSQL with: pg_start"
        echo "🔧 View logs with: tail -f ~/postgres.log"
    fi
fi

# Verify Jupyter configuration
if [ -f ~/.jupyter/jupyter_server_config.py ]; then
    echo "✅ Jupyter configured for zero-touch access"
else
    echo "⚠️ Jupyter configuration missing, recreating..."
    mkdir -p ~/.jupyter
    cat > ~/.jupyter/jupyter_server_config.py << 'EOF'
c.ServerApp.token = ''
c.ServerApp.password = ''
c.ServerApp.open_browser = False
c.ServerApp.ip = '0.0.0.0'
c.ServerApp.allow_origin = '*'
c.ServerApp.disable_check_xsrf = True
EOF
    echo "✅ Jupyter configuration restored"
fi

# Verify R kernel is available
echo "🔍 Checking R kernel availability..."
if jupyter kernelspec list 2>/dev/null | grep -q "ir"; then
    echo "✅ R kernel is available"
else
    echo "⚠️ R kernel not found, setting up..."
    # Run R kernel setup if missing
    if [ -f "/workspaces/data-management-classroom/scripts/setup_r_kernel.sh" ]; then
        bash /workspaces/data-management-classroom/scripts/setup_r_kernel.sh
    else
        # Inline R kernel setup
        R -e "
        user_lib <- '~/R'
        if (!dir.exists(user_lib)) dir.create(user_lib, recursive = TRUE)
        .libPaths(c(user_lib, .libPaths()))
        if (require('IRkernel', quietly = TRUE)) {
            IRkernel::installspec(user = TRUE)
            cat('✅ R kernel registered\n')
        }
        " 2>/dev/null
    fi
fi

echo "✅ Post-start check complete"
echo "🎓 Environment ready for data science work!"

# Ensure Git is properly configured for students (avoid GPG issues)
echo "🛠️ Ensuring Git configuration for GitHub Classroom..."
git config --global commit.gpgsign false 2>/dev/null || true
git config --global tag.gpgsign false 2>/dev/null || true
git config --local commit.gpgsign false 2>/dev/null || true
git config --local tag.gpgsign false 2>/dev/null || true
echo "✅ Git configured for seamless commits and pushes"

echo ""
echo "💡 Quick commands:"
echo "   📊 Start Jupyter Lab: jupyter lab"
echo "   🗄️ Connect to database: psql (connects as student user to postgres db)"
echo "   🔍 Query Northwind customers: psql -c \"SELECT * FROM northwind.customers LIMIT 5;\""
echo "   📋 List all schemas: psql -c \"\\dn\""
echo "   🔄 See all tables: psql -c \"SELECT * FROM shortcuts.all_tables;\""
echo "   📈 PostgreSQL status: pg_status"
echo "   🔄 Restart PostgreSQL: pg_restart"
echo "   📝 Git status: git status"
echo "   📤 Commit changes: git add . && git commit -m 'Your message'"
echo "   🚀 Push to GitHub: git push"
