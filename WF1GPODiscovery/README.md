#  WF1GPODiscovery – GPO Intelligence & Visibility Suite

## Overview

`WF1GPODiscovery` is an advanced PowerShell-based discovery module for **enumerating, summarising, and exporting** Group Policy Objects (GPOs) across an Active Directory (AD) forest. Built for Williams F1 and designed by Urbantek, it provides **full JSON, HTML, CSV, and Markdown reports** with auto-publishing pipelines to GitHub Pages and PDF exports.

---

##  Directory Structure

```text
WF1GPODiscovery/
├── wf1-gpo-discovery.ps1         # Main discovery script
├── Results/                      # Auto-generated reports
│   ├── wf1_gpo_summary_*.json
│   ├── wf1_gpo_summary_*.html
│   ├── wf1_gpo_dashboard_*.csv
│   └── wf1_gpo_summary_*.md
├── PDFs/                         # Auto-generated PDFs from Markdown (via GitHub Actions)
└── .github/workflows/            # GitHub Actions for automation
    └── publish-reports.yml


Features
	•	Full GPO extraction with metadata and linked OUs
	•	Summary of applied security filtering and settings
	•	Detects unlinked OUs (orphans)
	•	Exports to:
	•	 JSON
	•	 HTML + CSV
	•	 GitHub-flavoured Markdown
	•	 PDF (via Pandoc + GitHub Actions)
	•	Auto-published dashboards to GitHub Pages
	•	Designed for integration with SharePoint/OneDrive

⸻

️ Prerequisites
	•	PowerShell 5.1+
	•	Must be run as Domain Admin
	•	Required modules:

Import-Module GroupPolicy
Import-Module ActiveDirectory

Usage

# From within the repo root:
cd WF1GPODiscovery
.\wf1-gpo-discovery.ps1

