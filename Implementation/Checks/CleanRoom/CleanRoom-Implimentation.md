from pathlib import Path

# Markdown content from the previous message
markdown_content = """
# ✅ Shared Account Remediation Plan: `shr-kitcutting`

## 📍Purpose
Remediate the generic `cleanroom` account usage by introducing **individual login** for most devices, while preserving generic access on exempt devices. Create proper AD structure, file repositories, and app access for the **Kitcutting Team**.

---

## Phase 1 – Preparation (Planning & Account Structure)

### **1. Confirm Stakeholders**
**Primary Contacts:**
- **Blake Dawe** – Laminating & Kit Cutting Supervisor
- **Chris Bell** – Kit Cutting / Digitising Team Leader

### **2. User List (Individual Accounts)**
| Name               | Needs Individual Login |
|--------------------|------------------------|
| Blake Dawe         | Yes                    |
| Chris Bell         | Yes                    |
| Tom Brinkworth     | Yes                    |
| Jude Alsworth      | Yes                    |
| Leighton Hunter    | Yes                    |
| Darius Poldaski    | Yes                    |
| Tomasz Wozniak     | Yes                    |
| Jack Bowler        | Yes                    |

---

## Phase 2 – AD & Permissions Setup

### **3. Create AD Groups**
**Exact Commands:**
```powershell
# 1. Create Kitcutting AD groups
New-ADGroup -Name "GroupKitcuttingRW" -GroupScope Global -Path "OU=Groups,DC=wf1,DC=local"
New-ADGroup -Name "GroupKitcuttingRO" -GroupScope Global -Path "OU=Groups,DC=wf1,DC=local"

# 2. Create Login Access Control Group
New-ADGroup -Name "GroupCleanroomLAC" -GroupScope Global -Path "OU=Groups,DC=wf1,DC=local"


4. Add Users to AD Groups

# Add all users to RW group
Add-ADGroupMember -Identity "GroupKitcuttingRW" -Members blake.dawe, chris.bell, tom.brinkworth, jude.alsworth, leighton.hunter, darius.poldaski, tomasz.wozniak, jack.bowler

# Add shr-kitcutting to both groups
Add-ADGroupMember -Identity "GroupKitcuttingRW" -Members shr-kitcutting
Add-ADGroupMember -Identity "GroupCleanroomLAC" -Members shr-kitcutting
