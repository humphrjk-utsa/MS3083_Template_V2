#!/bin/bash
# Conda-based setup for jovyan user - NO SUDO REQUIRED!
# Works with the conda PostgreSQL installation in datascience-notebook

echo "🚀 Setting up conda-based data science environment..."
echo "📋 Current user: $(whoami)"
echo "🐍 Conda location: $(which conda)"

# Initialize conda for bash if not already done
if ! grep -q "conda initialize" ~/.bashrc; then
    echo "🔧 Initializing conda for bash..."
    conda init bash
fi

# Ensure conda is available in current session
source ~/.bashrc 2>/dev/null || true

# Install additional packages via conda (safer than pip in conda environments)
echo "📦 Installing additional conda packages..."
conda install -c conda-forge -y \
    postgresql \
    psycopg2 \
    sqlalchemy \
    plotly \
    bokeh \
    ipython \
    lxml \
    beautifulsoup4 \
    git \
    nodejs \
    gh

# Install Python packages via pip that aren't available in conda
echo "🐍 Installing additional Python packages..."
pip install --no-cache-dir \
    psycopg2-binary \
    jupyter-server-config \
    ipython-sql

# Configure Jupyter to disable authentication for classroom use
echo "📓 Configuring Jupyter for classroom use..."
mkdir -p ~/.jupyter
cat > ~/.jupyter/jupyter_server_config.py << 'EOF'
c.ServerApp.token = ''
c.ServerApp.password = ''
c.ServerApp.open_browser = False
c.ServerApp.ip = '0.0.0.0'
c.ServerApp.allow_origin = '*'
c.ServerApp.disable_check_xsrf = True
EOF

# Set up PostgreSQL data directory (using conda postgres)
echo "🗄️ Setting up PostgreSQL data directory..."
export PGDATA="$HOME/postgres_data"
mkdir -p "$PGDATA"

# Initialize PostgreSQL database if not already done
if [ ! -f "$PGDATA/PG_VERSION" ]; then
    echo "🔧 Initializing PostgreSQL database..."
    initdb -D "$PGDATA" --auth-local=trust --auth-host=trust
    echo "✅ PostgreSQL database initialized"
fi

# Configure PostgreSQL
echo "🔐 Configuring PostgreSQL..."
cat >> "$PGDATA/postgresql.conf" << 'EOF'
# Additional configuration for development
listen_addresses = 'localhost'
port = 5432
max_connections = 100
shared_buffers = 128MB
EOF

# Start PostgreSQL temporarily for initial setup
echo "🚀 Starting PostgreSQL for initial setup..."
pg_ctl -D "$PGDATA" start -l "$HOME/postgres.log" -w
sleep 2

# Create databases and users
echo "👤 Setting up databases and users..."
createdb jovyan 2>/dev/null || true
createdb vscode 2>/dev/null || true  
createdb student 2>/dev/null || true

# Create student user with no password
psql -c "CREATE USER student;" 2>/dev/null || true
psql -c "GRANT ALL PRIVILEGES ON DATABASE student TO student;" 2>/dev/null || true
psql -c "ALTER USER student CREATEDB;" 2>/dev/null || true

# Load demo databases
echo "📊 Loading demo databases for students..."
if [ -f "databases/northwind.sql" ]; then
    echo "📦 Loading Northwind database..."
    psql -d student -f databases/northwind.sql > /dev/null 2>&1
    echo "✅ Northwind database loaded"
fi

if [ -f "databases/sakila.sql" ]; then
    echo "📦 Loading Sakila database..."
    psql -d student -f databases/sakila.sql > /dev/null 2>&1
    echo "✅ Sakila database loaded"
fi

# Stop PostgreSQL (it will be started properly by post-start script)
pg_ctl -D "$PGDATA" stop -w > /dev/null 2>&1

# Set up environment variables for PostgreSQL
echo "🌍 Setting up environment variables..."
cat >> ~/.bashrc << 'EOF'

# PostgreSQL environment (conda-based)
export PGDATA="$HOME/postgres_data"
export PGUSER=jovyan
export PGDATABASE=jovyan
export PGHOST=localhost
export PGPORT=5432

# Aliases for common database operations
alias pg_start='pg_ctl -D $PGDATA start'
alias pg_stop='pg_ctl -D $PGDATA stop'
alias pg_status='pg_ctl -D $PGDATA status'
alias pg_restart='pg_ctl -D $PGDATA restart'

EOF

# Source the updated bashrc
source ~/.bashrc

# Git configuration
echo "🛠️ Configuring Git..."
git config --global init.defaultBranch main
git config --global user.name "Data Science Student" 2>/dev/null || true
git config --global user.email "student@example.com" 2>/dev/null || true
# Disable GPG signing to avoid issues in codespaces/containers
git config --global commit.gpgsign false
git config --global tag.gpgsign false
echo "✅ Git configured without GPG signing for classroom use"

# Set up R kernel for Jupyter
echo "🔧 Setting up R kernel for Jupyter..."
R -e "
# Ensure user library exists and is in path
user_lib <- '~/R'
if (!dir.exists(user_lib)) {
    dir.create(user_lib, recursive = TRUE)
    cat('📂 Created user library directory\n')
}
.libPaths(c(user_lib, .libPaths()))

# Check if IRkernel is installed
if (!require('IRkernel', quietly = TRUE)) {
    cat('📦 Installing IRkernel and dependencies...\n')
    
    # Install essential packages for Jupyter integration
    essential_packages <- c('IRkernel', 'repr', 'IRdisplay', 'crayon', 'pbdZMQ', 'uuid', 'digest')
    
    for (pkg in essential_packages) {
        if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
            cat('Installing', pkg, '...\n')
            install.packages(pkg, repos='https://cran.rstudio.com/', lib=user_lib, quiet=TRUE)
        }
    }
    
    cat('✅ R packages installed\n')
} else {
    cat('✅ IRkernel already available\n')
}

# Register kernel with Jupyter
library(IRkernel, lib.loc=user_lib)
tryCatch({
    IRkernel::installspec(user = TRUE)
    cat('✅ R kernel registered with Jupyter\n')
}, error = function(e) {
    cat('⚠️ Kernel registration warning (may be normal):', conditionMessage(e), '\n')
})

# Test the installation
if (require('IRkernel', quietly = TRUE)) {
    cat('🎉 R kernel setup complete!\n')
} else {
    cat('⚠️ There may be issues with the R kernel setup\n')
}
" 2>/dev/null

# Create/update .Rprofile for consistent R environment
echo "📝 Creating R profile for consistent library paths..."
cat > ~/.Rprofile << 'RPROFILE_EOF'
# Ensure user library is always available
user_lib <- "~/R"
if (!dir.exists(user_lib)) {
    dir.create(user_lib, recursive = TRUE)
}
.libPaths(c(user_lib, .libPaths()))

# Set CRAN mirror
options(repos = c(CRAN = "https://cran.rstudio.com/"))
RPROFILE_EOF

echo "✅ R profile created"

echo "✅ Conda-based setup complete!"
echo "🎓 Environment ready:"
echo "   - User: jovyan (no sudo needed)"
echo "   - PostgreSQL: conda-based, user-owned data directory"
echo "   - Jupyter: Authentication disabled"
echo "   - Python: Full data science stack via conda"
echo "   - Tools: Git, GitHub CLI, Node.js via conda"
echo ""
echo "🔗 To start PostgreSQL: pg_start"
echo "🔗 To check status: pg_status"
echo "🔗 To connect: psql"
