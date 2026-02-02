"""
AI Grading Engine
Uses AI to analyze and grade Jupyter notebooks
"""

import os
import json
from typing import List, Dict, Any, Optional
from dataclasses import dataclass, asdict
from datetime import datetime
from notebook_parser import ParsedNotebook


@dataclass
class GradingCriteria:
    """Defines the grading criteria for an assignment"""
    name: str
    max_points: int
    description: str
    rubric: List[str]  # List of rubric items to check


@dataclass
class CriteriaScore:
    """Score for a single criterion"""
    criteria_name: str
    points_earned: float
    max_points: int
    feedback: str
    details: List[str]


@dataclass
class GradingResult:
    """Complete grading result for a notebook"""
    student_name: str
    filename: str
    total_score: float
    max_score: int
    percentage: float
    letter_grade: str
    criteria_scores: List[CriteriaScore]
    overall_feedback: str
    strengths: List[str]
    areas_for_improvement: List[str]
    graded_at: str
    
    def to_dict(self) -> Dict:
        return asdict(self)


# Default grading criteria templates
DEFAULT_CRITERIA = [
    GradingCriteria(
        name="Code Correctness",
        max_points=40,
        description="Code runs without errors and produces correct output",
        rubric=[
            "Code executes without syntax errors",
            "Output matches expected results",
            "Edge cases are handled appropriately",
            "Logic is sound and algorithms are correct"
        ]
    ),
    GradingCriteria(
        name="Code Quality",
        max_points=20,
        description="Code is well-written, clean, and follows best practices",
        rubric=[
            "Variables have meaningful names",
            "Code is properly indented and formatted",
            "Functions are used appropriately",
            "No redundant or duplicate code"
        ]
    ),
    GradingCriteria(
        name="Documentation & Comments",
        max_points=15,
        description="Code is well-documented with helpful comments",
        rubric=[
            "Comments explain complex logic",
            "Markdown cells provide context",
            "Function docstrings are present",
            "Overall flow is explained"
        ]
    ),
    GradingCriteria(
        name="Completeness",
        max_points=15,
        description="All required tasks and questions are addressed",
        rubric=[
            "All required exercises completed",
            "All questions answered",
            "Required outputs displayed",
            "Assignment requirements met"
        ]
    ),
    GradingCriteria(
        name="Creativity & Insight",
        max_points=10,
        description="Shows original thinking and deep understanding",
        rubric=[
            "Goes beyond minimum requirements",
            "Shows insight into the problem",
            "Includes helpful visualizations",
            "Demonstrates understanding of concepts"
        ]
    )
]


def calculate_letter_grade(percentage: float) -> str:
    """Convert percentage to letter grade"""
    if percentage >= 97:
        return "A+"
    elif percentage >= 93:
        return "A"
    elif percentage >= 90:
        return "A-"
    elif percentage >= 87:
        return "B+"
    elif percentage >= 83:
        return "B"
    elif percentage >= 80:
        return "B-"
    elif percentage >= 77:
        return "C+"
    elif percentage >= 73:
        return "C"
    elif percentage >= 70:
        return "C-"
    elif percentage >= 67:
        return "D+"
    elif percentage >= 63:
        return "D"
    elif percentage >= 60:
        return "D-"
    else:
        return "F"


def analyze_code_quality(code: str) -> Dict[str, Any]:
    """Analyze code quality metrics"""
    lines = code.split('\n')
    
    # Count various metrics
    total_lines = len(lines)
    blank_lines = sum(1 for line in lines if not line.strip())
    comment_lines = sum(1 for line in lines if line.strip().startswith('#'))
    code_lines = total_lines - blank_lines - comment_lines
    
    # Check for common issues
    issues = []
    
    # Check for very long lines
    long_lines = [i+1 for i, line in enumerate(lines) if len(line) > 100]
    if long_lines:
        issues.append(f"Long lines (>100 chars) found on lines: {long_lines[:5]}")
    
    # Check for print debugging left in
    if 'print(' in code.lower() and ('debug' in code.lower() or 'test' in code.lower()):
        issues.append("Possible debug print statements left in code")
    
    # Check for TODO/FIXME comments
    if 'todo' in code.lower() or 'fixme' in code.lower():
        issues.append("Contains TODO/FIXME comments that may need attention")
    
    return {
        'total_lines': total_lines,
        'code_lines': code_lines,
        'comment_lines': comment_lines,
        'blank_lines': blank_lines,
        'comment_ratio': comment_lines / max(code_lines, 1),
        'issues': issues
    }


def analyze_notebook_structure(notebook: ParsedNotebook) -> Dict[str, Any]:
    """Analyze the structure of a notebook"""
    code_cells = notebook.get_code_cells()
    markdown_cells = notebook.get_markdown_cells()
    
    # Check execution order
    execution_counts = [c.execution_count for c in code_cells if c.execution_count is not None]
    executed_in_order = execution_counts == sorted(execution_counts)
    
    # Check for errors in outputs
    cells_with_errors = 0
    cells_with_outputs = 0
    for cell in code_cells:
        for output in cell.outputs:
            if isinstance(output, dict):
                if output.get('output_type') == 'error':
                    cells_with_errors += 1
                if output.get('output_type') in ['stream', 'execute_result', 'display_data']:
                    cells_with_outputs += 1
    
    return {
        'total_cells': len(notebook.cells),
        'code_cells': len(code_cells),
        'markdown_cells': len(markdown_cells),
        'executed_in_order': executed_in_order,
        'cells_with_errors': cells_with_errors,
        'cells_with_outputs': cells_with_outputs,
        'has_good_documentation': len(markdown_cells) >= len(code_cells) * 0.2
    }


def generate_ai_feedback(notebook: ParsedNotebook, 
                         criteria: List[GradingCriteria],
                         reference_solution: str = None) -> GradingResult:
    """
    Generate AI-powered feedback for a notebook.
    This is a rule-based grading system that can be extended with LLM integration.
    """
    
    # Analyze the notebook
    all_code = notebook.get_all_code()
    code_analysis = analyze_code_quality(all_code)
    structure_analysis = analyze_notebook_structure(notebook)
    
    criteria_scores = []
    total_earned = 0
    total_max = 0
    
    for criterion in criteria:
        score, feedback, details = _score_criterion(
            criterion, notebook, code_analysis, structure_analysis, reference_solution
        )
        
        criteria_scores.append(CriteriaScore(
            criteria_name=criterion.name,
            points_earned=score,
            max_points=criterion.max_points,
            feedback=feedback,
            details=details
        ))
        
        total_earned += score
        total_max += criterion.max_points
    
    percentage = (total_earned / max(total_max, 1)) * 100
    letter_grade = calculate_letter_grade(percentage)
    
    # Generate overall feedback
    strengths, improvements = _generate_summary_feedback(
        notebook, code_analysis, structure_analysis, criteria_scores
    )
    
    overall_feedback = _generate_overall_feedback(
        percentage, letter_grade, strengths, improvements
    )
    
    return GradingResult(
        student_name=notebook.student_name,
        filename=notebook.filename,
        total_score=round(total_earned, 2),
        max_score=total_max,
        percentage=round(percentage, 2),
        letter_grade=letter_grade,
        criteria_scores=criteria_scores,
        overall_feedback=overall_feedback,
        strengths=strengths,
        areas_for_improvement=improvements,
        graded_at=datetime.now().isoformat()
    )


def _score_criterion(criterion: GradingCriteria, 
                     notebook: ParsedNotebook,
                     code_analysis: Dict,
                     structure_analysis: Dict,
                     reference: str = None) -> tuple:
    """Score a single criterion"""
    
    details = []
    
    if criterion.name == "Code Correctness":
        # Check for errors
        error_count = structure_analysis['cells_with_errors']
        code_cells = structure_analysis['code_cells']
        
        if error_count == 0:
            base_score = 1.0
            details.append("✓ No execution errors found")
        elif error_count <= 1:
            base_score = 0.8
            details.append(f"⚠ {error_count} cell(s) with errors")
        elif error_count <= 3:
            base_score = 0.6
            details.append(f"⚠ {error_count} cells with errors")
        else:
            base_score = 0.4
            details.append(f"✗ {error_count} cells with errors - significant issues")
        
        if structure_analysis['cells_with_outputs'] > 0:
            details.append(f"✓ {structure_analysis['cells_with_outputs']} cells produced output")
        else:
            base_score *= 0.5
            details.append("✗ No visible output produced")
        
        score = base_score * criterion.max_points
        feedback = f"Code execution analysis: {error_count} errors in {code_cells} code cells"
        
    elif criterion.name == "Code Quality":
        issues = code_analysis['issues']
        comment_ratio = code_analysis['comment_ratio']
        
        base_score = 1.0
        
        if issues:
            base_score -= 0.1 * len(issues)
            for issue in issues:
                details.append(f"⚠ {issue}")
        else:
            details.append("✓ No major code quality issues detected")
        
        if code_analysis['code_lines'] > 0:
            details.append(f"✓ {code_analysis['code_lines']} lines of code")
        
        base_score = max(0.3, base_score)
        score = base_score * criterion.max_points
        feedback = "Code quality assessment based on style and structure"
        
    elif criterion.name == "Documentation & Comments":
        markdown_cells = structure_analysis['markdown_cells']
        comment_ratio = code_analysis['comment_ratio']
        
        if structure_analysis['has_good_documentation']:
            base_score = 0.9
            details.append(f"✓ Good use of markdown cells ({markdown_cells} cells)")
        elif markdown_cells > 0:
            base_score = 0.7
            details.append(f"⚠ Some markdown documentation ({markdown_cells} cells)")
        else:
            base_score = 0.4
            details.append("✗ No markdown documentation")
        
        if comment_ratio > 0.1:
            details.append(f"✓ Good comment density ({comment_ratio:.1%})")
        elif comment_ratio > 0.05:
            details.append(f"⚠ Moderate comment density ({comment_ratio:.1%})")
        else:
            base_score *= 0.8
            details.append(f"✗ Low comment density ({comment_ratio:.1%})")
        
        score = base_score * criterion.max_points
        feedback = "Documentation and commenting assessment"
        
    elif criterion.name == "Completeness":
        code_cells = structure_analysis['code_cells']
        cells_with_outputs = structure_analysis['cells_with_outputs']
        
        if code_cells == 0:
            base_score = 0.0
            details.append("✗ No code cells found")
        elif cells_with_outputs >= code_cells * 0.8:
            base_score = 1.0
            details.append("✓ Most code cells have been executed with output")
        elif cells_with_outputs >= code_cells * 0.5:
            base_score = 0.7
            details.append("⚠ Some code cells are missing output")
        else:
            base_score = 0.4
            details.append("✗ Many code cells are not executed")
        
        if structure_analysis['executed_in_order']:
            details.append("✓ Cells executed in order")
        else:
            details.append("⚠ Cells may not be executed in order")
        
        score = base_score * criterion.max_points
        feedback = "Completeness check based on executed cells and outputs"
        
    elif criterion.name == "Creativity & Insight":
        # This is harder to automate - give a moderate score by default
        all_code = notebook.get_all_code()
        
        base_score = 0.7  # Default moderate score
        
        # Check for visualizations
        viz_keywords = ['plt.', 'plot(', 'figure(', 'seaborn', 'sns.', 'plotly', 'chart']
        has_viz = any(kw in all_code for kw in viz_keywords)
        
        if has_viz:
            base_score += 0.15
            details.append("✓ Includes data visualizations")
        
        # Check for advanced concepts
        advanced_keywords = ['lambda', 'list comprehension', 'dict comprehension', 
                            'decorator', 'generator', 'async', 'class ']
        advanced_used = [kw for kw in advanced_keywords if kw in all_code]
        
        if advanced_used:
            base_score += 0.1
            details.append("✓ Uses advanced Python concepts")
        
        if not details:
            details.append("○ Standard approach - consider adding visualizations or extra analysis")
        
        score = min(base_score, 1.0) * criterion.max_points
        feedback = "Creativity assessment (may need manual review)"
        
    else:
        # Unknown criterion - give partial credit
        score = criterion.max_points * 0.7
        feedback = "This criterion requires manual review"
        details.append("○ Automated grading not available for this criterion")
    
    return round(score, 2), feedback, details


def _generate_summary_feedback(notebook: ParsedNotebook,
                               code_analysis: Dict,
                               structure_analysis: Dict,
                               criteria_scores: List[CriteriaScore]) -> tuple:
    """Generate strengths and areas for improvement"""
    
    strengths = []
    improvements = []
    
    # Check for strengths
    if structure_analysis['cells_with_errors'] == 0:
        strengths.append("Code runs without errors")
    
    if structure_analysis['has_good_documentation']:
        strengths.append("Well-documented with markdown cells")
    
    if code_analysis['comment_ratio'] > 0.1:
        strengths.append("Good use of code comments")
    
    if structure_analysis['executed_in_order']:
        strengths.append("Notebook is organized and runs in order")
    
    # Check for improvements
    if structure_analysis['cells_with_errors'] > 0:
        improvements.append("Fix code errors to improve correctness score")
    
    if not structure_analysis['has_good_documentation']:
        improvements.append("Add more markdown cells to explain your approach")
    
    if code_analysis['comment_ratio'] < 0.05:
        improvements.append("Add more comments to explain complex code")
    
    if code_analysis['issues']:
        improvements.append("Address code quality issues (long lines, debug prints)")
    
    # Ensure at least one item in each
    if not strengths:
        strengths.append("Submitted assignment on time")
    
    if not improvements:
        improvements.append("Keep up the excellent work!")
    
    return strengths[:5], improvements[:5]


def _generate_overall_feedback(percentage: float, 
                               letter_grade: str,
                               strengths: List[str],
                               improvements: List[str]) -> str:
    """Generate overall feedback message"""
    
    if percentage >= 90:
        tone = "Excellent work! "
    elif percentage >= 80:
        tone = "Good job! "
    elif percentage >= 70:
        tone = "Satisfactory work. "
    elif percentage >= 60:
        tone = "Needs improvement. "
    else:
        tone = "Please see me during office hours. "
    
    feedback = f"{tone}Your submission earned {percentage:.1f}% ({letter_grade}). "
    
    if strengths:
        feedback += f"Key strength: {strengths[0].lower()}. "
    
    if improvements and percentage < 95:
        feedback += f"To improve: {improvements[0].lower()}."
    
    return feedback


def grade_notebooks(notebooks: List[ParsedNotebook],
                   criteria: List[GradingCriteria] = None,
                   reference_solution: str = None) -> List[GradingResult]:
    """Grade multiple notebooks"""
    
    if criteria is None:
        criteria = DEFAULT_CRITERIA
    
    results = []
    for notebook in notebooks:
        try:
            result = generate_ai_feedback(notebook, criteria, reference_solution)
            results.append(result)
        except Exception as e:
            print(f"Error grading {notebook.filename}: {e}")
            # Create a minimal error result
            results.append(GradingResult(
                student_name=notebook.student_name,
                filename=notebook.filename,
                total_score=0,
                max_score=100,
                percentage=0,
                letter_grade="F",
                criteria_scores=[],
                overall_feedback=f"Error during grading: {str(e)}",
                strengths=[],
                areas_for_improvement=["Unable to grade - please resubmit"],
                graded_at=datetime.now().isoformat()
            ))
    
    return results


def export_results_to_csv(results: List[GradingResult], filepath: str):
    """Export grading results to CSV"""
    import csv
    
    with open(filepath, 'w', newline='') as f:
        writer = csv.writer(f)
        
        # Header
        header = ['Student Name', 'Filename', 'Total Score', 'Max Score', 
                  'Percentage', 'Letter Grade', 'Overall Feedback']
        writer.writerow(header)
        
        # Data rows
        for result in results:
            row = [
                result.student_name,
                result.filename,
                result.total_score,
                result.max_score,
                result.percentage,
                result.letter_grade,
                result.overall_feedback
            ]
            writer.writerow(row)
    
    return filepath


def export_results_to_json(results: List[GradingResult], filepath: str):
    """Export detailed grading results to JSON"""
    
    data = {
        'grading_session': {
            'timestamp': datetime.now().isoformat(),
            'total_submissions': len(results),
            'average_score': sum(r.percentage for r in results) / max(len(results), 1)
        },
        'results': [r.to_dict() for r in results]
    }
    
    with open(filepath, 'w') as f:
        json.dump(data, f, indent=2)
    
    return filepath


if __name__ == "__main__":
    print("AI Grading Engine")
    print("Usage: Import and use grade_notebooks() function")
