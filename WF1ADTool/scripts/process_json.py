import os
import json

# Define the base directory
base_dir = "/mnt/data/ADUserDiscoveryTool"

# Define full paths
directories = [
    "tools/ADUserDiscoveryTool/scripts",
    "tools/ADUserDiscoveryTool/reviews/json",
    "tools/ADUserDiscoveryTool/reviews/md"
]

# Create directories
created_dirs = []
for dir_path in directories:
    full_path = os.path.join(base_dir, dir_path)
    os.makedirs(full_path, exist_ok=True)
    created_dirs.append(full_path)

# Sample baseline.json content
baseline = {
    "required_groups": [
        "Workstation Local Admins",
        "IT Support Users",
        "grp-modelshopRW"
    ],
    "required_gpos": [
        "ModelShop Workstation Policy",
        "FSLogix Profile Baseline"
    ]
}

# Sample legacy_rules.json content
legacy_rules = {
    "deprecated_groups": [
        "SDP Users - Contractors",
        "VDI_Win10"
    ],
    "deprecated_gpos": [
        "Legacy User Login Policy"
    ]
}

# Sample user_modelshop.json input
user_data = {
    "Username": "modelshop",
    "DisplayName": "Shared Modelshop Account",
    "Groups": [
        "Workstation Local Admins",
        "SDP Users - Contractors",
        "grp-modelshopRW"
    ],
    "GPOs": [
        "ModelShop Workstation Policy",
        "Legacy User Login Policy"
    ],
    "ACLs": [],
    "OU": "OU=ModelShop,OU=Factory,DC=wf1,DC=corp",
    "ProfilePath": "\\\\fileserver\\profiles\\modelshop",
    "SID": "S-1-5-21-1123456789-2345678901-3456789012-1001"
}

# Save JSON files
files_written = []
samples = {
    "baseline.json": baseline,
    "legacy_rules.json": legacy_rules,
    "reviews/json/user_modelshop.json": user_data
}

for filename, content in samples.items():
    full_path = os.path.join(base_dir, "tools/ADUserDiscoveryTool", filename)
    with open(full_path, "w") as f:
        json.dump(content, f, indent=4)
    files_written.append(full_path)

created_dirs, files_written