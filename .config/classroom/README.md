# GitHub Classroom Configuration

This directory contains the autograding configuration files that are hidden from students.

## Files in this directory:

- `tests.json` - Autograding test configuration (renamed from `autograding.json`)
- `workflow.yml` - GitHub Actions workflow for running tests
- `setup-autograding.sh` - Script to restore autograding files for GitHub Classroom

## For Instructors:

### Setting up GitHub Classroom:

1. **Before importing to GitHub Classroom**, run the setup script:
   ```bash
   bash .config/classroom/setup-autograding.sh
   ```

2. **Import the repository** into GitHub Classroom as a template

3. **Enable autograding** in your assignment settings

4. **Students receive repositories** without visible autograding files

### ⚠️ Important: Template Repository Workflows

This template repository has no active GitHub Actions workflows to prevent unnecessary runs and failed autograding emails. Workflows are only created when you run the setup script for GitHub Classroom.

If you receive autograding failure emails from the template repository, it means workflows ran before being properly disabled. These can be safely ignored - they won't affect student repositories.

### Why hide these files?

- Prevents students from seeing test criteria and potentially cheating
- Keeps the student repository clean and focused on the assignment
- Maintains the integrity of automated grading

### Modifying tests:

To change the autograding tests:

1. Edit `tests.json` in this directory
2. Run `setup-autograding.sh` to update the GitHub configuration
3. Commit and push changes

### Test Configuration:

The current tests check for:
- R environment functionality
- Presence of required notebook file
- Basic notebook content (data import code)

Students will see test results but not the specific test criteria.
