"""
AI Grading Assistant - Web Interface
A simple, user-friendly interface for grading Jupyter notebooks
"""

import streamlit as st
import pandas as pd
import io
import json
from datetime import datetime

from notebook_parser import extract_notebooks_from_bytes, ParsedNotebook
from grading_engine import (
    grade_notebooks, 
    export_results_to_csv, 
    export_results_to_json,
    DEFAULT_CRITERIA,
    GradingCriteria,
    GradingResult
)


# Page configuration
st.set_page_config(
    page_title="AI Grading Assistant",
    page_icon="📚",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Custom CSS for better styling
st.markdown("""
<style>
    .main-header {
        font-size: 2.5rem;
        font-weight: bold;
        color: #1f77b4;
        text-align: center;
        padding: 1rem;
    }
    .sub-header {
        font-size: 1.2rem;
        color: #666;
        text-align: center;
        margin-bottom: 2rem;
    }
    .grade-card {
        background-color: #f8f9fa;
        border-radius: 10px;
        padding: 1.5rem;
        margin: 1rem 0;
        border-left: 5px solid #1f77b4;
    }
    .grade-A { border-left-color: #28a745 !important; }
    .grade-B { border-left-color: #17a2b8 !important; }
    .grade-C { border-left-color: #ffc107 !important; }
    .grade-D { border-left-color: #fd7e14 !important; }
    .grade-F { border-left-color: #dc3545 !important; }
    .metric-box {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        padding: 1rem;
        border-radius: 10px;
        text-align: center;
    }
    .stProgress > div > div > div {
        background-color: #1f77b4;
    }
</style>
""", unsafe_allow_html=True)


def get_grade_color(letter_grade: str) -> str:
    """Get color class based on letter grade"""
    if letter_grade.startswith('A'):
        return 'grade-A'
    elif letter_grade.startswith('B'):
        return 'grade-B'
    elif letter_grade.startswith('C'):
        return 'grade-C'
    elif letter_grade.startswith('D'):
        return 'grade-D'
    else:
        return 'grade-F'


def render_header():
    """Render the main header"""
    st.markdown('<div class="main-header">📚 AI Grading Assistant</div>', unsafe_allow_html=True)
    st.markdown('<div class="sub-header">Upload a zip file of Jupyter notebooks to grade them automatically</div>', unsafe_allow_html=True)


def render_sidebar():
    """Render the sidebar with settings"""
    with st.sidebar:
        st.header("⚙️ Grading Settings")
        
        st.subheader("📊 Criteria Weights")
        
        # Allow customization of grading criteria
        criteria_weights = {}
        total_weight = 0
        
        for criterion in DEFAULT_CRITERIA:
            weight = st.slider(
                criterion.name,
                min_value=0,
                max_value=50,
                value=criterion.max_points,
                help=criterion.description
            )
            criteria_weights[criterion.name] = weight
            total_weight += weight
        
        st.info(f"Total points: {total_weight}")
        
        st.divider()
        
        st.subheader("📝 Additional Options")
        
        include_detailed_feedback = st.checkbox("Include detailed feedback", value=True)
        show_code_preview = st.checkbox("Show code preview", value=False)
        
        return criteria_weights, include_detailed_feedback, show_code_preview


def render_upload_section():
    """Render the file upload section"""
    st.header("📤 Upload Submissions")
    
    col1, col2 = st.columns([2, 1])
    
    with col1:
        uploaded_file = st.file_uploader(
            "Upload a ZIP file containing Jupyter notebooks",
            type=['zip'],
            help="The ZIP file should contain .ipynb files. They can be in subfolders."
        )
    
    with col2:
        st.markdown("### 📋 Instructions")
        st.markdown("""
        1. Collect all student notebooks in a folder
        2. Compress the folder to a ZIP file
        3. Upload the ZIP file here
        4. Click 'Grade All Notebooks'
        5. Review and export results
        """)
    
    return uploaded_file


def render_notebook_list(notebooks: list):
    """Display list of detected notebooks"""
    st.subheader(f"📓 Detected {len(notebooks)} Notebook(s)")
    
    notebook_df = pd.DataFrame([
        {
            'Student': nb.student_name,
            'Filename': nb.filename,
            'Code Cells': len(nb.get_code_cells()),
            'Markdown Cells': len(nb.get_markdown_cells())
        }
        for nb in notebooks
    ])
    
    st.dataframe(notebook_df, use_container_width=True)
    
    return notebooks


def render_grading_results(results: list):
    """Render the grading results"""
    st.header("📊 Grading Results")
    
    # Summary statistics
    col1, col2, col3, col4 = st.columns(4)
    
    avg_score = sum(r.percentage for r in results) / len(results)
    highest = max(results, key=lambda r: r.percentage)
    lowest = min(results, key=lambda r: r.percentage)
    
    with col1:
        st.metric("Submissions Graded", len(results))
    with col2:
        st.metric("Average Score", f"{avg_score:.1f}%")
    with col3:
        st.metric("Highest Score", f"{highest.percentage:.1f}%")
    with col4:
        st.metric("Lowest Score", f"{lowest.percentage:.1f}%")
    
    st.divider()
    
    # Grade distribution
    st.subheader("📈 Grade Distribution")
    
    grade_counts = {}
    for r in results:
        grade = r.letter_grade[0]  # Just the letter
        grade_counts[grade] = grade_counts.get(grade, 0) + 1
    
    grade_df = pd.DataFrame([
        {'Grade': g, 'Count': c}
        for g, c in sorted(grade_counts.items())
    ])
    
    if not grade_df.empty:
        st.bar_chart(grade_df.set_index('Grade'))
    
    st.divider()
    
    # Individual results
    st.subheader("📝 Individual Results")
    
    # Create tabs for summary and detailed views
    tab1, tab2 = st.tabs(["Summary Table", "Detailed Feedback"])
    
    with tab1:
        summary_df = pd.DataFrame([
            {
                'Student': r.student_name,
                'Score': f"{r.total_score}/{r.max_score}",
                'Percentage': f"{r.percentage:.1f}%",
                'Grade': r.letter_grade,
                'Feedback': r.overall_feedback[:100] + '...' if len(r.overall_feedback) > 100 else r.overall_feedback
            }
            for r in results
        ])
        
        # Sort by score descending
        summary_df = summary_df.sort_values('Percentage', ascending=False)
        
        st.dataframe(summary_df, use_container_width=True)
    
    with tab2:
        for result in sorted(results, key=lambda r: r.student_name):
            grade_class = get_grade_color(result.letter_grade)
            
            with st.expander(f"📄 {result.student_name} - {result.letter_grade} ({result.percentage:.1f}%)"):
                # Score breakdown
                st.markdown("#### Score Breakdown")
                
                for cs in result.criteria_scores:
                    col1, col2 = st.columns([3, 1])
                    with col1:
                        st.write(f"**{cs.criteria_name}**")
                        progress = cs.points_earned / cs.max_points
                        st.progress(progress)
                    with col2:
                        st.write(f"{cs.points_earned}/{cs.max_points}")
                    
                    # Show details
                    for detail in cs.details:
                        st.caption(detail)
                    st.write("")
                
                st.markdown("#### Overall Feedback")
                st.info(result.overall_feedback)
                
                col1, col2 = st.columns(2)
                with col1:
                    st.markdown("**✅ Strengths:**")
                    for s in result.strengths:
                        st.write(f"• {s}")
                
                with col2:
                    st.markdown("**📈 Areas for Improvement:**")
                    for a in result.areas_for_improvement:
                        st.write(f"• {a}")


def render_export_section(results: list):
    """Render export options"""
    st.header("💾 Export Results")
    
    col1, col2, col3 = st.columns(3)
    
    with col1:
        # CSV export
        csv_buffer = io.StringIO()
        df = pd.DataFrame([
            {
                'Student Name': r.student_name,
                'Filename': r.filename,
                'Score': r.total_score,
                'Max Score': r.max_score,
                'Percentage': r.percentage,
                'Letter Grade': r.letter_grade,
                'Feedback': r.overall_feedback
            }
            for r in results
        ])
        df.to_csv(csv_buffer, index=False)
        
        st.download_button(
            label="📥 Download CSV",
            data=csv_buffer.getvalue(),
            file_name=f"grades_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv",
            mime="text/csv"
        )
    
    with col2:
        # JSON export with full details
        json_data = {
            'grading_session': {
                'timestamp': datetime.now().isoformat(),
                'total_submissions': len(results),
                'average_score': sum(r.percentage for r in results) / len(results)
            },
            'results': [r.to_dict() for r in results]
        }
        
        st.download_button(
            label="📥 Download JSON (Detailed)",
            data=json.dumps(json_data, indent=2),
            file_name=f"grades_detailed_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json",
            mime="application/json"
        )
    
    with col3:
        # Feedback report
        feedback_text = "# Grading Feedback Report\n\n"
        feedback_text += f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n"
        feedback_text += f"Total Submissions: {len(results)}\n"
        feedback_text += f"Average Score: {sum(r.percentage for r in results) / len(results):.1f}%\n\n"
        feedback_text += "---\n\n"
        
        for r in sorted(results, key=lambda x: x.student_name):
            feedback_text += f"## {r.student_name}\n\n"
            feedback_text += f"**Score:** {r.total_score}/{r.max_score} ({r.percentage:.1f}%) - {r.letter_grade}\n\n"
            feedback_text += f"**Feedback:** {r.overall_feedback}\n\n"
            feedback_text += "**Strengths:**\n"
            for s in r.strengths:
                feedback_text += f"- {s}\n"
            feedback_text += "\n**Areas for Improvement:**\n"
            for a in r.areas_for_improvement:
                feedback_text += f"- {a}\n"
            feedback_text += "\n---\n\n"
        
        st.download_button(
            label="📥 Download Feedback Report",
            data=feedback_text,
            file_name=f"feedback_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.md",
            mime="text/markdown"
        )


def main():
    """Main application entry point"""
    
    # Initialize session state
    if 'notebooks' not in st.session_state:
        st.session_state.notebooks = None
    if 'results' not in st.session_state:
        st.session_state.results = None
    
    # Render header
    render_header()
    
    # Render sidebar
    criteria_weights, include_detailed_feedback, show_code_preview = render_sidebar()
    
    # Main content
    uploaded_file = render_upload_section()
    
    if uploaded_file is not None:
        # Extract notebooks from zip
        try:
            with st.spinner("Extracting notebooks..."):
                notebooks = extract_notebooks_from_bytes(uploaded_file.read())
                st.session_state.notebooks = notebooks
            
            if not notebooks:
                st.error("No Jupyter notebooks found in the uploaded ZIP file.")
                return
            
            st.success(f"Successfully extracted {len(notebooks)} notebook(s)!")
            
            # Display notebook list
            render_notebook_list(notebooks)
            
            # Grade button
            if st.button("🎯 Grade All Notebooks", type="primary", use_container_width=True):
                with st.spinner("Grading notebooks... This may take a moment."):
                    # Create criteria with custom weights
                    custom_criteria = []
                    for criterion in DEFAULT_CRITERIA:
                        custom_criteria.append(GradingCriteria(
                            name=criterion.name,
                            max_points=criteria_weights.get(criterion.name, criterion.max_points),
                            description=criterion.description,
                            rubric=criterion.rubric
                        ))
                    
                    # Grade notebooks
                    results = grade_notebooks(notebooks, custom_criteria)
                    st.session_state.results = results
                
                st.success("Grading complete!")
            
            # Show results if available
            if st.session_state.results:
                render_grading_results(st.session_state.results)
                st.divider()
                render_export_section(st.session_state.results)
        
        except Exception as e:
            st.error(f"Error processing file: {str(e)}")
            st.exception(e)
    
    else:
        # Show placeholder when no file is uploaded
        st.info("👆 Upload a ZIP file containing Jupyter notebooks to get started!")
        
        # Quick demo section
        with st.expander("ℹ️ How it works"):
            st.markdown("""
            ### The AI Grading Assistant evaluates notebooks on:
            
            1. **Code Correctness** (40 points)
               - No execution errors
               - Proper output generation
               
            2. **Code Quality** (20 points)
               - Clean, readable code
               - Following best practices
               
            3. **Documentation** (15 points)
               - Markdown explanations
               - Code comments
               
            4. **Completeness** (15 points)
               - All cells executed
               - Required outputs present
               
            5. **Creativity & Insight** (10 points)
               - Visualizations
               - Advanced techniques
            
            ### Tips for best results:
            - Ensure students run all cells before submitting
            - Use consistent file naming (e.g., `lastname_firstname_hw1.ipynb`)
            - Clear error cells before submission
            """)


if __name__ == "__main__":
    main()
