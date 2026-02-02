# Data Management Assignment## 📝 Assignment Instructions

Your assignment is located in the `assignment/Homework/` folder. Complete all tasks in the README file there.

**🚨 IMPORTANT**: For detailed submission instructions, see [GITHUB_CLASSROOM_SUBMISSION.md](GITHUB_CLASSROOM_SUBMISSION.md) Introduction to R

Welcome to your first data management assignment! This repository contains a complete R environment ready for data analysis.

## 🚀 Getting Started

1. **Accept the Assignment** - You should have received this via GitHub Classroom
2. **Open in Codespaces** - Click the green "Code" button → "Codespaces" → "Create codespace"
3. **Wait for setup** - Takes 5-10 minutes for first-time setup
4. **Complete your assignment** - Follow the instructions in `assignment/Homework/README.md`
5. **Submit your work** - Commit and push your changes (instructions below)

## 🎯 What You Get

### Instant Data Science Environment
- **Python 3.12** with pandas, numpy, matplotlib, seaborn, scikit-learn
- **R 4.3** with tidyverse, ggplot2, dplyr, data analysis packages  
- **Jupyter Lab** with Python and R kernels
- **PostgreSQL** database ready to use
- **VS Code** with all data science extensions

### Zero Manual Setup
- ✅ No password prompts
- ✅ No configuration needed
- ✅ Database works immediately
- ✅ All packages pre-installed
- ✅ Students can start coding right away

## � Assignment Instructions

Your assignment is located in the `assignment/Homework/` folder. Complete all tasks in the README file there.

## 📁 Repository Structure

```
├── assignment/
│   └── Homework/           # YOUR ASSIGNMENT IS HERE
│       ├── README.md       # Assignment instructions
│       └── [your files]    # Create your R script or R Markdown here
├── data/                   # Sample datasets for your assignment
├── notebooks/              # Example notebooks (for reference)
├── databases/              # Pre-loaded databases
└── scripts/                # Environment setup scripts (don't modify)
```

## 💾 How to Submit Your Assignment to GitHub Classroom

### Simple 3-Step Process (No Command Line Required!)

#### Step 1: Complete Your Work
- Open the Jupyter notebook `assignment/Homework/homework_lesson_1.ipynb`
- Complete all code cells and markdown responses
- Run all cells to show your output (Cell → Run All)
- Save the notebook (Ctrl+S or File → Save)

#### Step 2: Submit Using VS Code Interface
1. **Click the Source Control icon** in the left sidebar (looks like a tree branch)
2. **Click the "+" button** next to your notebook file to stage it
3. **Type a message** like "Submit homework 1 - [Your Name]"
4. **Click "Commit"** to save your changes
5. **Click "Sync Changes"** or "Push" to submit to GitHub Classroom

#### Step 3: Verify Your Submission
1. Open your GitHub repository in a web browser
2. Navigate to `assignment/Homework/`
3. Click on `homework_lesson_1.ipynb` to verify your completed work appears
4. Check that all your outputs are visible

### ⚠️ Important Notes
- **No git commands needed** - use the VS Code buttons instead!
- **Multiple submissions allowed** - you can submit multiple times before the deadline
- **Always verify online** - check your GitHub repository to confirm submission
- **Save first!** - always save your notebook before submitting

**📖 Need detailed help?** See [GITHUB_CLASSROOM_SUBMISSION.md](GITHUB_CLASSROOM_SUBMISSION.md) for step-by-step instructions with screenshots.

## 🧪 Environment Details

### Python Environment
All packages installed via conda:
- Data: pandas, numpy, polars
- Visualization: matplotlib, seaborn, plotly
- Machine Learning: scikit-learn, scipy
- Database: sqlalchemy, psycopg2
- Jupyter: jupyter, ipython, kernels

### R Environment  
All packages via conda:
- Core: tidyverse, dplyr, ggplot2, tidyr, readr
- Database: DBI, RPostgreSQL
- Jupyter: IRkernel for R notebooks

### Database
- **PostgreSQL** server running locally
- **Database name:** `vscode`
- **Username:** `vscode` 
- **Connection:** Automatic via environment variables

## 📚 For Students

### Getting Started
1. Create a new Jupyter notebook in the `notebooks/` folder
2. Choose Python or R kernel
3. Start analyzing data immediately!

### Sample Data
- `data/WestRoxbury.csv` - Real estate data for analysis
- `data/sample.csv` - Basic sample dataset
- Additional datasets in `data/` folder

### Example Notebooks
- `notebooks/getting-started.ipynb` - Introduction examples
- `notebooks/westroxbury-analysis.ipynb` - Real data analysis
- `notebooks/r-kernel-diagnostic.ipynb` - R environment and database test

## 🛠️ For Instructors

### Adding Assignments
1. Create new folder in `assignments/`
2. Add Jupyter notebook with exercises
3. Include any needed data files
4. Students will have immediate access

### Database Setup
PostgreSQL is pre-configured and ready. To add sample data:
```sql
-- Connect to database (automatic in notebooks)
-- Add your tables and sample data
```

### Environment Verification
Run the test script to verify everything works:
```bash
python scripts/test_setup.py
```

## 🎓 Zero-Touch Philosophy

This environment follows a **zero-touch approach**:
- Students never see password prompts
- No manual installation or configuration
- All tools work immediately after Codespace creation
- Focus on learning, not setup

## 📋 Technical Notes

The devcontainer uses:
- **Base:** Jupyter datascience-notebook (official image)
- **User:** Transitions from `jovyan` to `vscode` during setup
- **Setup:** Automated user transition with passwordless sudo
- **Database:** PostgreSQL with pre-configured user and database
- **Extensions:** Complete VS Code data science extension pack

This provides a professional data science development environment that "just works" for education.

---

## 👩‍🏫 For Instructors

This repository is configured as a GitHub Classroom template with hidden autograding. To set up:

1. **Enable autograding** before importing to GitHub Classroom:
   ```bash
   bash .config/classroom/setup-autograding.sh
   ```

2. **Import to GitHub Classroom** as a template repository

3. **Students receive clean repositories** without visible autograding configuration

📖 See `.config/classroom/README.md` for detailed instructor setup instructions.
