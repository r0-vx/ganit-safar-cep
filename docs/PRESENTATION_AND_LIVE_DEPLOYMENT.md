# Live and presentation release — 1 November 2026

> Historical report. Demo sign-in pages, classroom demo mode and `/api/presentation/*` have been removed. See [the 2 November workflow update](SIGN_IN_SCHOOL_WORKFLOW_FIX.md) for current behaviour.

Both sites are deployed to the existing Vercel account:

- Classroom app: https://ganit-safar-smartboard.vercel.app/
- Dashboard: https://ganit-safar-dashboard.vercel.app/

The dashboard is a new Vercel project. Both sites use the same dedicated free Neon PostgreSQL database, with independent `ganit_live` and `ganit_presentation` schemas. The previously used local demonstration database was not uploaded. No paid plan, card, cloud subscription upgrade or Google Play service was added.

## Data switch

**Demo data OFF is the default.** The live schema initially contains the private administrator account and zero schools, classrooms, devices, activity events or usage totals. Teachers/classes must be created from the real administration dashboard; unavailable data is never replaced with samples.

**Demo data ON** opens a URL-scoped presentation session (`?presentation=1`). Switching modes reloads the page, preserving unrelated URL parameters and clearing the current in-memory question/result. It is an environment switch, not a change to the active quiz language or a way to keep an unfinished quiz across environments. The switch is available on web sign-in and dashboard toolbars. The persistent demo ribbon remains visible in the authenticated teaching application and dashboard.

The presentation dataset has one explicitly named presentation school, four demo classrooms and seven days of labelled sample chart history. Seeding creates no online boards, heartbeats, current lessons or fake event rows. New board registrations, sign-ins, heartbeats and teaching events are actual authenticated requests against this separate sandbox. Sample history remains sample history; the application never presents it as verified real school use.

Presentation identities, refresh/device-cookie names, local installation identities, signed offline leases, PIN keys, trusted times and upload queues are separate from live mode. A presentation bearer token is rejected by the live database. Context-local backend routing prevents simultaneous requests from changing one another's dataset. Demo accounts cannot administer live records. Presentation seeding is explicit and idempotent; ordinary requests never repopulate real records.

## Presentation on 2 November 2026

Use Demo data ON **on both sites**. The classroom account is `teacher@demo.ganitsafar.local`; the dashboard account is `presenter@demo.ganitsafar.local`. Passwords were delivered privately to the owner and are not embedded in JavaScript or source. These accounts are available now; no reminder or delayed activation is required.

1. Sign into the classroom app as the presentation teacher.
2. Choose a demo class, register the browser/board once, and choose a private local teaching PIN when prompted.
3. Sign into the dashboard separately as the presentation viewer.
4. Open a Learn lesson, Practice or Quiz in the classroom app. Its backend-recorded activity appears on the presentation dashboard automatically.
5. End the activity to see current activity counts change. Sign out of a board to mark it offline. Abrupt disconnects expire according to the configured 90-second heartbeat threshold.

The shared presentation dashboard account is read-only. Real administration uses the owner's private administrator credentials with Demo data OFF. Register actual schools and assigned teacher accounts there before using live mode in a school.

## Hosting and real-time behaviour

Vercel serves static Flutter assets and the Python API from the **same origin on each site**. This avoids cross-site credential-cookie dependencies. Both APIs access the same PostgreSQL schemas. The browser dashboard requests a fresh authenticated snapshot every three seconds, with no overlapping polls. It retains selected charts/search state, marks failed or stale updates clearly, and does not invent replacement numbers. Polling is near-real-time, not an instantaneous push guarantee. The supplied persistent-host deployment still supports SSE by leaving the polling build option at zero.

The backend requires production HTTPS/approved hosts, private runtime database and signing secrets, and explicit schema separation. PostgreSQL hostname/certificate validation uses a packaged public CA bundle. The compiled frontend contains the Ed25519 public-key pin only. API responses use `Cache-Control: no-store`. No passwords, database URI or private signing key are included in the static frontend. Deployment packaging copies only compiled assets and allowlisted server source/migrations; it excludes local SQLite databases, test credentials and preview data.

The same bilingual and touchscreen learning content remains in both releases. English/Marathi language switching keeps its existing behaviour within an environment. Individual answers and session scoreboards are not uploaded to central monitoring.

## Verification

- Full Flutter suite: **89 passed**, one managed-only test intentionally skipped in the default build.
- Separate managed-login configuration: **1 passed**.
- Final mode-URL regression and dashboard/layout suite: **16 passed** after the bidirectional-switch fix.
- Backend/domain/transport/presentation suite: **27 passed**.
- PostgreSQL presentation/live isolation suite: **5 passed** using disposable local schemas.
- Final analysis clean; pinned release web build successful.
- Both production APIs returned HTTP 200, PostgreSQL, schema version 5 and the expected signing public key, in live and presentation modes; API cache policy was `no-store`.
- Public live administrator sign-in visibly showed zero schools/classrooms/devices/sessions with the demo switch OFF.
- Public presentation viewer sign-in showed the separate four-class dataset and explicit demo labels.
- A deployment-verification board sent a real heartbeat/lesson-start event through the classroom site's API. The dashboard site's browser changed to one active lesson. Completion/logout changed the already-open dashboard to zero active lessons/zero online rooms without a refresh. The live database remained empty throughout. This was a deployment test, not a claim of a real school lesson.
- The verification board was signed out after the check. Its labelled sandbox record remains as a truthful test record.
- Production build assets and final deployment IDs/status are recorded in `validation/presentation-release/`.

Native Windows/Android installers and physical smartboard acceptance were not repeated. Hosted polling/functional checks are not a load test, penetration test or a guarantee that no bugs exist. Free hosting/database usage limits still apply; no paid quota was enabled.

## Rebuild

Use a stable private signing key in both Vercel projects. Keep `DATABASE_URL`, `GANIT_ENV=production`, `GANIT_DB_SCHEMA=ganit_live`, `GANIT_PRESENTATION_ENABLED=1`, `GANIT_PRESENTATION_SCHEMA=ganit_presentation`, `GANIT_LEASE_SIGNING_KEY`, `GANIT_PUBLIC_URL`, exact `GANIT_ALLOWED_ORIGINS` and trusted-proxy configuration in runtime secrets. Do not replace the database or signing key during an ordinary frontend release.

Build with `GANIT_API_URL=/api`, the matching **public** `GANIT_LEASE_PUBLIC_KEY`, and `GANIT_MONITOR_POLL_SECONDS=3` using `scripts/build-monitoring-web.sh`. Package each site using `scripts/package-monitoring-vercel.py`; it requires the explicit destination Vercel project ID. Deploy the generated package, not the repository or the Flutter assets alone. PostgreSQL migrations are idempotent. Refresh the public CA bundle as part of dependency/security maintenance.

To deliberately create a new sandbox, enable its schema and run `server/presentation.py` with privately supplied teacher/viewer passwords. Never run seeding inside the live dataset. The initial administrator was created through the local administrative setup over a certificate-verified database connection; there is no public bootstrap endpoint or default production password.

## Additional administrator account — 1 November 2026

At the owner's explicit request, an additional administrator login was provisioned independently in both live and presentation datasets. Its credentials are in the private owner access note, not in the static app bundle or this report. Sign-in and authenticated administrator dashboard access were verified against both public sites in both modes (four combinations); see `validation/presentation-release/shared-admin-checks.json`. Existing owner and teaching accounts were preserved. This is a database-only account change and required no application redeployment.

## Separate sign-in update

Use the dedicated classroom and dashboard `/sign-in` links. The classroom administrator now opens teaching rather than the monitoring dashboard. [Current entry links, presentation flow and verification](SEPARATE_SIGN_IN_PAGES.md).
