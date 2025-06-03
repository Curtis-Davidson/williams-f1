#!/usr/bin/env python3
"""
# === Purpose: Launch & Test ADUserReview Notebook Automatically ===
# Location: /scripts/launch_aduserreview.py
# Description: Validates ADUserDiscovery JSON export and opens Jupyter Notebook with injected values.
# Requires: Python 3.8+, pandas, jupyter
"""

import os
import sys
import json
import subprocess
from pathlib import Path

# === CONFIGURATION ===
NOTEBOOK_NAME = "ADUserReview.ipynb"
EXPORTS_DIR = Path(__file__).resolve().parent.parent / "exports"

# === VALIDATE ARGS ===
if len(sys.argv) != 2:
    print("Usage: python3 launch_aduserreview.py <username>")
    sys.exit(1)

username = sys.argv[1]
user_dir = EXPORTS_DIR / username

if not user_dir.exists():
    print(f"[ERROR] Directory not found: {user_dir}")
    sys.exit(2)

# === FIND LATEST JSON FILE ===
json_files = sorted(user_dir.glob("ad_user_summary_*.json"), reverse=True)
if not json_files:
    print(f"[ERROR] No ADUserDiscovery JSON exports found for user: {username}")
    sys.exit(3)

json_file = json_files[0]
print(f"[INFO] Found export: {json_file.name}")

# === PATCH NOTEBOOK DYNAMICALLY (Inject Path) ===
notebook_path = Path(__file__).resolve().parent / NOTEBOOK_NAME
if not notebook_path.exists():
    print(f"[ERROR] Notebook not found: {notebook_path}")
    sys.exit(4)

# Backup original notebook before overwrite (safety)
backup_path = notebook_path.with_suffix(".bak.ipynb")
if not backup_path.exists():
    notebook_path.replace(backup_path)
    notebook_path = backup_path.copy(notebook_path)

with open(notebook_path, "r", encoding="utf-8") as f:
    nb = json.load(f)

updated = False
for cell in nb["cells"]:
    if cell["cell_type"] == "code":
        for i, line in enumerate(cell["source"]):
            if "json_path =" in line:
                cell["source"][i] = f"json_path = Path(r'{json_file}')\n"
                updated = True

if updated:
    with open(notebook_path, "w", encoding="utf-8") as f:
        json.dump(nb, f, indent=1)
    print(f"[INFO] Injected path into notebook: {notebook_path.name}")
else:
    print(f"[WARN] No injection point found. Notebook unchanged.")

# === LAUNCH NOTEBOOK ===
print("[INFO] Launching Jupyter Notebook...")
subprocess.run(["jupyter", "notebook", str(notebook_path)])