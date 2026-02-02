#!/usr/bin/env Rscript

# Autograding script for homework_lesson_2_data_cleaning.ipynb
# This script analyzes R code from the Jupyter notebook and tests expected functionality

library(jsonlite)
suppressMessages(library(tidyverse, warn.conflicts = FALSE, quietly = TRUE))

# Function to extract R code from Jupyter notebook
extract_r_code <- function(notebook_path) {
  if (!file.exists(notebook_path)) {
    stop("Notebook file not found")
  }
  
  notebook <- fromJSON(notebook_path, simplifyVector = FALSE)
  
  r_code <- ""
  code_patterns <- list()
  
  for (i in seq_along(notebook$cells)) {
    cell <- notebook$cells[[i]]
    if (cell$cell_type == "code") {
      cell_code <- paste(cell$source, collapse = "\n")
      
      # Check if it's an R cell by content patterns
      if (grepl("library\\(|read_csv|<-|print\\(|summary\\(|head\\(|str\\(", cell_code, ignore.case = TRUE)) {
        # Store both the code and patterns for analysis
        code_patterns[[length(code_patterns) + 1]] <- list(
          cell_index = i,
          code = cell_code,
          has_assignment = grepl("<-", cell_code),
          has_function_call = grepl("\\w+\\(", cell_code),
          is_todo = grepl("# YOUR CODE HERE|TODO", cell_code)
        )
        
        # Only add non-TODO code to executable code
        if (!grepl("^\\s*# YOUR CODE HERE\\s*$|^\\s*# TODO", cell_code)) {
          r_code <- paste(r_code, cell_code, sep = "\n")
        }
      }
    }
  }
  
  return(list(code = r_code, patterns = code_patterns))
}

# Test functions for data cleaning homework

test_dataset_creation <- function() {
  tryCatch({
    score <- 0
    max_score <- 10
    issues <- c()
    
    # First, test if we can load the data ourselves
    if (file.exists("data/messy_sales_data.csv")) {
      messy_sales <- read_csv("data/messy_sales_data.csv", show_col_types = FALSE)
      score <- score + 3
      
      # Check expected columns
      expected_cols <- c("TransactionID", "Customer_Name", "Product_Category", "Sales_Amount", "Purchase_Date", "Quantity")
      if (all(expected_cols %in% names(messy_sales))) {
        score <- score + 2
      } else {
        issues <- c(issues, "CSV file missing expected columns")
      }
      
      # Check for missing values (should have some for practice)
      if (sum(is.na(messy_sales)) > 0) {
        score <- score + 2
      } else {
        issues <- c(issues, "Dataset should contain missing values for practice")
      }
      
      # Check if dataset has reasonable number of rows
      if (nrow(messy_sales) >= 100 && nrow(messy_sales) <= 500) {
        score <- score + 1
      } else {
        issues <- c(issues, "Dataset size seems incorrect")
      }
      
      # Look for evidence student imported the data
      code_info <- get("code_info", envir = .GlobalEnv)
      if (any(sapply(code_info$patterns, function(p) grepl("read_csv|messy_sales.*<-", p$code)))) {
        score <- score + 2
      } else {
        issues <- c(issues, "No evidence of data import in student code")
      }
      
    } else {
      issues <- c(issues, "messy_sales_data.csv file not found")
    }
    
    if (score >= max_score * 0.7) {
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

test_data_assessment <- function() {
  tryCatch({
    score <- 0
    max_score <- 10
    issues <- c()
    
    # Look for evidence that students performed data assessment
    # Check if they used basic inspection functions (evidence in the extracted code)
    extracted_code <- get("extracted_code", envir = .GlobalEnv)
    
    assessment_functions <- c("head\\(", "str\\(", "summary\\(", "dim\\(", "nrow\\(", "ncol\\(", "names\\(")
    functions_found <- 0
    
    for (func_pattern in assessment_functions) {
      if (grepl(func_pattern, extracted_code)) {
        functions_found <- functions_found + 1
        score <- score + 1
      }
    }
    
    # Bonus points for additional assessment techniques
    advanced_functions <- c("colSums\\(is\\.na", "is\\.na\\(", "class\\(")
    for (func_pattern in advanced_functions) {
      if (grepl(func_pattern, extracted_code)) {
        score <- score + 1
      }
    }
    
    if (functions_found >= 3) {
      score <- score + 2  # Bonus for comprehensive assessment
    }
    
    if (score >= max_score * 0.5) {
      if (functions_found < 3) {
        return(paste("PARTIAL PASS: Found evidence of", functions_found, "assessment functions"))
      } else {
        return("PASS")
      }
    } else {
      return("FAIL: Insufficient evidence of data assessment")
    }
    
  }, error = function(e) {
    return(paste("FAIL:", e$message))
  })
}

test_missing_value_analysis <- function() {
  tryCatch({
    score <- 0
    max_score <- 15
    issues <- c()
    
    code_info <- get("code_info", envir = .GlobalEnv)
    all_code <- paste(sapply(code_info$patterns, function(p) p$code), collapse = "\n")
    
    # Test 1: Look for missing value calculation patterns
    if (grepl("total_missing.*<-|sum\\(is\\.na", all_code)) {
      score <- score + 3
    } else {
      issues <- c(issues, "No evidence of total missing value calculation")
    }
    
    if (grepl("missing_per_column.*<-|colSums\\(is\\.na", all_code)) {
      score <- score + 3
    } else {
      issues <- c(issues, "No evidence of missing per column calculation")
    }
    
    # Test 2: Look for missing value removal patterns
    if (grepl("sales_removed_na.*<-", all_code)) {
      score <- score + 2
      if (grepl("complete\\.cases|na\\.omit|drop_na", all_code)) {
        score <- score + 2
      } else {
        issues <- c(issues, "sales_removed_na created but no clear removal method")
      }
    } else {
      issues <- c(issues, "No evidence of missing value removal dataset creation")
    }
    
    # Test 3: Look for mode function and imputation patterns
    if (grepl("get_mode.*function|mode.*<-.*function", all_code)) {
      score <- score + 2
    } else {
      issues <- c(issues, "No evidence of mode function creation")
    }
    
    if (grepl("sales_imputed.*<-", all_code)) {
      score <- score + 2
      if (grepl("get_mode\\(|mean\\(.*na\\.rm|median\\(.*na\\.rm", all_code)) {
        score <- score + 1
      }
    } else {
      issues <- c(issues, "No evidence of imputation dataset creation")
    }
    
    if (score >= max_score * 0.6) {
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

test_outlier_detection <- function() {
  tryCatch({
    score <- 0
    max_score <- 15
    issues <- c()
    
    # Test 1: Check for IQR calculation variables
    outlier_vars <- list(
      Q1_sales = "Q1_sales",
      Q3_sales = "Q3_sales", 
      IQR_sales = "IQR_sales",
      upper_threshold = "upper_threshold",
      lower_threshold = "lower_threshold"
    )
    
    for (var_name in names(outlier_vars)) {
      if (exists(var_name)) {
        var_value <- get(var_name)
        if (is.numeric(var_value) && !is.na(var_value) && length(var_value) == 1) {
          score <- score + 1
        } else {
          issues <- c(issues, paste(var_name, "should be a single numeric value"))
        }
      } else {
        issues <- c(issues, paste(var_name, "not found"))
      }
    }
    
    # Test 2: Validate IQR calculations are reasonable
    if (exists("Q1_sales") && exists("Q3_sales") && exists("IQR_sales")) {
      if (get("Q3_sales") > get("Q1_sales") && 
          abs(get("IQR_sales") - (get("Q3_sales") - get("Q1_sales"))) < 0.01) {
        score <- score + 2
      } else {
        issues <- c(issues, "IQR calculations appear incorrect")
      }
    }
    
    # Test 3: Check for outliers data frame
    if (exists("outliers")) {
      outliers_data <- get("outliers")
      if (is.data.frame(outliers_data)) {
        score <- score + 2
        # Should have the same columns as original data
        if (exists("messy_sales") && all(names(outliers_data) %in% names(messy_sales))) {
          score <- score + 1
        }
      } else {
        issues <- c(issues, "outliers should be a data frame")
      }
    } else {
      issues <- c(issues, "outliers data frame not found")
    }
    
    # Test 4: Check for boxplot (optional, worth fewer points)
    if (exists("boxplot_sales")) {
      # Check if it's a ggplot object
      if (inherits(get("boxplot_sales"), "ggplot")) {
        score <- score + 1
      }
    }
    
    # Test 5: Check for outlier treatment datasets
    outlier_datasets <- c("sales_outliers_removed", "sales_outliers_capped")
    
    for (dataset_name in outlier_datasets) {
      if (exists(dataset_name)) {
        dataset <- get(dataset_name)
        if (is.data.frame(dataset) && nrow(dataset) > 0) {
          score <- score + 2
          
          # Verify outlier treatment worked appropriately
          if (dataset_name == "sales_outliers_removed" && exists("sales_imputed")) {
            original_data <- get("sales_imputed")
            if (nrow(dataset) < nrow(original_data)) {
              score <- score + 1
            } else {
              issues <- c(issues, "sales_outliers_removed should have fewer rows")
            }
          } else if (dataset_name == "sales_outliers_capped") {
            # Check if extreme values were capped
            if (exists("upper_threshold") && exists("lower_threshold")) {
              upper_thresh <- get("upper_threshold")
              lower_thresh <- get("lower_threshold")
              sales_values <- dataset$Sales_Amount
              if (all(sales_values >= lower_thresh & sales_values <= upper_thresh, na.rm = TRUE)) {
                score <- score + 1
              } else {
                issues <- c(issues, "sales_outliers_capped values not properly capped")
              }
            }
          }
        } else {
          issues <- c(issues, paste(dataset_name, "is not a proper data frame"))
        }
      } else {
        issues <- c(issues, paste(dataset_name, "not found"))
      }
    }
    
    if (score >= max_score * 0.6) {
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

test_final_dataset_choice <- function() {
  tryCatch({
    score <- 0
    max_score <- 10
    issues <- c()
    
    # Check if a final dataset was chosen
    if (exists("final_dataset")) {
      dataset <- get("final_dataset")
      if (is.data.frame(dataset) && nrow(dataset) > 0) {
        score <- score + 5
        
        # Check if it's one of the expected cleaned datasets
        dataset_names <- c("sales_removed_na", "sales_imputed", "sales_outliers_removed", "sales_outliers_capped")
        is_valid_choice <- FALSE
        
        for (expected_name in dataset_names) {
          if (exists(expected_name)) {
            expected_dataset <- get(expected_name)
            if (identical(dataset, expected_dataset)) {
              is_valid_choice <- TRUE
              score <- score + 3
              break
            }
          }
        }
        
        if (!is_valid_choice) {
          issues <- c(issues, "final_dataset should be one of the cleaned datasets")
        }
        
        # Check for comparison summary
        if (exists("comparison_summary")) {
          summary_data <- get("comparison_summary")
          if (is.data.frame(summary_data) && nrow(summary_data) > 0) {
            score <- score + 2
          } else {
            issues <- c(issues, "comparison_summary exists but is not a proper data frame")
          }
        } else {
          issues <- c(issues, "comparison_summary not found")
        }
      } else {
        issues <- c(issues, "final_dataset is not a proper data frame or is empty")
      }
    } else {
      issues <- c(issues, "final_dataset not found")
    }
    
    if (score >= max_score * 0.6) {
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
test_reflection_questions <- function() {
  tryCatch({
    # Get the notebook content
    notebook_path <- get("notebook_file", envir = .GlobalEnv)
    notebook <- fromJSON(notebook_path, simplifyVector = FALSE)
    
    # Look for reflection question responses
    reflection_responses <- 0
    total_questions <- 4  # We now have 4 reflection questions
    
    # Search for markdown cells with actual responses (not just "[Write your response here]")
    for (cell in notebook$cells) {
      if (cell$cell_type == "markdown") {
        cell_content <- paste(cell$source, collapse = " ")
        
        # Check if this cell contains a student response to reflection questions
        if (grepl("\\*\\*YOUR ANSWER:\\*\\*", cell_content)) {
          # Look for actual content after "YOUR ANSWER:"
          content_after_answer <- gsub(".*\\*\\*YOUR ANSWER:\\*\\*", "", cell_content)
          content_after_answer <- trimws(gsub("\\[.*?\\]", "", content_after_answer))
          
          # If there's substantial content (more than just placeholder text)
          if (nchar(content_after_answer) > 30 && 
              !grepl("Write your.*response here|TODO|FIXME", content_after_answer)) {
            reflection_responses <- reflection_responses + 1
          }
        }
      }
    }
    
    if (reflection_responses >= total_questions) {
      return("PASS")
    } else if (reflection_responses >= total_questions * 0.75) {
      return(paste("PARTIAL PASS:", reflection_responses, "of", total_questions, "questions answered"))
    } else {
      return("FAIL: Insufficient reflection questions answered with substantive content")
    }
    
  }, error = function(e) {
    return(paste("FAIL:", e$message))
  })
}

test_packages_loaded <- function() {
  tryCatch({
    if (!"tidyverse" %in% (.packages())) return("FAIL: tidyverse not loaded")
    return("PASS")
  }, error = function(e) {
    return(paste("FAIL:", e$message))
  })
}

# Main execution
main <- function() {
  args <- commandArgs(trailingOnly = TRUE)
  if (length(args) < 2) {
    cat("Usage: autograder.R <notebook_path> <test_name>\n")
    cat("Available tests: dataset_creation, data_assessment, missing_values, outlier_detection, final_dataset, reflection, packages, all\n")
    quit(status = 1)
  }
  
  notebook_path <- args[1]
  test_name <- args[2]
  
  # Store notebook path for access by test functions
  assign("notebook_file", notebook_path, envir = .GlobalEnv)
  
  # Extract code patterns from notebook (without executing)
  tryCatch({
    code_info <- extract_r_code(notebook_path)
    
    # Store code info for analysis by test functions
    assign("code_info", code_info, envir = .GlobalEnv)
    
    # For safety, only execute basic library loading
    if (grepl("library\\(tidyverse\\)", code_info$code)) {
      suppressMessages(library(tidyverse, warn.conflicts = FALSE, quietly = TRUE))
    }
    
  }, error = function(e) {
    cat("FAIL: Error analyzing notebook code -", e$message, "\n")
    quit(status = 1)
  })
  
  # Run the specified test or all tests
  if (test_name == "all") {
    # Run all tests and provide summary
    tests <- list(
      "packages" = test_packages_loaded(),
      "dataset_creation" = test_dataset_creation(),
      "data_assessment" = test_data_assessment(),
      "missing_values" = test_missing_value_analysis(),
      "outlier_detection" = test_outlier_detection(),
      "final_dataset" = test_final_dataset_choice(),
      "reflection" = test_reflection_questions()
    )
    
    passed <- 0
    total <- length(tests)
    
    cat("=== COMPREHENSIVE AUTOGRADING RESULTS ===\n")
    for (test_name in names(tests)) {
      result <- tests[[test_name]]
      status <- if (startsWith(result, "PASS")) "✓" else if (startsWith(result, "PARTIAL")) "~" else "✗"
      cat(sprintf("%s %s: %s\n", status, test_name, result))
      if (startsWith(result, "PASS") || startsWith(result, "PARTIAL PASS")) {
        passed <- passed + 1
      }
    }
    
    cat(sprintf("\nSUMMARY: %d/%d tests passed\n", passed, total))
    
    if (passed >= total * 0.75) {
      cat("OVERALL: PASS\n")
      quit(status = 0)
    } else {
      cat("OVERALL: FAIL\n")
      quit(status = 1)
    }
  } else {
    # Run individual test
    result <- switch(test_name,
      "dataset_creation" = test_dataset_creation(),
      "data_assessment" = test_data_assessment(),
      "missing_values" = test_missing_value_analysis(),
      "outlier_detection" = test_outlier_detection(),
      "final_dataset" = test_final_dataset_choice(),
      "reflection" = test_reflection_questions(),
      "packages" = test_packages_loaded(),
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
}

test_data_assessment <- function() {
  tryCatch({
    score <- 0
    max_score <- 10
    issues <- c()
    
    # Look for evidence that students performed data assessment
    code_info <- get("code_info", envir = .GlobalEnv)
    all_code <- paste(sapply(code_info$patterns, function(p) p$code), collapse = "\n")
    
    assessment_functions <- c("head\\(", "str\\(", "summary\\(", "dim\\(", "nrow\\(", "ncol\\(", "names\\(")
    functions_found <- 0
    
    for (func_pattern in assessment_functions) {
      if (grepl(func_pattern, all_code)) {
        functions_found <- functions_found + 1
        score <- score + 1
      }
    }
    
    # Bonus points for additional assessment techniques
    advanced_functions <- c("colSums\\(is\\.na", "is\\.na\\(", "class\\(", "View\\(")
    for (func_pattern in advanced_functions) {
      if (grepl(func_pattern, all_code)) {
        score <- score + 1
      }
    }
    
    if (functions_found >= 3) {
      score <- score + 2  # Bonus for comprehensive assessment
    }
    
    if (score >= max_score * 0.5) {
      if (functions_found < 3) {
        return(paste("PARTIAL PASS: Found evidence of", functions_found, "assessment functions"))
      } else {
        return("PASS")
      }
    } else {
      return("FAIL: Insufficient evidence of data assessment")
    }
    
  }, error = function(e) {
    return(paste("FAIL:", e$message))
  })
}

test_outlier_detection <- function() {
  tryCatch({
    score <- 0
    max_score <- 15
    issues <- c()
    
    code_info <- get("code_info", envir = .GlobalEnv)
    all_code <- paste(sapply(code_info$patterns, function(p) p$code), collapse = "\n")
    
    # Test 1: Look for IQR calculation patterns
    outlier_vars <- c("Q1_sales", "Q3_sales", "IQR_sales", "upper_threshold", "lower_threshold")
    found_vars <- 0
    
    for (var_name in outlier_vars) {
      if (grepl(paste0(var_name, ".*<-"), all_code)) {
        found_vars <- found_vars + 1
        score <- score + 1
      }
    }
    
    # Test 2: Look for quantile function usage
    if (grepl("quantile\\(.*0\\.25|quantile\\(.*0\\.75", all_code)) {
      score <- score + 2
    } else {
      issues <- c(issues, "No evidence of quantile calculations")
    }
    
    # Test 3: Look for outlier identification
    if (grepl("outliers.*<-", all_code)) {
      score <- score + 2
      if (grepl("upper_threshold|lower_threshold", all_code)) {
        score <- score + 1
      }
    } else {
      issues <- c(issues, "No evidence of outlier identification")
    }
    
    # Test 4: Look for visualization (boxplot)
    if (grepl("boxplot|geom_boxplot|ggplot", all_code)) {
      score <- score + 1
    }
    
    # Test 5: Look for outlier treatment datasets
    outlier_datasets <- c("sales_outliers_removed", "sales_outliers_capped")
    
    for (dataset_name in outlier_datasets) {
      if (grepl(paste0(dataset_name, ".*<-"), all_code)) {
        score <- score + 2
        
        # Look for treatment methods
        if (dataset_name == "sales_outliers_removed" && grepl("filter\\(|subset\\(", all_code)) {
          score <- score + 1
        } else if (dataset_name == "sales_outliers_capped" && grepl("ifelse\\(|pmin\\(|pmax\\(", all_code)) {
          score <- score + 1
        }
      } else {
        issues <- c(issues, paste(dataset_name, "not found in code"))
      }
    }
    
    if (score >= max_score * 0.6) {
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

test_final_dataset_choice <- function() {
  tryCatch({
    score <- 0
    max_score <- 10
    issues <- c()
    
    code_info <- get("code_info", envir = .GlobalEnv)
    all_code <- paste(sapply(code_info$patterns, function(p) p$code), collapse = "\n")
    
    # Check if a final dataset was chosen
    if (grepl("final_dataset.*<-", all_code)) {
      score <- score + 5
      
      # Look for comparison summary
      if (grepl("comparison_summary.*<-|data\\.frame", all_code)) {
        score <- score + 3
      } else {
        issues <- c(issues, "No evidence of comparison summary creation")
      }
      
      # Look for evidence of thoughtful choice
      dataset_options <- c("sales_removed_na", "sales_imputed", "sales_outliers_removed", "sales_outliers_capped")
      if (any(sapply(dataset_options, function(opt) grepl(opt, all_code)))) {
        score <- score + 2
      } else {
        issues <- c(issues, "No evidence of choosing from cleaned datasets")
      }
    } else {
      issues <- c(issues, "No evidence of final dataset selection")
    }
    
    if (score >= max_score * 0.6) {
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
    code_info <- get("code_info", envir = .GlobalEnv)
    all_code <- paste(sapply(code_info$patterns, function(p) p$code), collapse = "\n")
    
    if (grepl("library\\(tidyverse\\)", all_code)) {
      return("PASS")
    } else {
      return("FAIL: No evidence of tidyverse library loading")
    }
  }, error = function(e) {
    return(paste("FAIL:", e$message))
  })
}

# Run main function
main()
