# Homework Assignment - Lesson 1: Introduction to R

**Due Date:** [Your instructor will specify]  
**Points:** 30 points total

**📋 SUBMISSION INSTRUCTIONS**: See [GITHUB_CLASSROOM_SUBMISSION.md](../../GITHUB_CLASSROOM_SUBMISSION.md) for complete submission guide.

**Instructions:**

*   Complete the following tasks in the Jupyter notebook `homework_lesson_1.ipynb` using the R kernel.
*   The notebook template is already created for you in this folder.
*   Add your code and markdown explanations in the appropriate cells.
*   Make sure to run all cells to show your output.
*   Commit and push your completed notebook to submit.

⚠️ **Important:** The data files (`sales_data.csv` and `customer_feedback.xlsx`) are already provided in the `data/` folder at the root of this repository.

---

## Part 1: Setting Up Your Environment and Importing Data

1.  **Working Directory:**
    *   You are already in the correct Codespaces environment - no need to create folders.
    *   Verify your current working directory using `getwd()`.
    *   Your working directory should be `/workspaces/Data-Management-Assignment-1-Intro-to-R`

2.  **Package Installation & Loading:**
    *   The required packages are already installed in this environment.
    *   Load `tidyverse` and `readxl` packages into your R session.

3.  **Data Import - CSV:**
    *   The `sales_data.csv` file is located in the `data/` folder.
    *   Import it using: `sales_df <- read_csv("data/sales_data.csv")`

4.  **Data Import - Excel:**
    *   The `customer_feedback.xlsx` file is located in the `data/` folder.
    *   Import the `Ratings` sheet: `ratings_df <- read_excel("data/customer_feedback.xlsx", sheet = "Ratings")`
    *   Import the `Comments` sheet: `comments_df <- read_excel("data/customer_feedback.xlsx", sheet = "Comments")`

---

## Part 2: Basic Data Inspection

Perform the following inspection tasks for each of the three data frames you imported (`sales_df`, `ratings_df`, `comments_df`). For each data frame, provide the R code and the output, along with a brief interpretation of what you observe.

1.  **First Few Rows:** Display the first 10 rows of each data frame.
2.  **Structure:** Display the structure (data types, number of observations/variables) of each data frame.
3.  **Summary Statistics:** Display summary statistics for each data frame.
4.  **Visual Inspection (Optional, but Recommended):** If your VS Code setup allows, use `View()` to open each data frame in the data viewer and briefly describe any immediate observations (e.g., presence of missing values, unexpected values).

---

## 📋 Submission Checklist

Before submitting your assignment, make sure you have:

- [ ] Completed the Jupyter notebook `homework_lesson_1.ipynb` in this folder
- [ ] Run all cells to show output (Cell → Run All)
- [ ] Added your name and date at the top of the notebook
- [ ] Completed all tasks in Parts 1, 2, and 3
- [ ] Added markdown explanations and observations
- [ ] Answered all reflection questions
- [ ] Saved the notebook (Ctrl+S or Cmd+S)
- [ ] Committed your changes: `git add assignment/Homework/homework_lesson_1.ipynb && git commit -m "Complete assignment 1"`
- [ ] Pushed to GitHub Classroom: `git push origin main`
- [ ] Verified your submission appears on GitHub online

## 🚀 How to Submit to GitHub Classroom (VS Code Interface - No Commands!)

### Quick Submission Steps:

1. **Complete and save your notebook** (Ctrl+S)

2. **Use VS Code Source Control** (no terminal needed!):
   - Click the **Source Control** icon in left sidebar (tree branch symbol)
   - Click **"+"** next to `homework_lesson_1.ipynb` to stage your file
   - Type a commit message: `Submit homework lesson 1 - [Your Name]`
   - Click **"Commit"** button
   - Click **"Sync Changes"** or **"Push"** button

3. **Verify submission:**
   - Go to your GitHub repository in a web browser
   - Navigate to `assignment/Homework/`
   - Click on your notebook to see your completed work
   - Check the commit timestamp to confirm it's recent

### ✅ Submission Confirmation
You'll know your assignment was submitted successfully when:
- VS Code shows "Successfully pushed" or "Everything up-to-date"
- Your notebook appears in your GitHub repository online
- The file shows your completed code and outputs
- You can see a recent "Last commit" timestamp

**🆘 Need help?** See [GITHUB_CLASSROOM_SUBMISSION.md](../../GITHUB_CLASSROOM_SUBMISSION.md) for detailed step-by-step instructions.

## 🆘 Getting Help

If you encounter issues:
1. Check that your file is saved in the correct location (`assignment/Homework/`)
2. Verify your code runs without errors in the R console
3. Make sure you've committed and pushed your changes
4. Contact your instructor if you need assistance

**Good luck with your assignment! 🎯**

## Part 3: Reflection Questions

Answer the following questions in your submission document:

1.  Based on your inspection of `sales_df`, what are the data types of the `Date` and `Amount` columns? Are these data types appropriate for typical business analytics tasks involving sales data? Explain why or why not.
2.  Looking at `ratings_df` and `comments_df`, do you notice any potential issues (e.g., missing values, inconsistent data types) that might need to be addressed in future data wrangling steps? (No need to fix them, just identify them).
3.  Why is it important to perform initial data inspection immediately after importing data? What kind of problems can it help you identify early on?
4.  Briefly explain the difference between `install.packages()` and `library()` in R. When would you use each function?

---

**Submission Checklist:**

*   [ ] R script Notebook file with all code and outputs.
*   [ ] Answers to reflection questions included in the document or as a separate text file.
*   [ ] All necessary data files (`sales_data.csv`, `customer_feedback.xlsx`) are accessible (e.g., in the same directory or clearly referenced).

Good luck!


