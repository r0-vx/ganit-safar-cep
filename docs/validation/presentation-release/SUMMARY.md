# Presentation/live deployment verification — 1 November 2026

- Both production projects are READY; their exact IDs and aliases are in deployments.json.
- 89 full-suite Flutter tests passed; one managed-only case skipped in the default suite and passed separately.
- 16 final mode URL/dashboard/layout checks passed after the bidirectional switch fix.
- 27 backend tests and five PostgreSQL dataset-isolation tests passed.
- Final analysis clean and pinned web release built.
- Both APIs report PostgreSQL schema version 5, live/presentation namespaces and no-store caching.
- Six final public HTML/JavaScript/WASM checks matched local artifacts by SHA-256.
- Public live sign-in: Demo data OFF and all school/classroom/device/usage totals zero.
- Public presentation login: separate four-class demo and labelled sample history.
- Already-open dashboard changed active lessons 1 to 0 and online classrooms 1 to 0 when a cross-site backend verification lesson ended and its test board signed out, without reloading.
- Final browser mode switch returned to live mode, restored the live account and still showed zero usage; no demo data leaked.
- Public teacher sign-in exposes four assigned demo classrooms; board enrollment verified.
- Creating the private local teaching PIN is left to the owner on first use. No agent-generated PIN was placed in browser storage.
- No native build, physical smartboard acceptance, remote CI run, load test or security audit was performed.

The backend verification board is explicitly named Deployment verification board and remains a signed-out record in the presentation dataset. The owner's registered presentation browser is separate. Credentials and database/signing secrets are excluded from this evidence folder.
