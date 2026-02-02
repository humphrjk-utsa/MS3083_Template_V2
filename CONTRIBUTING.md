# How to Submit Your Assignment to GitHub Classroom

## 📚 Simple Submission Guide (No Command Line Required!)

### Step 1: Complete Your Assignment
1. **Open your notebook**: `assignment/Homework/homework_lesson_1.ipynb`
2. **Fill in your information** at the top (name, date)
3. **Complete all sections** (Parts 1, 2, and 3)
4. **Run all cells** to show your outputs (Cell → Run All)
5. **Save your work** (Ctrl+S or File → Save)

### Step 2: Submit Using VS Code Interface (Easy Way!)

**No need to use terminal commands! Just click buttons in VS Code:**

1. **Find Source Control** in VS Code:
   - Look at the left sidebar
   - Click the icon that looks like a tree branch (Source Control)

2. **Stage your file**:
   - You'll see `homework_lesson_1.ipynb` in the changes list
   - Click the **"+"** button next to it

3. **Add a commit message**:
   - Type in the text box: `Submit homework lesson 1 - [Your Name]`

4. **Commit your changes**:
   - Click the **"Commit"** button

5. **Push to GitHub Classroom**:
   - Click **"Sync Changes"** or **"Push"** button
   - This submits your assignment!

### Step 3: Verify Your Submission

1. **Check VS Code** - you should see "Successfully pushed" or similar message

2. **Visit your GitHub repository**:
   - Open a new browser tab
   - Go to your assignment repository 
   - Navigate to `assignment/Homework/`
   - Click on `homework_lesson_1.ipynb`
   - Verify you can see your completed work with outputs

### 🚨 Common Issues and Solutions

**"I don't see Source Control":**
- Look for the tree branch icon in the left sidebar
- If missing, go to View → Source Control

**"No changes detected":**
- Make sure you saved your notebook first (Ctrl+S)
- Check that you actually made changes to the file

**"My file isn't in the changes list":**
- Save the file again (Ctrl+S)
- Try refreshing VS Code (F5)

**"Sync failed":**
- Try clicking "Pull" first, then "Push" again
- Contact your instructor if problems persist

### � Submission Deadline Reminders

- **Submit before the deadline** - GitHub Classroom tracks submission timestamps
- **You can submit multiple times** - your latest submission before the deadline counts
- **Always verify your submission** - check that your work appears on GitHub
- **Don't wait until the last minute** - allow time for technical issues

## Troubleshooting

### "Permission denied" or authentication errors
- Make sure you're working in the GitHub Codespace
- Try: `git config --global credential.helper store`

### "Nothing to commit"
- Make sure your file is saved
- Check that you're in the right directory: `pwd`
- Your file should be in `assignment/Homework/`

### Code doesn't run
- Check for typos in variable names
- Make sure you loaded required packages in the first cells
- Verify data file paths are correct
- Try restarting the R kernel: Kernel → Restart Kernel

### Notebook won't save
- Make sure you have write permissions
- Try Ctrl+S (or Cmd+S) to force save
- Check disk space isn't full

### Still having issues?
Contact your instructor with:
- What you were trying to do
- The exact error message
- A screenshot if helpful
