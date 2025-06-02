# Purpose: Batch process all user JSONs in /input folder
import glob
from tools.generate_report import generate_report

INPUT_FOLDER = "/mnt/data/ADUserDiscoveryTool/input"

def main():
    json_files = glob.glob(f"{INPUT_FOLDER}/user_*.json")
    print(f"Found {len(json_files)} files...")

    for file in json_files:
        print(f"Processing {file}...")
        json_out, md_out = generate_report(file)
        print(f" JSON saved: {json_out}")
        print(f" Markdown saved: {md_out}")

if __name__ == "__main__":
    main()