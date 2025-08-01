# Implementation Plan – Shared Account: `shr-neo-mi`
**Department:** NEO 800  
**Account:** `shr-neo-mi`  
**Engineer:** Curtis-Davidson  
**Date Completed:** 01/08/2025

---

## 1. Purpose

Deploy a secured, read-only shared account (`shr-neo-mi`) for the **NEO 800 display workstation**.  
Purpose: Run BI metrics (SharePoint-based) and live camera feeds (D-Link), with **no session timeout or lock screen**.

---

## 2. Account Creation & Configuration

### Command:
Create shared account `shr-neo-mi` in Active Directory (OU: `WAF1\SharedAccounts\NEO800`)

```plaintext
# Created in Active Directory (via dsa.msc or PowerShell)
# Account settings:
- Password: Set to never expire
- Cannot change password
- Smartcard logon not required
- Description field populated with use-case context
