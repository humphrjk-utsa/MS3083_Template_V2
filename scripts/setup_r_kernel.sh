#!/bin/bash

echo "🔧 Setting up R Kernel for Jupyter - Student Quick Fix"
echo "This script ensures the R kernel is properly configured for your assignment."

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if R is installed
if ! command_exists R; then
    echo "❌ R is not installed. Please run the main setup script first."
    exit 1
fi

echo "✅ R is installed ($(R --version | head -1))"

# Check if Jupyter is available
if ! command_exists jupyter; then
    echo "❌ Jupyter is not installed. Please run the main setup script first."
    exit 1
fi

echo "✅ Jupyter is available"

# Set up R environment
echo "📦 Setting up R libraries and kernel..."

R -e "
# Ensure user library exists and is in path
user_lib <- '~/R'
if (!dir.exists(user_lib)) {
    dir.create(user_lib, recursive = TRUE)
    cat('Created user library directory\\n')
}
.libPaths(c(user_lib, .libPaths()))

# Check if IRkernel is installed
if (!require('IRkernel', quietly = TRUE)) {
    cat('📦 Installing IRkernel and dependencies...\\n')
    
    # Install essential packages
    essential_packages <- c('IRkernel', 'repr', 'IRdisplay', 'crayon', 'pbdZMQ', 'uuid', 'digest')
    
    for (pkg in essential_packages) {
        if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
            cat('Installing', pkg, '...\\n')
            install.packages(pkg, repos='https://cran.rstudio.com/', lib=user_lib, quiet=TRUE)
        }
    }
    
    cat('✅ Packages installed\\n')
} else {
    cat('✅ IRkernel already available\\n')
}

# Register kernel with Jupyter
library(IRkernel, lib.loc=user_lib)
IRkernel::installspec(user = TRUE)
cat('✅ R kernel registered with Jupyter\\n')

# Test the installation
if (require('IRkernel', quietly = TRUE)) {
    cat('🎉 R kernel setup complete!\\n')
} else {
    cat('⚠️ There may be issues with the R kernel setup\\n')
}
" 2>/dev/null

# Create/update .Rprofile
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

# Test if kernel is available
echo "🧪 Testing kernel availability..."
if jupyter kernelspec list | grep -q "ir"; then
    echo "✅ R kernel is available in Jupyter!"
    echo ""
    echo "🎯 Testing R kernel functionality..."
    
    # Quick test to ensure kernel works
    R -e "
    if (require('IRkernel', quietly = TRUE)) {
        cat('✅ IRkernel package is functional\n')
        cat('✅ R kernel is ready for use\n')
    } else {
        cat('⚠️ IRkernel package issues detected\n')
    }
    " 2>/dev/null
    
    echo ""
    echo "🎯 Next steps:"
    echo "1. Open any .ipynb file in VS Code"
    echo "2. Click the kernel selector (top right)"
    echo "3. Choose 'R' from the dropdown"
    echo "4. Start coding in R!"
    echo ""
    echo "� If kernel doesn't appear:"
    echo "   - Refresh VS Code (Ctrl+Shift+P > 'Developer: Reload Window')"
    echo "   - Wait a moment for VS Code to detect kernels"
    echo "   - Click the kernel selector and look for 'R'"
    echo ""
    echo "�🚀 You're ready to go!"
else
    echo "⚠️ R kernel not detected. Attempting to register again..."
    
    # Try to register kernel again
    R -e "
    user_lib <- '~/R'
    .libPaths(c(user_lib, .libPaths()))
    if (require('IRkernel', quietly = TRUE)) {
        IRkernel::installspec(user = TRUE)
        cat('✅ R kernel re-registered\n')
    }
    " 2>/dev/null
    
    # Check again
    if jupyter kernelspec list | grep -q "ir"; then
        echo "✅ R kernel now available!"
    else
        echo "❌ R kernel still not available"
        echo "💡 Try restarting VS Code or running: jupyter kernelspec list"
        echo "💡 If issues persist, run: python scripts/test_setup.py"
    fi
fi
