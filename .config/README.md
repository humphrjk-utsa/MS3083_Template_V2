# Instructor Configuration Files

This `.config` folder contains files that are hidden from students but accessible to instructors and the autograding system.

## Files in this directory:

- `autograder.R` - Main autograding script that tests student homework submissions
- `test_autograder.R` - Tests for the autograder functionality
- `test_homework_setup.R` - Setup tests for homework environment

## GitHub Classroom Integration:

The autograding configuration is defined in `.github/classroom/autograding.json` and uses the workflow in `.github/workflows/classroom.yml`.

## Running the Autograder Manually:

To test student submissions manually:
```bash
Rscript .config/autograder.R assignment/Homework/homework_lesson_2_data_cleaning.ipynb all
```

## Test Categories:
1. Package loading test (5 points)
2. Dataset creation test (10 points)
3. Data assessment test (10 points)
4. Missing values analysis test (15 points)
5. Outlier detection test (15 points)
6. Final dataset choice test (10 points)
7. Reflection questions test (10 points)
8. Comprehensive test (25 points)

Total: 100 points
