# Workflow Blueprint — CRAFT Master Prompts for Shared Account Remediation

---

## Step 1 — Interpreter (Canonical Truth Extractor)

**Input:** Raw BA document (full of ambiguity, boilerplate, approvals, distribution lists).  
**Output:** Clean, plain-English “truth document” with:
- Purpose
- Shared Account (old → new)
- Devices (As-Is vs To-Be)
- Users
- Exceptions
- Dependencies
- Risks & Business Impacts

**Why:**  
This becomes the **single source of truth**.  
Every other prompt runs off this, avoiding “document drift”.

---

## Step 2 — CAB Generator (Governance Pack)

**Input:** Interpreter output.  
**Output:** CAB submission, structured around:
- Change summary
- Business justification
- Scope & impact
- Implementation window
- Rollback plan
- Testing & validation
- Approvals

**Audience:** Change Advisory Board.  
**Why:** Cleanly separates *governance* from *engineering*.

---

## Step 3 — Implementation Runbook Generator (Engineer’s Playbook)

**Input:** Interpreter output.  
**Output:** Step-by-step, technical runbook:
- Create Shared Account(s) in AD/Entra
- Create/verify groups (RO, RW, LAC, RDC)
- Apply logonWorkstations restrictions
- Migrate devices (Cat 1 → decommission, Cat 3 → Individual Accounts, Cat 8 → Shared Account)
- Remove old Generic Accounts
- Enforce MFA & Keeper integration
- Validation testing

**Audience:** Engineers executing change.  
**Why:** Zero ambiguity, repeatable across every remediation.

---

## Step 4 — Support Document Generator (Service Desk Runbook)

**Input:** Interpreter output.  
**Output:** Post-implementation support doc:
- Shared Account overview
- Access rules (who, where, how)
- Password/MFA reset procedure (Keeper, escalation)
- Troubleshooting guide
- Escalation chain
- Monitoring & audit schedule

**Audience:** Service Desk / 2nd Line.  
**Why:** Ensures sustainable support after go-live.

---

## Step 5 — Sign-Off Generator (Acceptance Sheet)

**Input:** Interpreter output (plus Implementation evidence).  
**Output:** One-page business acceptance:
- Summary of what was delivered
- Confirmation MFA/Keeper enforced
- Statement: “remediation tested & accepted, no rollback required”
- Signatures: Business Owner + IT Security Approver

**Audience:** Business sponsor & CAB closure pack.  
**Why:** Closes loop — no change is “done” until business signs.

---

# Data Flow (Chained View)

      [BA Document]
             │
             ▼
    ┌────────────────┐
    │ Interpreter    │   →  Canonical truth doc
    └────────────────┘
             │
┌───────────┼───────────┐───────────────┐───────────────┐
▼           ▼           ▼               ▼               ▼

---

# Key Benefits of this Workflow

- **Consistency** → Interpreter ensures all outputs stem from the same truth.
- **Audience-driven** → each doc fits its reader: CAB, Engineer, Service Desk, Business.
- **Audit-ready** → every stage produces an artefact that can be filed in Confluence, Jira, or CAB pack.
- **Zero duplication** → no more rewriting the same facts four different ways.
- **Governance & Execution balance** → risk language separated from technical commands.  