# Central monitoring: deployment and operations

The initial version was prepared locally on 1 November 2026. **A subsequent release is now deployed on Vercel**, using same-origin Python APIs, a dedicated free Neon database and three-second snapshot polling. See [the current release](PRESENTATION_AND_LIVE_DEPLOYMENT.md). Windows and Android builds remain on hold. The persistent-host/SSE option below remains available.

## Architecture

Serve the Flutter web application and `/api/*` through one HTTPS origin. Caddy serves static files, strips `/api`, and streams responses from a private Gunicorn/Flask service. The Python service stores authenticated management data in managed PostgreSQL. SSE uses database-backed snapshots, so separate Gunicorn workers see the same changes; there is no process-local dashboard database.

Use a persistent host that supports long-lived HTTP streaming. For the persistent-host/SSE option, use the supplied Gunicorn transport. The current Vercel option packages the Python API as a function beside each frontend and uses bounded HTTP snapshot polling, rather than a permanent streaming connection. Deployment must preserve credential cookies and backend state in PostgreSQL. Prefer the supplied single-origin layout. Cross-site cookie restrictions can prevent authentication even with `SameSite=None; Secure`; see [MDN cookie guidance](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Set-Cookie).

## Required configuration

Copy `server/.env.example` to `server/.env.production` outside version control and replace every placeholder. Configure secrets through the host's secret manager where available.

| Variable | Purpose |
|---|---|
| `GANIT_ENV=production` | Requires PostgreSQL, HTTPS origins/public URL, proxy trust configuration and a private signing key |
| `DATABASE_URL` | Managed PostgreSQL connection URI; explicit `sslmode=verify-full` recommended, with the provider CA if required |
| `GANIT_PUBLIC_URL` | Public HTTPS deployment address |
| `GANIT_DOMAIN` | DNS hostname for the supplied Caddy configuration |
| `GANIT_ALLOWED_ORIGINS` | Exact approved frontend origins, comma-separated; no wildcard |
| `GANIT_TRUSTED_PROXY_CIDRS` | Exact private proxy source address/CIDRs; example Compose proxy is `172.31.98.2/32` |
| `GANIT_LEASE_SIGNING_KEY` | Private base64url-encoded 32-byte Ed25519 signing key; backend only |
| `GANIT_COOKIE_SAMESITE` | `Lax` by default; same-origin hosting recommended |
| `GANIT_ACCESS_TTL` | Access token lifetime, default 900 seconds |
| `GANIT_REFRESH_TTL` | Rotating refresh/device-cookie lifetime, default 2,592,000 seconds |
| `GANIT_OFFLINE_TTL` | Signed learning authorization lifetime, default 604,800 seconds |
| `GANIT_OFFLINE_AFTER` | Online status expiry, default 90 seconds |
| `GANIT_SSE_INTERVAL` | Database snapshot check interval, default 2 seconds |

Development-only variables: `GANIT_DB` selects a SQLite file; `GANIT_LEASE_KEY_FILE` selects a private development signing-key file; `GANIT_ALLOWED_ORIGIN` is the single-origin fallback. `GANIT_TEST_DATABASE_URL` is exclusively a disposable integration-test database. Production refuses SQLite. Do not reuse test trust authentication, test users or the local preview signing key.

Frontend compile-time variables are public: `GANIT_API_URL`, `GANIT_MANAGED=true`, `GANIT_APP_VERSION=1.2.0`, and `GANIT_LEASE_PUBLIC_KEY`. **Never pass the private signing key or database URI to Flutter.** The production build script requires an HTTPS API URL and public-key pin.

## Prepare the backend

From the repository root:

```bash
python3 -m venv .venv-central
.venv-central/bin/pip install -r server/requirements.lock
.venv-central/bin/python server/manage.py generate-key
```

Store the generated value privately as `GANIT_LEASE_SIGNING_KEY`. Load the production environment through your host or shell without printing it. Then:

```bash
.venv-central/bin/python server/manage.py migrate
.venv-central/bin/python server/manage.py create-admin --email YOUR_ADMIN_EMAIL --name 'System administrator'
```

`create-admin` reads and confirms the password privately, never through a command-line argument. There are no default production credentials. Administrator-created accounts must change their initial password before using the app. Reset tokens are single-use, expire after 30 minutes, and must be handed to the teacher privately; this release does not send reset emails.

Back up the database before upgrades. Migrations are idempotent and versioned in `server/database.py` and `server/migrations/`:

1. Existing foundation tables.
2. Monitoring entities, scopes and migration of legacy classroom/teacher records; retires unbound legacy sessions and requires legacy accounts to change passwords.
3. PostgreSQL epoch timestamps use double precision, including upgrades from old float4 columns.
4. Device connection state for online/offline/logout/revocation transitions.
5. First observation time of the current device app version.

An advisory transaction lock serializes PostgreSQL migration startup across workers. Test upgrades on a database copy before production rollout. There is no destructive automatic rollback.

## Build the frontend

Obtain the public key from the configured backend's `GET /health` or derive it administratively from the private key. Verify it against the intended server before building.

```bash
export GANIT_API_URL=https://YOUR_DOMAIN/api
export GANIT_LEASE_PUBLIC_KEY=YOUR_PUBLIC_ED25519_KEY
./scripts/build-monitoring-web.sh
```

The script creates `build/production-web`, sets managed mode, and bundles Flutter renderer resources locally instead of relying on a renderer CDN. Web first installation and teacher/device authorization require connectivity. Temporary disconnection after loading and authorization was tested; cold offline browser installation is not certified by this release.

## Host with HTTPS

The example `deployment/monitoring.compose.yml` uses an external managed PostgreSQL service, a non-root backend container, a private network and Caddy TLS. It does not create a public development database.

1. Point real DNS to the host and permit HTTPS/ACME ports.
2. Set the production environment, PostgreSQL TLS/CA, database firewall and backup policy.
3. Build `build/production-web` as above.
4. Review `GANIT_TRUSTED_PROXY_CIDRS`; use the actual proxy address on another host/platform.
5. Run the following **on the production host when deployment is authorized**:

```bash
docker compose --env-file server/.env.production -f deployment/monitoring.compose.yml build
docker compose --env-file server/.env.production -f deployment/monitoring.compose.yml run --rm backend python server/manage.py migrate
docker compose --env-file server/.env.production -f deployment/monitoring.compose.yml run --rm -it backend python server/manage.py create-admin --email YOUR_ADMIN_EMAIL
docker compose --env-file server/.env.production -f deployment/monitoring.compose.yml up -d
```

The backend has no host port. Exposing Gunicorn directly invalidates the proxy trust boundary. HTTP or forwarded HTTPS headers from an untrusted peer are rejected. Keep the database private to the backend. Use a separate migration-capable credential during releases if the runtime database role should have fewer privileges.

For a host-managed TLS proxy, use `gunicorn --bind 127.0.0.1:8000 --workers 2 --worker-class gthread --threads 16 --timeout 120 server.wsgi:application` and configure the proxy to preserve streaming. Each open SSE connection uses a thread; size workers/threads for dashboard subscribers and REST traffic. [Gunicorn design guidance](https://gunicorn.org/design/) explains streaming worker considerations. PostgreSQL `verify-full` checks both certificate trust and hostname; see [PostgreSQL TLS documentation](https://www.postgresql.org/docs/17/libpq-ssl.html).

In managed build environments, preserve the configured HTTPS proxy and certificate trust. The Dockerfile accepts a BuildKit secret `proxy_ca` for a combined CA bundle. It is not stored in image layers. Never disable certificate verification to build or connect.

## Acceptance after hosting

- Check HTTPS `/api/health`: `ok=true`, PostgreSQL, schema version 5, expected public key.
- Create a school, classroom, teacher and assignment; sign in with a separate board browser.
- Complete the initial password change; register the board; set a private local teaching PIN.
- Confirm HttpOnly/Secure cookies, in-memory access tokens, role/school separation and no console credentials.
- Open a second independent classroom installation and an administrator dashboard. Check both devices and activity updates without refreshing.
- Disconnect one classroom. Learning and the session result should remain usable; status expires after 90 seconds. Reconnect and confirm events are counted once.
- Revoke one device and disable one teacher; check locking/rejected sign-in. Revoke cannot be undone; use a fresh approved installation when replacing a device.
- Test password reset, sign-out, expiry, supported-version policy, mobile layout, Marathi and bilingual modes on the actual school network.

These are production acceptance steps, not claims that a public deployment has passed them.

## Operations, retention and limits

Use managed PostgreSQL encrypted storage, restricted credentials and scheduled backups. Keep signing keys stable: changing the key requires a new pinned frontend build and teacher authorization; old offline grants then fail verification. Browser site data must be preserved for installation identity, private PIN and queue continuity. Clearing cookies/site storage requires supervised re-enrollment with a new installation identity; stale device registrations should be revoked.

Run `python server/manage.py prune` on an operator-managed schedule. It removes raw heartbeats/events/errors older than 30 days, new audit logs older than 180 days, expired session/reset/device/refresh rows after their grace periods, and obsolete rate-limit rows. Daily anonymous aggregates remain. Existing legacy `audit` records are preserved and need a separate retention policy if populated. No retention job is silently installed.

Queued events are capped at 1,000; oldest events may be dropped with a visible teacher warning when full. A batch contains at most 100 events. Reconnection retries retain event IDs. Events older than 30 days are acknowledged without adding analytics. Scores and answers are never part of this queue.

An offline installation cannot receive a new revocation until connectivity returns. The signed grant limits this window to seven days by default. Local PINs and browser storage do not protect against an attacker with operating-system/devtools access; configure school devices as managed kiosks.

The database currently batches/scopes an initial small-school snapshot and retains bounded dashboard histories. Global-scale operation requires pagination, tighter query-level scoping/index profiling, a connection pool and capacity/load tests. No global-scale or security penetration certification is claimed. Availability is estimated from heartbeat observations, not exact network uptime.

## Local verification commands

```bash
flutter analyze
flutter test
flutter test test/managed_gate_test.dart --dart-define=GANIT_API_URL=http://localhost:8789
cd server
../.venv-central/bin/python -m unittest -v test_api test_transport
GANIT_TEST_DATABASE_URL=YOUR_DISPOSABLE_POSTGRES_URI ../.venv-central/bin/python -m unittest -v test_api
```

PostgreSQL integration tests create/drop only a random `ganit_test_*` schema in the specified test database. Never point this at production. The local preview uses an isolated `ganit_preview_*` schema with disposable users, plus three loopback frontend origins to model independent devices.
