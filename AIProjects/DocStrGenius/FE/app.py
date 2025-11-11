import os
import re
import time
import pathlib
from typing import Any, Dict, List, Optional
import requests
import streamlit as st

# ---------------- Configuration ----------------
INSTANCE_URL = os.environ.get("JAC_INSTANCE_URL", "http://localhost:8000")
LOGIN_URL = f"{INSTANCE_URL}/user/login"
REGISTER_URL = f"{INSTANCE_URL}/user/register"
JAC_WALKER_URL = f"{INSTANCE_URL}/walker/codebase_walker"
# Optional backend file-download endpoint pattern (if backend exposes it)
BACKEND_DOWNLOAD_URL = os.environ.get("JAC_DOWNLOAD_ENDPOINT")  # e.g., "http://localhost:8000/outputs/{name}.md"

# Default test credentials (override with env vars in production)
TEST_USER_EMAIL = os.environ.get("JAC_TEST_EMAIL", "test@mail.com")
TEST_USER_PASSWORD = os.environ.get("JAC_TEST_PASSWORD", "password")

# ---------------- Streamlit setup (run at import) ----------------
st.set_page_config(page_title="CodeBase Genius", layout="wide")
# session state defaults (idempotent)
st.session_state.setdefault("token", None)
st.session_state.setdefault("markdown_history", [])  # list of entries: {"repo","name","markdown","download_url","saved_path"}
st.session_state.setdefault("debug", False)
st.session_state.setdefault("last_payload", None)

# ---------------- Helpers ----------------
def debug_log(*args, **kwargs):
    if st.session_state.get("debug"):
        st.write(*args, **kwargs)

def sanitize_filename(name: str, fallback: str = "repo") -> str:
    if not name:
        return fallback
    safe = re.sub(r"[^A-Za-z0-9_\-]", "_", name).strip("_")
    return safe or fallback

def repo_name_from_url(url: str) -> str:
    if not url:
        return "repo"
    u = url.rstrip("/").removesuffix(".git")
    if "github.com" in u:
        try:
            owner_repo = u.split("github.com/", 1)[1].split("/")[:2]
            if len(owner_repo) == 2:
                owner, repo = owner_repo
                return sanitize_filename(f"{owner}_{repo}")
        except Exception:
            pass
    last = u.split("/")[-1]
    return sanitize_filename(last)

def safe_extract_markdown(payload: Any) -> str:
    """Robustly find the most complete markdown string in a backend response."""
    if isinstance(payload, dict):
        v = payload.get("markdown")
        if isinstance(v, str) and v.strip():
            return v

    # check reports list (prefer later reports which usually have final output)
    if isinstance(payload, dict) and isinstance(payload.get("reports"), list):
        for rep in reversed(payload["reports"]):
            if not isinstance(rep, dict):
                continue
            for key in ("markdown", "doc", "summary"):
                val = rep.get(key)
                if isinstance(val, str) and val.strip():
                    return val

    # fallback: recursive search for first non-empty markdown-like field
    def find_md(obj):
        if isinstance(obj, dict):
            v = obj.get("markdown")
            if isinstance(v, str) and v.strip():
                return v
            for value in obj.values():
                found = find_md(value)
                if found:
                    return found
        elif isinstance(obj, list):
            for item in obj:
                found = find_md(item)
                if found:
                    return found
        return None

    found = find_md(payload)
    return found or ""

def extract_saved_info(payload: Any) -> Dict[str, Optional[str]]:
    """
    Return a small dict with possible fields:
    - 'repo_url' (from backend)
    - 'local_path' (server-local path where file was saved)
    - 'file_url' (HTTP URL to download saved file if backend exposes it)
    """
    info = {"repo_url": None, "local_path": None, "file_url": None}
    if not isinstance(payload, dict):
        return info
    # scan reports
    for rep in payload.get("reports", []):
        if not isinstance(rep, dict):
            continue
        if rep.get("repo_url") and not info["repo_url"]:
            info["repo_url"] = rep.get("repo_url")
        if rep.get("local_path") and not info["local_path"]:
            info["local_path"] = rep.get("local_path")
        # some backends directly include a file_url
        if rep.get("file_url") and not info["file_url"]:
            info["file_url"] = rep.get("file_url")
        # sometimes local_path is full path to folder; backend may also return repo basename
    # also check top-level fields
    if isinstance(payload.get("local_path"), str) and not info["local_path"]:
        info["local_path"] = payload["local_path"]
    if isinstance(payload.get("file_url"), str) and not info["file_url"]:
        info["file_url"] = payload["file_url"]
    return info

def login_or_register() -> Optional[str]:
    """Attempt login; if user missing, register and retry. Returns token or None."""
    try:
        r = requests.post(LOGIN_URL, json={"email": TEST_USER_EMAIL, "password": TEST_USER_PASSWORD}, timeout=30)
        debug_log("Auth login status:", r.status_code)
        if r.status_code == 200:
            token = r.json().get("token")
            if token:
                return token

        # try register
        reg = requests.post(REGISTER_URL, json={"email": TEST_USER_EMAIL, "password": TEST_USER_PASSWORD}, timeout=30)
        debug_log("Auth register status:", reg.status_code)
        if reg.status_code not in (200, 201):
            return None

        # login again
        r2 = requests.post(LOGIN_URL, json={"email": TEST_USER_EMAIL, "password": TEST_USER_PASSWORD}, timeout=30)
        if r2.status_code == 200:
            return r2.json().get("token")
    except requests.exceptions.RequestException as e:
        debug_log("Auth request exception:", e)
        return None
    return None

def fetch_backend_file(file_url: str, token: Optional[str] = None) -> Optional[bytes]:
    """GET file_url and return bytes, handling Authorization if token provided."""
    try:
        headers = {}
        if token:
            headers["Authorization"] = f"Bearer {token}"
        r = requests.get(file_url, headers=headers, timeout=60)
        if r.ok:
            return r.content
    except requests.RequestException as e:
        debug_log("Error fetching backend file_url:", e)
    return None

# ---------------- App UI ----------------
def bootstrap_frontend():
    st.title("🧠 CodeBase Genius")
    st.markdown("Generate documentation from a public GitHub repo using JacLang agents.")

    with st.form("repo_form"):
        repo_url = st.text_input("🔗 GitHub Repository URL", placeholder="https://github.com/user/project")
        submit = st.form_submit_button("🚀 Generate Docs")
        st.checkbox("Show debug logs", value=st.session_state.debug, key="debug")

    if submit and repo_url and repo_url.strip():
        repo_url = repo_url.strip()
        repo_basename = repo_name_from_url(repo_url)
        with st.spinner("Sending repo to backend..."):
            token = st.session_state.get("token")
            headers = {"Content-Type": "application/json"}
            if token:
                headers["Authorization"] = f"Bearer {token}"
            try:
                resp = requests.post(JAC_WALKER_URL, json={"repo_url": repo_url}, headers=headers, timeout=120)
            except requests.exceptions.RequestException as e:
                st.error(f"Network error contacting backend: {e}")
                return

            # parse and handle response
            try:
                resp.raise_for_status()
            except requests.HTTPError:
                st.error(f"Server returned {resp.status_code}")
                try:
                    st.json(resp.json())
                except Exception:
                    st.write(resp.text)
                return

            try:
                payload = resp.json()
            except Exception:
                st.error("Could not parse JSON response from backend.")
                st.write(resp.text)
                return

            # save raw payload into session for debug & future use
            st.session_state.last_payload = payload
            debug_log("Raw backend payload:", payload)

            # extract markdown text and saved file info
            markdown_text = safe_extract_markdown(payload)
            saved_info = extract_saved_info(payload)

            # If server saved file and exposed a file_url, fetch it for download
            download_bytes = None
            download_name = None
            if saved_info.get("file_url"):
                file_url = saved_info["file_url"]
                download_bytes = fetch_backend_file(file_url, token=token)
                if download_bytes:
                    download_name = (repo_basename + ".md")
            elif BACKEND_DOWNLOAD_URL and saved_info.get("local_path"):
                # If you configured a download pattern, construct URL
                candidate = BACKEND_DOWNLOAD_URL.format(name=repo_basename)
                download_bytes = fetch_backend_file(candidate, token=token)
                if download_bytes:
                    download_name = f"{repo_basename}.md"

            # If we didn't fetch server file, fallback to markdown_text extracted
            if not download_bytes and markdown_text:
                download_bytes = markdown_text.encode("utf-8")
                download_name = f"{repo_basename}.md"

            # If nothing found, try to use summary or file_tree as quick preview
            if not download_bytes:
                # try to find summary in reports
                if isinstance(payload, dict) and payload.get("reports"):
                    for rep in reversed(payload["reports"]):
                        if isinstance(rep, dict) and rep.get("summary"):
                            markdown_text = rep["summary"]
                            download_bytes = markdown_text.encode("utf-8")
                            download_name = f"{repo_basename}.md"
                            break

            # Present result or error
            if download_bytes:
                st.success("✅ Documentation generated (or retrieved).")
                # show preview markdown_text if available
                if isinstance(markdown_text, str) and markdown_text.strip():
                    st.markdown(markdown_text, unsafe_allow_html=False)
                # download button
                st.download_button("📥 Download Markdown", data=download_bytes, file_name=download_name, mime="text/markdown")
                # store history entry
                entry = {
                    "repo": repo_url,
                    "name": repo_basename,
                    "markdown": (markdown_text or ""),
                    "download_name": download_name,
                    "saved_path": saved_info.get("local_path"),
                    "file_url": saved_info.get("file_url"),
                    "timestamp": int(time.time())
                }
                history = st.session_state.markdown_history
                history.insert(0, entry)
                st.session_state.markdown_history = history[:50]
            else:
                st.warning("No markdown or downloadable file found in backend response. Showing raw payload for debugging.")
                st.json(payload)

    # Sidebar: compact selector only (no large content here)
with st.sidebar:
    st.header("History & Controls")
    st.checkbox("Show debug logs", value=st.session_state.debug, key="debug_sidebar")
    if st.button("Clear history"):
        st.session_state.markdown_history = []
        st.session_state.selected_repo_index = None
        st.success("History cleared")
    st.markdown("---")
    st.subheader("Recent repos")
    if st.session_state.markdown_history:
        for i, item in enumerate(st.session_state.markdown_history):
            title = item.get("name") or item.get("repo")
            # button selects the repo to render in the main pane
            if st.button(title, key=f"select_repo_{i}"):
                st.session_state.selected_repo_index = i
            # show a tiny one-line preview under the button
            preview = (item.get("markdown") or "")[:160].replace("\n", " ")
            if preview:
                st.caption(preview + ("..." if len(preview) >= 160 else ""))
    else:
        st.write("No history yet")

# Main pane: render the selected repo (large view)
selected = st.session_state.get("selected_repo_index")
if selected is None:
    st.info("Select a repo from the sidebar to view its full README here.")
else:
    # guard index validity
    history = st.session_state.get("markdown_history", [])
    if not (0 <= selected < len(history)):
        st.session_state.selected_repo_index = None
        st.info("Selected repo no longer available. Pick another from the sidebar.")
    else:
        entry = history[selected]
        title = entry.get("name") or entry.get("repo")
        st.markdown(f"# {title}")
        ts = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(entry.get("timestamp", 0)))
        st.markdown(f"*Saved: {ts}*")
        # show full markdown content (main pane)
        if entry.get("markdown"):
            st.markdown(entry["markdown"], unsafe_allow_html=False)
        else:
            st.write("No markdown content available for this entry.")

        # download / fetch server file actions
        file_url = entry.get("file_url")
        if file_url:
            if st.button("Fetch server-saved file", key=f"fetch_file_{selected}"):
                b = fetch_backend_file(file_url, token=st.session_state.get("token"))
                if b:
                    fname = entry.get("download_name") or f"{title}.md"
                    st.download_button("📥 Download server file", data=b, file_name=fname, mime="text/markdown")
                else:
                    st.warning("Could not fetch file from backend URL.")
        elif entry.get("download_name") and entry.get("markdown"):
            st.download_button("📥 Download Markdown", data=entry["markdown"].encode("utf-8"), file_name=entry["download_name"], mime="text/markdown")

        # small actions: remove this history item
        if st.button("Remove from history", key=f"remove_{selected}"):
            history.pop(selected)
            st.session_state.markdown_history = history
            st.session_state.selected_repo_index = None
            st.experimental_rerun()

    # bottom debug view
    if st.session_state.get("debug"):
        st.markdown("---")
        st.subheader("DEBUG: last backend payload")
        st.json(st.session_state.get("last_payload"))

# ---------------- Entry flow ----------------
def ensure_authenticated():
    if not st.session_state.get("token"):
        with st.spinner("🔐 Authenticating..."):
            token = login_or_register()
            if token:
                st.session_state.token = token
                st.success("✅ Authenticated successfully!")
            else:
                st.warning("Could not authenticate with backend using test credentials. You may continue without token, but some endpoints may fail.")

def main():
    ensure_authenticated()
    bootstrap_frontend()

if __name__ == "__main__":
    main()
