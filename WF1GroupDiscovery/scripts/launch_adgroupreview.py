#!/usr/bin/env python3
"""
Launch Helper for ADGroupReview.ipynb
Injects latest AD group snapshot path and launches the review notebook.
"""

import sys
import json
from pathlib import Path
import subprocess

# === CONFIG ===
NOTEBOOK_NAME = "ADGroupReview.ipynb"
EXPORTS_DIR = Path("../exports")

# === ARGUMENT CHECK ===
if len(sys.argv) != 2:
    print("Usage: python launch_adgroupreview.py <GroupName>")
    sys.exit(1)

group_name = sys.argv[1]
group_dir = EXPORTS_DIR / group_name

if not group_dir.exists():
    print(f"[ERROR] No export folder found for group: {group_name}")
    sys.exit(2)

# === FIND LATEST SNAPSHOT FILE ===
json_files = sorted(group_dir.glob("group_snapshot_*.json"), reverse=True)

if not json_files:
    print(f"[ERROR] No snapshot JSON exports found for: {group_name}")
    sys.exit(3)

json_file = json_files[0]
print(f"[INFO] Found snapshot: {json_file.name}")

# === PATCH NOTEBOOK ===
notebook_path = Path(__file__).parent / NOTEBOOK_NAME

if not notebook_path.exists():
    print(f"[ERROR] Notebook not found: {notebook_path}")
    sys.exit(4)

with open(notebook_path, "r", encoding="utf-8") as f:
    nb = json.load(f)

updated = False
for cell in nb["cells"]:
    if cell["cell_type"] == "code":
        for i, line in enumerate(cell["source"]):
            if "json_file =" in line or "json_path =" in line:
                cell["source"][i] = f"json_path = Path(r\"{json_file}\")\n"
                updated = True

if updated:
    with open(notebook_path, "w", encoding="utf-8") as f:
        json.dump(nb, f, indent=1)
    print(f"[INFO] Injected snapshot path into: {NOTEBOOK_NAME}")
else:
    print("[WARN] No injection point found. Notebook left unchanged.")

# === LAUNCH NOTEBOOK ===
print("[INFO] Launching Jupyter Notebook...")
subprocess.run(["jupyter", "notebook", str(notebook_path)])