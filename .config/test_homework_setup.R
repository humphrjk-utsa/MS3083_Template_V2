#!/usr/bin/env Rscript

# Quick test to verify the homework setup works with actual CSV file

library(tidyverse)

# Test importing the messy data
messy_sales <- read_csv("data/messy_sales_data.csv", show_col_types = FALSE)

cat("✅ Dataset imported successfully!\n")
cat("📊 Dimensions:", nrow(messy_sales), "rows x", ncol(messy_sales), "columns\n")
cat("📋 Columns:", paste(names(messy_sales), collapse = ", "), "\n")

# Check for missing values
missing_summary <- sapply(messy_sales, function(x) sum(is.na(x)))
cat("❓ Missing values per column:\n")
print(missing_summary)

# Check for potential outliers in Sales_Amount
sales_summary <- summary(messy_sales$Sales_Amount)
cat("💰 Sales_Amount summary:\n")
print(sales_summary)

# Quick outlier check
Q1 <- quantile(messy_sales$Sales_Amount, 0.25, na.rm = TRUE)
Q3 <- quantile(messy_sales$Sales_Amount, 0.75, na.rm = TRUE)
IQR_val <- Q3 - Q1
upper_threshold <- Q3 + 1.5 * IQR_val
lower_threshold <- Q1 - 1.5 * IQR_val

outliers <- messy_sales %>% 
  filter(Sales_Amount > upper_threshold | Sales_Amount < lower_threshold, 
         !is.na(Sales_Amount))

cat("🚨 Potential outliers found:", nrow(outliers), "\n")

cat("✨ Ready for homework assignment!\n")
