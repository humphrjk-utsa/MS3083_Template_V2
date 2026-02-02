#!/usr/bin/env Rscript

# Autograding script for homework_lesson_1.ipynb
# This script extracts and runs R code from the Jupyter notebook to test functionality

library(jsonlite)

# Load other packages only if needed for code execution tests
load_data_packages <- function() {
  library(tidyverse, quietly = TRUE)
  library(readxl, quietly = TRUE)
}

# Function to extract R code from Jupyter notebook
extract_r_code <- function(notebook_path) {
  if (!file.exists(notebook_path)) {
    stop("Notebook file not found")
  }
  
  notebook <- fromJSON(notebook_path, simplifyVector = FALSE)
  
  r_code <- ""
  for (cell in notebook$cells) {
    if (cell$cell_type == "code") {
      # Check if it's an R cell (either by vscode metadata or by content)
      is_r_cell <- FALSE
      
      # Check vscode metadata for R language
      if (!is.null(cell$metadata$vscode) && 
          !is.null(cell$metadata$vscode$languageId) &&
          cell$metadata$vscode$languageId == "r") {
        is_r_cell <- TRUE
      }
      
      # Also accept cells that look like R code (contain R-specific functions)
      cell_code <- paste(cell$source, collapse = "\n")
      if (grepl("library\\(|read_csv|read_excel|getwd\\(\\)|head\\(|str\\(|summary\\(", cell_code)) {
        is_r_cell <- TRUE
      }
      
      if (is_r_cell) {
        r_code <- paste(r_code, cell_code, sep = "\n")
      }
    }
  }
  
  return(r_code)
}

# Test functions
test_data_import <- function() {
  tryCatch({
    # Check if data frames exist and have expected structure
    score <- 0
    max_score <- 10
    issues <- c()
    
    if (exists("sales_df")) {
      if (nrow(sales_df) > 0) {
        score <- score + 3
        if ("Date" %in% names(sales_df)) score <- score + 1
        if ("Amount" %in% names(sales_df)) score <- score + 1
      } else {
        issues <- c(issues, "sales_df is empty")
      }
    } else {
      issues <- c(issues, "sales_df not found")
    }
    
    if (exists("ratings_df")) {
      if (nrow(ratings_df) > 0) {
        score <- score + 2
      } else {
        issues <- c(issues, "ratings_df is empty")
      }
    } else {
      issues <- c(issues, "ratings_df not found")
    }
    
    if (exists("comments_df")) {
      if (nrow(comments_df) > 0) {
        score <- score + 2
      } else {
        issues <- c(issues, "comments_df is empty")
      }
    } else {
      issues <- c(issues, "comments_df not found")
    }
    
    # Check if the code at least attempts the right functions
    if (!exists("sales_df") || !exists("ratings_df") || !exists("comments_df")) {
      # Look for evidence of trying to import data
      r_code <- get("extracted_code", envir = .GlobalEnv)
      if (grepl("read_csv", r_code)) score <- score + 1
      if (grepl("read_excel", r_code)) score <- score + 1
    }
    
    if (score >= max_score * 0.7) {  # 70% threshold
      if (length(issues) > 0) {
        return(paste("PARTIAL PASS:", paste(issues, collapse = "; ")))
      } else {
        return("PASS")
      }
    } else {
      return(paste("FAIL:", paste(issues, collapse = "; ")))
    }
    
  }, error = function(e) {
    return(paste("FAIL:", e$message))
  })
}

test_packages_loaded <- function() {
  tryCatch({
    if (!"tidyverse" %in% (.packages())) return("FAIL: tidyverse not loaded")
    if (!"readxl" %in% (.packages())) return("FAIL: readxl not loaded")
    return("PASS")
  }, error = function(e) {
    return(paste("FAIL:", e$message))
  })
}

test_data_types <- function() {
  tryCatch({
    if (!exists("sales_df")) return("FAIL: sales_df not found")
    
    # Check if Date column is properly formatted
    date_col <- sales_df$Date
    if (is.character(date_col) || is.factor(date_col)) {
      return("FAIL: Date column should be converted to Date type")
    }
    
    # Check if Amount is numeric
    if (!is.numeric(sales_df$Amount)) {
      return("FAIL: Amount column should be numeric")
    }
    
    return("PASS")
  }, error = function(e) {
    return(paste("FAIL:", e$message))
  })
}

test_reflection_questions <- function() {
  tryCatch({
    # Get the notebook path
    notebook_path <- get("notebook_file", envir = .GlobalEnv)
    
    # Use separate reflection checker to avoid package loading issues
    result <- system2("Rscript", 
                     args = c(".config/classroom/reflection_checker.R", notebook_path),
                     stdout = TRUE, stderr = TRUE)
    
    if (length(result) > 0) {
      return(result[1])  # Return the first line of output
    } else {
      return("FAIL: No reflection response detected")
    }
  }, error = function(e) {
    return(paste("FAIL:", e$message))
  })
}

# Main execution
main <- function() {
  args <- commandArgs(trailingOnly = TRUE)
  if (length(args) < 2) {
    cat("Usage: autograder.R <notebook_path> <test_name>\n")
    quit(status = 1)
  }
  
  notebook_path <- args[1]
  test_name <- args[2]
  
  # Store notebook path for access by test functions
  assign("notebook_file", notebook_path, envir = .GlobalEnv)
  
  # Extract and execute R code from notebook (skip for reflection test)
  if (test_name != "reflection") {
    # Load data packages for code execution tests
    load_data_packages()
    
    tryCatch({
      r_code <- extract_r_code(notebook_path)
      
      # Store extracted code for analysis
      assign("extracted_code", r_code, envir = .GlobalEnv)
      
      # Only execute if there's actual code
      if (nchar(trimws(r_code)) > 0) {
        eval(parse(text = r_code))
      }
    }, error = function(e) {
      cat("FAIL: Error executing notebook code -", e$message, "\n")
      quit(status = 1)
    })
  }
  
  # Run the specified test
  result <- switch(test_name,
    "data_import" = test_data_import(),
    "packages" = test_packages_loaded(), 
    "data_types" = test_data_types(),
    "reflection" = test_reflection_questions(),
    "FAIL: Unknown test"
  )
  
  cat(result, "\n")
  
  # Exit with appropriate status (accept both PASS and PARTIAL PASS)
  if (startsWith(result, "PASS") || startsWith(result, "PARTIAL PASS")) {
    quit(status = 0)
  } else {
    quit(status = 1)
  }
}

# Run main function
main()
