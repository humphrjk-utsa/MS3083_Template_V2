#!/usr/bin/env Rscript

# Simple reflection question checker
# Only checks markdown content, doesn't execute any R code

library(jsonlite)

check_reflection_questions <- function(notebook_path) {
  if (!file.exists(notebook_path)) {
    return("FAIL: Notebook file not found")
  }
  
  notebook <- fromJSON(notebook_path, simplifyVector = FALSE)
  
  # Look for reflection question responses
  reflection_responses <- 0
  total_questions <- 3  # We know there are 3 questions
  response_lengths <- c()
  
  # Search for markdown cells with actual responses
  for (cell in notebook$cells) {
    if (cell$cell_type == "markdown") {
      cell_content <- paste(cell$source, collapse = " ")
      
      # Check if this cell contains a student response to reflection questions
      if (grepl("\\*\\*Your Answer:\\*\\*", cell_content)) {
        # Look for actual content after "Your Answer:"
        content_after_answer <- gsub(".*\\*\\*Your Answer:\\*\\*", "", cell_content)
        content_after_answer <- trimws(gsub("\\[.*?\\]", "", content_after_answer))
        
        # Remove common placeholder text
        content_after_answer <- gsub("Write your response here|TODO|FIXME|\\[.*\\]", "", content_after_answer)
        content_after_answer <- trimws(content_after_answer)
        
        # If there's substantial content
        if (nchar(content_after_answer) > 20) {
          reflection_responses <- reflection_responses + 1
          response_lengths <- c(response_lengths, nchar(content_after_answer))
        }
      }
    }
  }
  
  # Scoring
  if (reflection_responses >= total_questions) {
    avg_length <- mean(response_lengths)
    if (avg_length > 100) {
      return("PASS")
    } else {
      return("PARTIAL PASS: All questions answered but responses are brief")
    }
  } else if (reflection_responses > 0) {
    return(paste("PARTIAL PASS:", reflection_responses, "of", total_questions, "questions answered"))
  } else {
    return("FAIL: No reflection questions answered with substantive content")
  }
}

# Main execution
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1) {
  cat("Usage: reflection_checker.R <notebook_path>\n")
  quit(status = 1)
}

result <- check_reflection_questions(args[1])
cat(result, "\n")

# Exit with appropriate status
if (startsWith(result, "PASS") || startsWith(result, "PARTIAL PASS")) {
  quit(status = 0)
} else {
  quit(status = 1)
}
