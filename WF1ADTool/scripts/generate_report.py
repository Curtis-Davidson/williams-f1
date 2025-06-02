# Purpose: Reusable module to generate JSON + Markdown AD review reports

import json, os
from datetime import datetime
import pandas as pd
from pathlib import Path

def generate_report(json_input_path: str, output_base: str = "/mnt/data/ADUserDiscoveryTool"):
    with open(json_input_path, "r", encoding="utf-8-sig") as f:
        user_data = json.load(f)

    username = user_data.get("Username", "unknown_user").lower()
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")

    json_out = f"{output_base}/reviews/json/user_{username}_{timestamp}.json"
    md_out = f"{output_base}/reviews/md/user_{username}_{timestamp}.md"

    Path(os.path.dirname(json_out)).mkdir(parents=True, exist_ok=True)
    Path(os.path.dirname(md_out)).mkdir(parents=True, exist_ok=True)

    groups = user_data.get("Groups", [])
    group_df = pd.DataFrame(groups, columns=["GroupName"])
    group_df["Decision"] = "Unsure"

    md_lines = [
        f"# AD User Review Report – {user_data.get('DisplayName', 'N/A')} ({username})",
        f"**Timestamp:** {timestamp}",
        f"**Domain:** {user_data.get('Domain', 'N/A')}",
        f"**Organizational Unit:** {user_data.get('OU', 'N/A')}",
        f"\n## Group Memberships Review\n",
        "| Group Name | Decision |",
        "|------------|----------|"
    ]

    for _, row in group_df.iterrows():
        md_lines.append(f"| {row['GroupName']} | {row['Decision']} |")

    with open(md_out, "w") as f:
        f.write("\n".join(md_lines))

    user_data["ReviewedGroups"] = group_df.to_dict(orient="records")
    with open(json_out, "w", encoding="utf-8") as f:
        json.dump(user_data, f, indent=4)

    return json_out, md_out