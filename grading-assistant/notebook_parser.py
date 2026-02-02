"""
Notebook Parser Module
Extracts and processes Jupyter notebooks from zip files
"""

import json
import zipfile
import os
from pathlib import Path
from typing import List, Dict, Any
from dataclasses import dataclass


@dataclass
class NotebookCell:
    """Represents a single notebook cell"""
    cell_type: str  # 'code' or 'markdown'
    source: str
    outputs: List[Any]
    execution_count: int = None


@dataclass
class ParsedNotebook:
    """Represents a parsed Jupyter notebook"""
    filename: str
    student_name: str  # Extracted from filename or metadata
    cells: List[NotebookCell]
    metadata: Dict[str, Any]
    raw_content: Dict[str, Any]
    
    def get_code_cells(self) -> List[NotebookCell]:
        """Return only code cells"""
        return [cell for cell in self.cells if cell.cell_type == 'code']
    
    def get_markdown_cells(self) -> List[NotebookCell]:
        """Return only markdown cells"""
        return [cell for cell in self.cells if cell.cell_type == 'markdown']
    
    def get_all_code(self) -> str:
        """Concatenate all code from code cells"""
        return "\n\n".join([cell.source for cell in self.get_code_cells()])
    
    def get_cell_with_outputs(self) -> List[Dict]:
        """Return cells with their outputs for grading"""
        result = []
        for i, cell in enumerate(self.cells):
            result.append({
                'cell_number': i + 1,
                'type': cell.cell_type,
                'source': cell.source,
                'outputs': cell.outputs,
                'execution_count': cell.execution_count
            })
        return result


def extract_student_name(filename: str) -> str:
    """
    Extract student name from filename.
    Common patterns:
    - lastname_firstname_assignment.ipynb
    - firstname_lastname_hw1.ipynb
    - student_id_assignment.ipynb
    """
    # Remove .ipynb extension
    name = Path(filename).stem
    
    # Remove common suffixes
    suffixes_to_remove = ['_homework', '_hw', '_assignment', '_lab', '_project', 
                          '_final', '_submission', '_v1', '_v2', '_v3']
    for suffix in suffixes_to_remove:
        if name.lower().endswith(suffix):
            name = name[:name.lower().rfind(suffix)]
    
    # Replace underscores and hyphens with spaces for display
    display_name = name.replace('_', ' ').replace('-', ' ')
    
    return display_name.title() if display_name else filename


def parse_notebook(content: bytes, filename: str) -> ParsedNotebook:
    """Parse a single Jupyter notebook from bytes content"""
    try:
        notebook_json = json.loads(content.decode('utf-8'))
    except json.JSONDecodeError as e:
        raise ValueError(f"Invalid notebook JSON in {filename}: {e}")
    
    cells = []
    for cell_data in notebook_json.get('cells', []):
        source = cell_data.get('source', [])
        if isinstance(source, list):
            source = ''.join(source)
        
        outputs = cell_data.get('outputs', [])
        
        cell = NotebookCell(
            cell_type=cell_data.get('cell_type', 'code'),
            source=source,
            outputs=outputs,
            execution_count=cell_data.get('execution_count')
        )
        cells.append(cell)
    
    student_name = extract_student_name(filename)
    
    return ParsedNotebook(
        filename=filename,
        student_name=student_name,
        cells=cells,
        metadata=notebook_json.get('metadata', {}),
        raw_content=notebook_json
    )


def extract_notebooks_from_zip(zip_path: str) -> List[ParsedNotebook]:
    """Extract all Jupyter notebooks from a zip file"""
    notebooks = []
    
    with zipfile.ZipFile(zip_path, 'r') as zip_ref:
        for file_info in zip_ref.filelist:
            filename = file_info.filename
            
            # Skip directories and hidden files
            if file_info.is_dir() or filename.startswith('__MACOSX'):
                continue
            
            # Skip checkpoint files
            if '.ipynb_checkpoints' in filename:
                continue
            
            # Only process .ipynb files
            if not filename.endswith('.ipynb'):
                continue
            
            # Read and parse the notebook
            try:
                content = zip_ref.read(filename)
                notebook = parse_notebook(content, os.path.basename(filename))
                notebooks.append(notebook)
            except Exception as e:
                print(f"Warning: Could not parse {filename}: {e}")
    
    return notebooks


def extract_notebooks_from_bytes(zip_bytes, filename: str = "upload.zip") -> List[ParsedNotebook]:
    """Extract notebooks from zip file bytes (for web upload)"""
    import io
    
    notebooks = []
    
    try:
        with zipfile.ZipFile(io.BytesIO(zip_bytes), 'r') as zip_ref:
            for file_info in zip_ref.filelist:
                fname = file_info.filename
                
                # Skip directories and hidden files
                if file_info.is_dir() or fname.startswith('__MACOSX'):
                    continue
                
                # Skip checkpoint files
                if '.ipynb_checkpoints' in fname:
                    continue
                
                # Only process .ipynb files
                if not fname.endswith('.ipynb'):
                    continue
                
                # Read and parse the notebook
                try:
                    content = zip_ref.read(fname)
                    notebook = parse_notebook(content, os.path.basename(fname))
                    notebooks.append(notebook)
                except Exception as e:
                    print(f"Warning: Could not parse {fname}: {e}")
    except zipfile.BadZipFile:
        raise ValueError("Invalid zip file uploaded")
    
    return notebooks


if __name__ == "__main__":
    # Test the parser
    print("Notebook Parser Module")
    print("Usage: Import and use extract_notebooks_from_zip() or extract_notebooks_from_bytes()")
