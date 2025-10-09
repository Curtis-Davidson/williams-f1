# Shared Account Remediation – Prompt Library

This library contains the five **CRAFT Master Prompts** used to transform raw Business Analyst documents into consistent, audit-ready artefacts for Shared Account remediation @WF1.

---

##  Index of Prompts

1. [Interpreter Prompt](./Interpreter-Prompt.md)
    - Extracts canonical truth from BA documents.
    - Produces clear, plain-English outputs: accounts, devices, users, exceptions, dependencies, risks.
    - Forms the *single source of truth* for all other prompts.

2. [CAB Generator Prompt](./CAB-Generator-Prompt.md)
    - Creates governance-ready CAB submissions.
    - Includes change summary, business justification, risks, rollback, testing, approvals.
    - Tailored for Change Advisory Board audience.

3. [Implementation Runbook Generator Prompt](./Implementation-Runbook-Prompt.md)
    - Produces detailed, step-by-step runbooks for engineers.
    - Covers account creation, group setup, device lockdown, MFA/Keeper enforcement, validation.
    - Zero ambiguity; ready for change execution.

4. [Support Document Generator Prompt](./Support-Doc-Prompt.md)
    - Generates post-implementation Service Desk runbooks.
    - Covers account overview, access rules, password/MFA reset, troubleshooting, escalation, monitoring.
    - Ensures sustainable operational support.

5. [Sign-Off Generator Prompt](./Sign-Off-Prompt.md)
    - Creates one-page acceptance sheets.
    - Confirms remediation is delivered, tested, accepted, MFA/Keeper enforced.
    - Signed by Business Owner & IT Security; archived in CAB pack.

---

##  Workflow Blueprint

All five prompts work in sequence, using the Interpreter as the canonical truth extractor.  

      [BA Document]
             │
             ▼
    ┌────────────────┐
    │ Interpreter    │   →  Canonical truth doc
    └────────────────┘
             │
┌───────────┼───────────┐───────────────┐───────────────┐
▼           ▼           ▼               ▼

[CAB Gen]   [Runbook]   [Support Doc]   [Sign-Off]
(Govern.)   (Engineer)  (Ops Support)   (Business Closure)


---

##  Usage Notes
- Always run the **Interpreter** first — it produces the canonical truth.
- Feed Interpreter output into **CAB / Runbook / Support / Sign-Off** prompts as required.
- Store each output in version control (GitHub, Confluence, or SharePoint).
- Tag each output with **Project ID + Date** for audit traceability.

---

##  Recommended File Layout

/Prompts
├── Interpreter-Prompt.md
├── CAB-Generator-Prompt.md
├── Implementation-Runbook-Prompt.md
├── Support-Doc-Prompt.md
└── Sign-Off-Prompt.md

/Outputs
├── Interpreter/
├── CAB/
├── Runbooks/
├── Support/
└── Sign-Offs/





