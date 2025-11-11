import git
import os
def clone_project(repo_url:str, local_path:str):
    try:
        os.makedirs(local_path, exist_ok=True)

        # Clone the repository
        git.Repo.clone_from(repo_url, local_path)
        print(f"Repository '{repo_url}' cloned successfully to '{local_path}'")
    except git.exc.GitCommandError as e:
        print(f"Error cloning repository: {e}")
    return {"status": "cloned", "path": local_path}