import os

def save(markdown: str, filename: str):
    
    base_dir = os.path.dirname(os.path.dirname(os.path.dirname(__file__)))
    outputs_dir = os.path.join(base_dir, "outputs")
    file_path = os.path.join(outputs_dir, f"{filename}.md")
    with open(file_path, "w") as f:
        f.write(markdown)
    return file_path
