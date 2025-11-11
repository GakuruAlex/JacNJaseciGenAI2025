import os
import glob
from utils import git_tools  # assuming your existing git_tools.py is in utils/
from directory_tree import DisplayTree

def prepare_repo(repo_url: str) -> tuple[str, list, str]:
    """
    Prepares and analyzes a repository.
    - Clones it into `outputs/` if not already cloned.
    - Returns (local_path, file_tree, readme_text).
    """

    # 🧱 Set up outputs directory
    base_dir = os.path.dirname(os.path.dirname(os.path.dirname(__file__)))
    outputs_dir = os.path.join(base_dir, "outputs")
    os.makedirs(outputs_dir, exist_ok=True)


    # 🏷️ Determine repo name and path
    repo_name = repo_url.split("/")[-1].replace(".git", "")
    local_path = os.path.join(outputs_dir, repo_name)

    # ⚙️ Clone repo
    
    git_tools.clone_project(repo_url, local_path)
    
    # 📘 Find README (if any)
    readme_text = ""
    readme_candidates = glob.glob(os.path.join(local_path, "**/README.md"), recursive=True)
    if readme_candidates:
        try:
            with open(readme_candidates[0], "r", encoding="utf-8", errors="ignore") as f:
                readme_text = f.read()
        except Exception:
            pass

    return local_path, DisplayTree(local_path, stringRep=True), readme_text
