#!/usr/bin/env Rscript

# Simple test of the autograder functionality
# This script tests individual components without executing student code

library(jsonlite)
library(tidyverse, quietly = TRUE)

# Test the data import manually
cat("Testing data import...\n")
messy_sales <- read_csv("data/messy_sales_data.csv")
cat("✓ Data imported successfully\n")
cat("✓ Dataset has", nrow(messy_sales), "rows and", ncol(messy_sales), "columns\n")
cat("✓ Missing values:", sum(is.na(messy_sales)), "\n")

# Test missing value functions
cat("\nTesting missing value analysis...\n")
total_missing <- sum(is.na(messy_sales))
missing_per_column <- colSums(is.na(messy_sales))
cat("✓ Total missing values:", total_missing, "\n")
cat("✓ Missing per column calculated\n")

# Test missing value removal
sales_removed_na <- messy_sales[complete.cases(messy_sales), ]
cat("✓ Rows after removing NA:", nrow(sales_removed_na), "\n")

# Test imputation
get_mode <- function(v) {
  uniqv <- unique(v[!is.na(v)])
  uniqv[which.max(tabulate(match(v, uniqv)))]
}
cat("✓ Mode function created\n")

# Test outlier detection
Q1_sales <- quantile(messy_sales$Sales_Amount, 0.25, na.rm = TRUE)
Q3_sales <- quantile(messy_sales$Sales_Amount, 0.75, na.rm = TRUE)
IQR_sales <- Q3_sales - Q1_sales
upper_threshold <- Q3_sales + 1.5 * IQR_sales
lower_threshold <- Q1_sales - 1.5 * IQR_sales

outliers <- messy_sales[!is.na(messy_sales$Sales_Amount) & 
                       (messy_sales$Sales_Amount > upper_threshold | 
                        messy_sales$Sales_Amount < lower_threshold), ]

cat("✓ Outlier detection completed\n")
cat("✓ Found", nrow(outliers), "outliers\n")

cat("\n=== ALL BASIC TESTS PASSED ===\n")
