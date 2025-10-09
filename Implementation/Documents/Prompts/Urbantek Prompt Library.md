# Urbantek Prompt Library

Central library of master prompts for Urbantek development, infra, and architecture work.  
Each prompt is version-controlled, Markdown-formatted, and linked here for quick retrieval.

---

## Index

### 1. Core Infrastructure Prompts
- [UT-NoBS v3.1 — Principal Network & Storage Architect (MikroTik/DNS/TrueNAS/Dell/ZFS)](./UT-NoBS-v3.1.md)  
  Hardened persona for all infra work: MikroTik RouterOS, DNS privacy, TrueNAS/ZFS, Dell rack servers.  
  Includes integration, storage guard, process guard, and loop/noise guard.

- [Interpreter Prompt](./Interpreter.md)  
  Parse technical documents and config files, translate into actionable steps.

- [CAB Generator Prompt](./CAB-Generator.md)  
  Create Change Advisory Board-ready implementation plans.

- [Support Runbook Generator Prompt](./Support-Runbook.md)  
  Build service desk / operations runbooks from technical procedures.

- [Sign-Off Generator Prompt](./Sign-Off-Generator.md)  
  Produce completion/validation documents for infra projects.

---

### 2. Development Prompts
- [CloudHealthLink Dev Architect Prompt](./CHL-Dev-Architect.md)  
  Guides AI-assisted development across CHL stack: FastAPI, Postgres, Proxmox integration, AI memory.

- [Postgres Tuning Prompt](./Postgres-Tuning.md)  
  Expert-level database tuning for shared_buffers, WAL, replication.

- [AI Memory Node Prompt](./AI-Memory.md)  
  Persona for building and verifying AI conversation logging architecture.

---

### 3. Security & Observability Prompts
- [SIEM & Threat Intel Prompt](./SIEM-Threat-Intel.md)  
  Persona for designing log pipelines, ingesting blocklists, pushing intel feeds.

- [Observability Architect Prompt](./Observability-Architect.md)  
  Grafana/Prometheus/Loki/Fluent Bit integration prompt.

---

### 4. Utilities
- [Markdown Exporter Prompt](./Markdown-Exporter.md)  
  Export infra logs/conversations into Markdown for compliance/archive.

- [Prompt Hardening Checklist](./Prompt-Hardening-Checklist.md)  
  Guidance for reviewing/upgrading prompts (e.g., from v3.0 → v3.1).

---

## Usage
1. Clone the repo locally.
2. Open in IntelliJ / VSCode for Markdown editing.
3. When starting a new session with AI, copy the required prompt verbatim.
4. Track changes in Git with semantic commit messages.

---

## Contributing
- New prompts: place in this folder as `Prompt-Name-vX.X.md`.
- Update `README.md` with a one-line description and link.
- Keep every previous version intact (never overwrite).
- Use tags/releases for major prompt revisions (e.g., `v3.0`, `v3.1`).

---