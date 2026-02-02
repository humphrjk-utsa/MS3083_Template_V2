# 📚 AI Grading Assistant

A simple, user-friendly tool for professors to automatically grade Jupyter notebook submissions.

![Python](https://img.shields.io/badge/Python-3.8+-blue.svg)
![Streamlit](https://img.shields.io/badge/Streamlit-1.28+-red.svg)

## ✨ Features

- **📤 Easy Upload**: Upload a ZIP file containing multiple student Jupyter notebooks
- **🤖 AI-Powered Grading**: Automatic analysis of code quality, correctness, and documentation
- **📊 Detailed Feedback**: Individual feedback for each student with strengths and areas for improvement
- **📈 Analytics**: Grade distribution charts and class statistics
- **💾 Export Options**: Download results as CSV, JSON, or Markdown feedback reports
- **⚙️ Customizable Criteria**: Adjust grading weights through the sidebar

## 🚀 Quick Start

### 1. Install Dependencies

```bash
cd grading-assistant
pip install -r requirements.txt
```

### 2. Run the Application

```bash
streamlit run app.py
```

### 3. Open in Browser

The app will automatically open in your browser at `http://localhost:8501`

## 📋 How to Use

1. **Prepare Submissions**: Collect all student Jupyter notebooks (.ipynb files) into a folder
2. **Create ZIP**: Compress the folder into a ZIP file
3. **Upload**: Click the upload area and select your ZIP file
4. **Review**: Check the detected notebooks in the list
5. **Grade**: Click "Grade All Notebooks"
6. **Export**: Download the results in your preferred format

## 📊 Grading Criteria

The assistant evaluates notebooks on 5 criteria:

| Criterion | Default Points | Description |
|-----------|---------------|-------------|
| Code Correctness | 40 | Code runs without errors and produces output |
| Code Quality | 20 | Clean code following best practices |
| Documentation | 15 | Markdown cells and code comments |
| Completeness | 15 | All cells executed with required outputs |
| Creativity & Insight | 10 | Visualizations and advanced techniques |

You can adjust these weights in the sidebar before grading.

## 📁 File Structure

```
grading-assistant/
├── app.py              # Main Streamlit web application
├── grading_engine.py   # AI grading logic and scoring
├── notebook_parser.py  # Jupyter notebook parsing utilities
├── requirements.txt    # Python dependencies
└── README.md          # This file
```

## 💡 Tips for Best Results

### For Professors:
- Ask students to **run all cells** before submitting
- Use consistent naming conventions (e.g., `lastname_firstname_hw1.ipynb`)
- Provide a rubric that aligns with the grading criteria

### For Students:
- Clear error cells before submission
- Add markdown cells explaining your approach
- Include comments in complex code
- Make sure all outputs are visible

## 🔧 Customization

### Adding Custom Criteria

Edit `grading_engine.py` and modify the `DEFAULT_CRITERIA` list:

```python
GradingCriteria(
    name="Your Criterion",
    max_points=20,
    description="What this measures",
    rubric=["Item 1", "Item 2"]
)
```

### Modifying Grading Logic

The grading logic is in the `_score_criterion()` function in `grading_engine.py`. 
You can add custom analysis for specific assignment types.

## 📤 Export Formats

- **CSV**: Simple spreadsheet with scores (great for gradebooks)
- **JSON**: Detailed data including all feedback and criteria scores
- **Markdown**: Formatted feedback report for sharing with students

## 🛠️ Technical Details

- Built with **Streamlit** for the web interface
- Uses **Pandas** for data manipulation
- Pure Python with no external AI API dependencies
- Notebook parsing handles various Jupyter formats

## ❓ Troubleshooting

**No notebooks found:**
- Ensure files have `.ipynb` extension
- Check that ZIP isn't corrupted
- Avoid nested ZIP files

**Low scores unexpectedly:**
- Make sure students ran all cells
- Check for hidden errors in cell outputs
- Verify notebooks aren't empty

**App won't start:**
- Run `pip install -r requirements.txt` again
- Check Python version (3.8+ required)

## 📄 License

MIT License - Feel free to use and modify for your courses!

---

Made with ❤️ for educators
