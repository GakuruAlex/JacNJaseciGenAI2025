# 🧠 DocStrGenius

DocStrGenius is an agent-driven documentation generator that analyzes a specific subfolder of a repository (`DocStrGenius`) and produces structured README/Markdown documentation.  
It uses Jac/JIR agents for code analysis and a Streamlit frontend to submit subfolders and retrieve generated docs. The repository contains:

- BE/— Backend agent code and utilities (Jac/JIR files and helpers)
- FE/ — Frontend Streamlit application
- outputs/— Generated documentation and artifacts


## 📂 Project Structure

- **BE/**
  - `code_analyzer.jac`, `code_analyzer.impl.jac`, — code analysis logic and implementation
  - `code_genius.jac` — orchestration agents
  - `codebase_walker.jac`— walker that traverses the subfolder and builds semantic graphs
  - `doc_genie.jac` — document generation agents
  - `repo_mapper.jac` — map subfolder structure into summaries
  - `utils/` — utility scripts
  - `requirements.txt` — Python dependencies

- **FE/**
  - `app.py` — Streamlit app to submit extracted subfolders, view generated markdown, download files, and manage session history

- **outputs/**
  - Generated documentation files (e.g., `docstrgen.md`)

---

## 🚀 Quick Overview

1. The **walker** (`BE/codebase_walker`) reads the extracted subfolder and builds a semantic graph of modules, functions, classes, and docstrings.  
2. The **doc_genie** agent converts the semantic graph into human-friendly README/Markdown.  
3. The backend saves the markdown to `outputs/<repo_name>.md` and returns structured reports.  
4. The Streamlit frontend (`FE/app.py`) allows submission of extracted subfolders, displays markdown, supports downloads, and maintains session history.

---

## 🛠️ Getting Started

### Prerequisites
- Python 3.9+
- Git (optional if using ZIP extraction)
- pip
- Jac/JIR runtime

### Setup

#### 📥 Clone Only a Subfolder (Bash Zip Download & Extract)
    Run the following on bash to get the DocStrGenius subfolder of the repo.

    ```bash
    # Parameters
    REPO_OWNER="GakuruAlex"
    REPO_NAME="JacNJaseciGenAI2025"
    BRANCH="main"
    SUBDIR="AIProjects/DocStrGenius"
    OUTDIR="/tmp/docstrgen"

    # Prepare
    TMPDIR="$(mktemp -d)"
    ZIP_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/archive/refs/heads/${BRANCH}.zip"

    # Download the branch zip
    curl -L -o "${TMPDIR}/${REPO_NAME}-${BRANCH}.zip" "${ZIP_URL}"

    # Create output dir
    mkdir -p "${OUTDIR}"

    # Determine archive prefix
    ARCHIVE_PREFIX="${REPO_NAME}-${BRANCH}/"

    # Extract only files under the desired subfolder path
    unzip -q "${TMPDIR}/${REPO_NAME}-${BRANCH}.zip" "${ARCHIVE_PREFIX}${SUBDIR}/*" -d "${TMPDIR}"

    # Move extracted subfolder contents to OUTDIR
    rsync -a "${TMPDIR}/${ARCHIVE_PREFIX}${SUBDIR}/" "${OUTDIR}/"

    # Cleanup
    rm -rf "${TMPDIR}"

    echo "Subfolder ${SUBDIR} extracted to ${OUTDIR}"


    cd /tmp/docstrgen/BE

    # create and activate a virtual environment
    python3 -m venv .venv
    source .venv/bin/activate

    # install backend requirements
    pip install -r requirements.txt

    # install frontend requirements
    pip install streamlit requests

    cd /tmp/docstrgen/BE
    uvicorn be_app:app --reload --host 0.0.0.0 --port 8000

    cd /tmp/docstrgen/FE
    streamlit run app.py




### 🧪 Use the app

Open the Streamlit UI in your browser.

Enter a GitHub repo URL and optionally a subfolder path (like AIProjects/DocStrGenius).

Click Generate Docs.

The backend walker analyzes the code, the doc_genie agent generates markdown, and the frontend displays and lets you download the file (saved in outputs/<repo_name>.md).