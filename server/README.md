# Ganit Safar central monitoring backend

The existing Python foundation now supports authenticated classroom administration, PostgreSQL, role/school isolation, registered browser devices, rotating HttpOnly sessions, signed offline learning authorization and SSE dashboard updates. SQLite and the loopback HTTP server remain development options.

**No production deployment has been performed.** See the complete [delivery report](../docs/CENTRAL_MONITORING_REPORT.md) and [deployment/operations guide](../docs/CENTRAL_MONITORING_DEPLOYMENT.md).

## Local development

```bash
python3 -m venv .venv-central
.venv-central/bin/pip install -r server/requirements.lock
export GANIT_ENV=development
export GANIT_DB=/tmp/ganit-central.sqlite3
export GANIT_ALLOWED_ORIGIN=http://localhost:8080
.venv-central/bin/python server/manage.py create-admin --email YOUR_LOCAL_ADMIN_EMAIL
.venv-central/bin/python server/app.py --port 8787
```

The bootstrap prompts privately for a password; none is seeded. Sign in as administrator, create a school/classroom, create teachers and assign classrooms. Teachers change their initial password, register the whiteboard and set a private teaching PIN. They cannot enter the administrator dashboard.

A local Flutter frontend can use `GANIT_API_URL=http://127.0.0.1:8787 scripts/preview-local.sh`. Open `http://localhost:8080` to match the configured origin. This is a development preview, not production HTTPS hosting.

The production guide documents managed PostgreSQL/TLS, secrets, migrations, pinned frontend builds, the Docker/Gunicorn/Caddy layout, retention, limitations and acceptance checks. `manage.py` supports `migrate`, `create-admin`, `generate-key` and explicit `prune` operations.

## Tests

```bash
cd server
../.venv-central/bin/python -m unittest -v test_api test_transport
GANIT_TEST_DATABASE_URL=YOUR_DISPOSABLE_POSTGRES_URI ../.venv-central/bin/python -m unittest -v test_api
```

The PostgreSQL tests create and drop their own random test schema. Never use production as a test database. No child answer or score data is accepted by monitoring endpoints.
