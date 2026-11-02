# Ganit Safar: central classroom monitoring delivery report

> Historical local implementation report. The subsequent Vercel/PostgreSQL release, demo/live isolation and public verification are documented in [the current deployment report](PRESENTATION_AND_LIVE_DEPLOYMENT.md). Its original no-deployment statements below refer to the earlier local phase.

**1 November 2026 — deployment-ready source and local verification. No deployment occurred.**

This phase extends the existing Python management backend and Flutter web application. It preserves the 79-entry chapter directory, Learn, Practice, Quiz, teacher tools, local learning progress, translation-review structure and temporary quiz results. Windows and Android work is on hold. The existing public Vercel site remains on its previous release.

## 1. Administrator dashboard

Nine working pages read authenticated backend data: Overview, Schools, Classrooms, Teacher accounts, Devices, Usage analytics, Alerts, App versions and Audit log. Navigation and forms use the current English/Marathi/bilingual selection. Touch-sized controls, wrapping cards, scrolling forms and a page selector support smaller screens without requiring a desktop sidebar.

Overview reports schools, classrooms, devices, online/offline/recent activity, active teachers, lesson/practice/quiz counts, daily/weekly usage, outdated devices, attention states, recent anonymous learning events, connection/account events and errors. Connection loss is displayed with the time of the last live snapshot. Data is not fabricated when the backend is unavailable.

## 2. School, classroom and account management

Super administrators create/edit/disable schools with location, code and administrator contact. Classrooms have a school, grade, section, status and multiple teacher assignments; they can be renamed, disabled or archived. Each classroom shows its devices, activity and usage.

Account creation supports super administrator, school administrator, teacher and viewer roles. Teachers receive an initial password and one or more classroom assignments. The account page supports name/status changes, classroom assignment changes, enable/disable, single-use password reset and session revocation. Passwords are cleared from UI controllers and are not returned after creation. First-login password change is enforced by the API, not just the screen.

School administrators manage teachers only within their assigned schools. A teacher shared across schools cannot be modified by a school administrator who lacks all of those scopes. Staff lists and classroom IDs are filtered to the viewer's school. Device history remains school-scoped after device reassignment; the new school cannot read the old school's events/errors. Super administrators retain complete device history.

## 3. Teacher sign-in and child-facing access

Managed builds open with sign-in. A new teacher must change the initial password, choose an assigned classroom, register the current browser/whiteboard, and configure a private teaching PIN. The assigned school/classroom is displayed. The child-facing screen opens with Teacher Mode locked.

Protected settings, connection/account pages, password controls and teacher tools require the teaching gate. Teachers cannot access the central administrator dashboard. Server role checks also reject direct requests. When access is revoked, an app-wide login screen blocks underlying routes, pointer input, focus and semantics. The login screen has its own navigation/selection overlay and supports password-reset navigation.

Access expiry, incorrect credentials, disabled accounts, rejected device identity, disconnected service, sign-out and re-authentication have translated feedback. Standalone development mode preserves existing local learning; the production build script sets managed mode so a missing API URL cannot create an authentication bypass.

## 4. Device registration and management

A random persistent installation ID identifies a browser installation. Registration requires teacher credentials, an active assigned classroom and a device name. The API issues an HttpOnly identity-proof cookie, binds the session to the installation and returns classroom metadata. Copying only the public installation ID does not authorize another browser. Existing registrations cannot be silently moved by teachers.

Administrators can rename, reassign, activate/deactivate, revoke, force logout or require sign-in again. Device cards show identity, classroom/school, teacher, current version, the first observation time of that version, online state, last heartbeat/login, registration time, current chapter/mode, health and latest error category. History and error panels fetch server records.

Device proof expiry is renewed during valid session issuance/refresh. Revocation is permanent for that registration. Clearing browser site data/cookies requires supervised re-enrollment under a new installation identity and revocation of the old registration. This is browser identity, not hardware attestation.

## 5. Heartbeat design

Teacher installations send a heartbeat every **45 seconds**, plus activity transitions/reconnection. Payloads contain assigned classroom, app version, mode, current grade, approved chapter identifier, actual last interaction time, network/health state, error count and anonymous active-session count. Device/teacher identities are validated against the server session and cookie proof; the browser cannot nominate an arbitrary teacher.

Online status expires after **90 seconds** by default. A newly registered device without a heartbeat is marked never connected. Signed-out, disabled, revoked, unsupported/outdated and unhealthy devices have separate status handling. Recent activity uses a five-minute window. The dashboard derives freshness from server timestamps and does not assume that a remembered browser session is online.

## 6. Live events and SSE

Lesson, Practice and Quiz hooks record start, completion and departure. Error reports send only approved error categories. Teacher login/logout, registration, connection/disconnection, revocation, version mismatch and session expiry produce audit/system records. Learning events and important system events appear in dashboard snapshots.

Authenticated SSE checks database state every two seconds, streams changed snapshots and sends keepalives. It is compatible with multiple Gunicorn workers because shared state is in PostgreSQL. Expired/revoked administrator streams require authentication again; server failure closes the stream with a generic service-unavailable event, and the client reconnects automatically. A manual dashboard refresh is not required.

Connection-loss detection and offline alert evaluation occur during dashboard snapshot/SSE reads. There is no separate always-running alert scheduler. This is sufficient for an open central dashboard; unattended notifications/email/SMS are not implemented.

## 7. Offline authorization, queue and reconnect

After successful enrollment, the device receives an Ed25519-signed, device-bound, teacher/classroom-bound learning authorization, valid seven days by default. Dart verifies the Python signature. Production builds pin the public key. Learn, Practice, Quiz and temporary results continue through temporary network/server failure.

Teacher Mode uses a private 6–12 digit PIN, stored as a salted PBKDF2-HMAC-SHA256 verifier with 120,000 iterations, separate from learning backups. There is no universal PIN in managed mode. An authenticated account password can authorize initial online setup; a PIN must be configured for later offline Teacher Mode use. Five incorrect local attempts cause a five-minute in-memory cooldown. Reloading resets that cooldown; operating-system/kiosk restrictions remain necessary.

Anonymous events enter a persistent queue, at most 1,000 records. Reconnect sends batches of 100, retaining event IDs until acknowledged. Database constraints deduplicate both event IDs and device/session/event-type combinations. A lost response can be retried safely. Events remain partitioned by their originating teacher and classroom, preventing a later teacher/reassignment from misattributing old events. Over-limit loss has a visible teacher warning.

Sign-out clears local authorization immediately. If the server is unreachable, a pending logout is remembered and processed before cookie refresh on the next start, preventing silent sign-in after an offline logout. Known revocation/disabled-account responses clear the offline authorization and lock the app.

An offline device cannot receive a new revocation until reconnecting. Default signed authorization expiry bounds that interval to seven days. Authorization, queue continuity and PINs require browser storage. A loaded app was tested offline; cold offline web installation/reload is not certified here.

## 8. Database schema

Production uses PostgreSQL; SQLite remains a local development/test option. Five versioned migrations preserve the existing foundation and add monitoring. PostgreSQL epoch timestamps use double precision to avoid heartbeat rounding errors.

| Entities | Purpose |
|---|---|
| `users`, `roles`, `teachers` | Staff identities, hashes, account state and role |
| `schools`, `user_schools` | School records and server authorization scopes |
| `classrooms`, `classroom_assignments` | School/grade/section and multiple teachers |
| `devices`, `device_sessions` | Current installation state and hashed cookie proofs |
| `sessions`, `refresh_tokens` | Hashed access tokens and rotating refresh families |
| `password_reset_tokens` | Hashed, expiring, single-use reset tokens |
| `heartbeats` | Anonymous application/device health observations |
| `activity_events`, `usage_daily` | Idempotent learning activity and classroom aggregates |
| `app_versions` | Approved/supported version policy |
| `error_events` | Approved error categories, without raw stacks or content |
| `audit_logs` | Actor/action/target/school/time administration and system records |
| `alerts`, `alert_rules` | Scoped notices and configurable thresholds |
| `login_attempts`, `system_state`, `schema_migrations` | Throttling, revisions and migrations |

Legacy `audit` records are retained. Relationships and indexes cover school/classroom/teacher/device assignment and event histories. Migrations serialize startup with a PostgreSQL advisory transaction lock.

## 9. Authentication and authorization

Passwords use salted scrypt. Access tokens are random, hash-stored and expire after 15 minutes; the browser keeps them in memory. Refresh tokens use HttpOnly cookies, rotate on use, are hash-stored and have a 30-day default lifetime. Reuse revokes the token family and raises an alert. Device identity uses a separate HttpOnly proof cookie. Production cookies are Secure.

Server checks enforce roles, school scopes, classroom assignments, account/device/classroom/school status, first password change, refresh expiry, device binding and revocation. Login/reset/reauthentication throttling uses database state, with account/token limits and a source-address limit. Production requests require HTTPS through a configured trusted proxy; spoofed forwarding headers from other peers are rejected. CORS allows explicit origins with credentials. JSON bodies are limited to 128 KiB. Responses use no-store and nosniff.

Private keys, database URLs, passwords and refresh/device cookies are excluded from Flutter assets and learning backup exports. Portable exports also omit the legacy standalone PIN verifier; restoring an old file preserves the device’s current PIN. Production needs an operator-managed TLS host and PostgreSQL credentials; those have not been supplied or provisioned.

## 10. Privacy boundary

The monitoring API accepts a strict allowlist. Unknown question/answer/name/score fields are rejected. Chapter references are approved IDs rather than arbitrary content text. No child names, student accounts, profiles, answers, mistakes, camera/microphone data or raw error stacks are uploaded. There is no central score or answer-history column in the monitoring schema.

Staff names/emails, school contacts, teacher assignment IDs and installation/application usage are central administrative data. Source addresses are hashed for throttling. Offline authorization contains staff/classroom metadata and is signed, not encrypted. Local learning storage remains distinct from authentication and monitoring state.

## 11. Analytics

The dashboard derives seven-day UTC metrics from actual events and daily aggregates: daily/weekly active classrooms, lesson starts/completions, Practice/Quiz starts, mean completed-session duration, daily usage, chapter usage/completion, most/least-used chapters, grade-level Practice/Quiz counts, teacher activity, device version distribution, error frequency and estimated connected/offline duration.

Availability is a heartbeat-based estimate, not exact network uptime. No individual student score or answer contributes to these metrics. The legacy team tool remains local and is not a separate centrally tracked team competition.

## 12. Alerts

Implemented alerts cover prolonged offline state, repeated login failures, revoked devices, outdated/unsupported versions, repeated app errors, unhealthy heartbeat, legacy/unassigned devices, unknown or invalid device proofs, disabled teachers and suspicious refresh reuse. School administrators configure offline duration, error-count and login-failure thresholds for their schools. Alerts show severity, context, time, translated description and open/resolved state; administrators resolve/reopen them. Healthy reconnects automatically resolve offline/unhealthy notices.

New registration requires a valid assignment, so ordinary enrollment cannot create an unassigned device. Legacy orphaned device records are surfaced as super-administrator alerts and require supervised repair/re-enrollment. Alerts are dashboard notices; no outbound messaging service is used.

## 13. Version monitoring

Super administrators add/approve versions, mark versions outdated and disable unsupported versions. Devices report their current version; the system records when that version was first observed, distribution by classroom and device update needs. This observation time is not a claimed operating-system installation timestamp. Unsupported versions are blocked during online heartbeat/synchronization. Offline learning is not forcibly updated. No automatic installer/update download was added.

## 14. Verification performed

Automated evidence and browser observations are in `docs/validation/monitoring/` and `docs/monitor-screenshots/`. Final counts are recorded in the verification summary there.

- Flutter analysis; complete existing and new test suite; a separate managed-lock regression test.
- Dashboard layout/SSE tests at 375×812, 768×1024 and 1920×1080 with bilingual text scaled to 140%; a directly routed teacher is denied administrator UI.
- Dart tests for Python signature verification/tamper/expiry, offline queue and lost acknowledgements, revocation, private PIN hashing, memory-only access, streamed updates, offline sign-out/reload and central server failure.
- Real HTTP tests on SQLite and PostgreSQL 17: account creation/change/reset, all roles, school isolation, shared teachers, enrollment/proof checks, two SSE subscribers, two classroom clients, automatic stale status/reconnect, idempotency, privacy rejection, logout/expiry/reuse, revocation, disabled users/classes, thresholds, versions and migrations.
- WSGI tests for trusted HTTPS proxy enforcement, spoofed forwarding headers, CORS/body limit, generic service failure/SSE shutdown, production SQLite refusal, cookie flags, password whitespace and legacy migration.
- Non-root Docker image build and local PostgreSQL-connected health smoke test.
- Actual browser test: one administrator app plus two independent teacher app installations; 15 classrooms were created through authenticated API calls. Two registered boards appeared automatically. Disconnecting board A caused the dashboard to move from two online classrooms to one after expiry; reconnecting returned it to two without refreshing.
- Board A completed a bilingual lesson, opened Practice, retained its answer while using Help, finished an offline five-question quiz at 5/5 and switched to Marathi without losing state. Its current result survived reconnect. Six learning events synchronized once: lesson start/complete, Practice start/leave, Quiz start/complete. The database received no answers or score.
- The final browser pass also checks the repaired login overlay, revocation lock and an unaffected second device. See the verification summary for the recorded result.

The live local demonstration school, 15 classrooms and test accounts are isolated fixtures, not production seed data or hardcoded dashboard values. Private test credentials are outside the repository.

## 15. Failures found and corrected

Earlier test runs found and fixed PostgreSQL float4 epoch rounding, a revoked-device login path, offline authorization expiry lock ordering, legacy PIN-verifier export/restore, standalone PIN feedback regression and missing text-selection overlay in the managed login lock screen. The overlay regression test also caught and fixed a shared HeroController conflict between navigators. A two-worker container smoke test caught a development signing-key publication race; atomic publication and an eight-process regression test fixed it. Browser error counters before that repair correctly marked affected boards unhealthy; a fresh corrected client is checked in the final browser pass.

The environment's optional WebAssembly dry-run compiler exited 252. The supported JavaScript web release builds successfully with `--no-wasm-dry-run`; WebAssembly deployment is not claimed. The final verification summary lists remaining failed checks, if any, instead of treating these earlier failures as still open.

## 16. Known limitations

- No public backend, managed database, production TLS/domain acceptance or deployment was performed. No Windows/Android binary was rebuilt or tested. Their existing CI build workflow is now manual-only; a separate monitoring workflow was added but has not run on GitHub.
- Internet is required for initial enrollment, server authentication/administration and live monitoring; valid loaded learning continues through temporary loss. Offline revocation cannot be immediate.
- First-login password changes were verified through real HTTP; private PIN storage/unlock was verified in Dart. The browser walkthrough does not claim manual acceptance of every password/PIN setup dialog or every administrator form.
- New Marathi operator labels are manually authored, use the existing three-mode system and retain the review model. No claim of professional language review, Bhashini calls or automatic editorial approval is made.
- This monitoring phase preserves existing curriculum content. It does not certify every existing starter lesson's illustrations, wording or mathematical visual equivalence; some starter chapter visuals are generic objects rather than exact count models.
- Analytics and histories are deliberately bounded. An open dashboard evaluates alerts. There is no unattended notification worker, email delivery, MFA, hardware attestation, remote screen viewing or remote device control.
- Browser installation identity assumes a managed school device/profile. Multiple independent devices were modeled with separate origins; multiple simultaneous teacher identities in one browser installation are not certified.
- Queues have a cap; old/incompatible-owner events are not attributed to a new teacher. Availability is estimated. Keep device clocks correct.
- Local PIN cooldown is in memory; kiosk/OS security remains necessary. A user with full local machine/devtools control is outside the child-facing PIN boundary.
- Fifteen configured classrooms and two concurrently running browser classrooms were tested. Fifteen simultaneously active physical boards and global-scale capacity were not load-tested.

## 17–18. Production variables and deployment

See [deployment and operations](CENTRAL_MONITORING_DEPLOYMENT.md) for every variable, PostgreSQL/TLS setup, migrations, private administrator bootstrap, pinned managed frontend build, Docker/Caddy/Gunicorn hosting, retention and production acceptance commands. All dependencies and runtime technologies are free/open-source; no paid API or mandatory cloud account is used for standalone learning. Central hosting is the operator's choice.

## 19–21. Required confirmations

- **No unnecessary child data is collected:** central records contain staff, school, device and allowlisted anonymous usage/health metadata. Individual quiz answers, names and results are excluded.
- **New quiz scoreboards remain temporary:** current-session answers, mistakes, accuracy, stars and score stay in device memory. They are not added to permanent central or local quiz history. Language switching/reconnect preserves the active result; exit/reset/new session clears it under the existing session flow.
- **The dashboard is backed by real data:** authenticated REST/SSE reads the Python/PostgreSQL system. Multiple running browser installations and automatic online/offline/activity changes were observed without manual refresh. Test fixtures are explicit and separate from production.
- **No deployment occurred.**
