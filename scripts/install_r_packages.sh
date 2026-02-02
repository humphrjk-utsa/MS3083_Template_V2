#!/bin/bash

echo "🔧 Installing Essential R Data Science Packages"
echo "This script ensures all required packages are installed for data science work"

# Run R script to install all essential packages
R --no-save --no-restore << 'EOF'
# Set up user library
user_lib <- "~/R/library"
if (!dir.exists(user_lib)) dir.create(user_lib, recursive = TRUE)
.libPaths(c(user_lib, .libPaths()))

# Complete list of essential packages
essential_packages <- c(
    # Jupyter/IRkernel
    "IRkernel", "repr", "uuid", "digest", "IRdisplay", "pbdZMQ",
    
    # Core tidyverse
    "dplyr", "ggplot2", "readr", "tidyr", "tibble", "stringr", "forcats", "lubridate",
    
    # Database
    "DBI", "RPostgreSQL", "RSQLite", "dbplyr",
    
    # Development and documentation
    "devtools", "knitr", "rmarkdown", "roxygen2", "testthat",
    
    # Web and data import
    "httr", "jsonlite", "rvest", "curl",
    
    # Statistical and visualization
    "broom", "scales", "plotly", "RColorBrewer",
    
    # Data manipulation
    "reshape2", "data.table"
)

cat("Installing", length(essential_packages), "essential packages...\n")

# Install missing packages
installed_count <- 0
failed_packages <- c()

for (pkg in essential_packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
        cat("Installing", pkg, "...\n")
        tryCatch({
            install.packages(pkg, lib = user_lib, repos = "https://cloud.r-project.org/", quiet = TRUE)
            if (requireNamespace(pkg, quietly = TRUE)) {
                installed_count <- installed_count + 1
                cat("✅", pkg, "installed successfully\n")
            } else {
                failed_packages <- c(failed_packages, pkg)
                cat("❌", pkg, "installation verification failed\n")
            }
        }, error = function(e) {
            failed_packages <- c(failed_packages, pkg)
            cat("❌", pkg, "installation failed:", conditionMessage(e), "\n")
        })
    } else {
        cat("✅", pkg, "already available\n")
    }
}

# Summary
cat("\n📊 Installation Summary:\n")
cat("Total packages checked:", length(essential_packages), "\n")
cat("Newly installed:", installed_count, "\n")
cat("Failed installations:", length(failed_packages), "\n")

if (length(failed_packages) > 0) {
    cat("Failed packages:", toString(failed_packages), "\n")
}

# Register R kernel
if (requireNamespace("IRkernel", quietly = TRUE)) {
    IRkernel::installspec(user = TRUE)
    cat("✅ R kernel registered with Jupyter\n")
}

cat("🎉 R package installation complete!\n")
EOF

echo "✅ R data science packages setup completed"
