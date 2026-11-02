# Local verification — 1 November 2026

No production deployment, GitHub push or native build occurred.

| Check | Result |
|---|---|
| Flutter analysis | No issues |
| Complete default Flutter test suite | 78 passed; one managed-only test intentionally skipped |
| Managed-only lock/login regression | 1 passed with managed API compile flag |
| SQLite API + WSGI/configuration/migration/key-race tests | 22 passed |
| PostgreSQL 17 HTTP integration tests | 15 passed |
| JavaScript web release, bundled renderer resources | Built successfully |
| Non-root backend container, read-only filesystem and tmpfs | Built and started with two Gunicorn workers |
| Container health | PostgreSQL, schema 5, ok=true |
| Production TLS enforcement | Trusted/untrusted proxy and cookie flags tested; real hosted TLS/managed database not provisioned |
| GitHub Actions | Monitoring workflow added, not run remotely; native workflow now manual-only |
| Remaining failed checks | None in the final runs |

The optional environment WebAssembly dry run failed earlier (252); the supported JavaScript target was built with --no-wasm-dry-run. WebAssembly is not certified.

## Real browser sessions

Three running app origins modeled independent installations: administrator http://127.0.0.1:8082, board A http://127.0.0.1:8083 and board B http://127.0.0.1:8084. These used Gunicorn http://127.0.0.1:8789 and an isolated PostgreSQL preview schema. Fifteen classrooms, one school and two teachers were provisioned through real authenticated HTTP. Dashboard values came from the backend.

- 16:16 UTC: both boards registered; dashboard automatically showed two devices and two online classrooms.
- Board A was disconnected using tab-scoped network emulation; board B and the administrator remained connected. Board A displayed disconnected/learning continues.
- Board A opened Class 1 Addition, completed its lesson, used Practice and Help, answered the same question, then finished a five-question quiz at 5/5. Marathi switching preserved the active answer/question.
- After heartbeat expiry, the open SSE dashboard changed from two online classrooms to one with no manual refresh.
- 16:19 UTC: connectivity restored. The current-session result stayed visible. The dashboard returned to two online classrooms, and six learning events synchronized: lesson started/completed, Practice started/left, Quiz started/completed.
- API/DB checks confirmed one quiz start/completion, unique event/session/type keys and no individual answer/score fields. Later heartbeats did not duplicate that quiz.
- The login-overlay issue discovered in the initial browser pass was fixed and regression-tested. Fresh corrected sessions signed in without new console rendering errors; both boards reported healthy with zero current-run errors.
- 16:33 UTC: a fresh active lesson appeared automatically on the dashboard, with two online classrooms and one active lesson. Screenshots show this phase.
- 16:33–16:34 UTC: administrator revoked board A through the Devices page. Its active lesson was covered by the locked sign-in screen at the next authenticated request. A new sign-in attempt did not restore learning. Board B continued sending heartbeats and remained connected.
- Browser refresh cleared the temporary result. Local lesson progress survived. New quiz answers/results were not persisted centrally or added to permanent local quiz history.

Offline mode emulation was restored to normal after testing. The temporary container smoke service on port 8788 was stopped after its health check. The local main API, PostgreSQL preview and frontend previews remain available for review. The administrator and second-board browser tabs were retained. Board A remains deliberately revoked in the test data.

## Scope of acceptance

Passwords/first-login change/reset, disabled accounts, all role/school boundaries, duplicate identity rejection, revoked reconnect, token expiry/rotation/reuse, central failure, migrations and privacy rejection were tested through HTTP/Dart/WSGI tests. Private PIN hashing/unlock and sign-out while offline were tested in Dart. Responsive dashboard/SSE tests cover 375×812, 768×1024 and 1920×1080 at 140% bilingual text. This is not acceptance on physical Android/Windows boards, fifteen simultaneous physical boards, a public host, every administrator dialog or professional Marathi review.

See ../../CENTRAL_MONITORING_REPORT.md and ../../CENTRAL_MONITORING_DEPLOYMENT.md for features, schema, privacy, deployment and limitations. Exact test/build logs and SHA-256 hashes are alongside this file. Screenshots are in ../../monitor-screenshots/.
