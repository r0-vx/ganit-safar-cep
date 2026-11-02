"""Transport/configuration regressions separate from domain integration tests."""
import importlib
import os
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import app
import database


class TransportTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.old_db, self.old_url = app.DB, app.DATABASE_URL
        app.DB, app.DATABASE_URL = self.tmp.name + '/transport.sqlite3', ''
        app.init()
        self.wsgi = importlib.import_module('wsgi')
        self.client = self.wsgi.application.test_client()

    def tearDown(self):
        app.DB, app.DATABASE_URL = self.old_db, self.old_url
        self.tmp.cleanup()

    def test_trusted_tls_proxy_and_no_header_spoofing(self):
        with patch.object(app, 'ENV', 'production'), patch.dict(os.environ, {'GANIT_TRUSTED_PROXY_CIDRS': '172.31.98.2/32'}):
            self.assertEqual(self.client.get('/health', headers={'X-Forwarded-Proto': 'https'}).status_code, 400)
            self.assertEqual(self.client.get('/health', environ_overrides={'REMOTE_ADDR': '172.31.98.2'}).status_code, 400)
            self.assertEqual(self.client.get('/health', headers={'X-Forwarded-Proto': 'https'}, environ_overrides={'REMOTE_ADDR': '172.31.98.2'}).status_code, 200)

    def test_body_limit_and_cors(self):
        self.assertEqual(self.client.post('/login', data='x' * 131073, content_type='application/json').status_code, 413)
        self.assertEqual(self.client.options('/login', headers={'Origin': 'https://unapproved.invalid'}).status_code, 403)
        response = self.client.get('/health', headers={'Origin': app.ORIGIN})
        self.assertEqual(response.headers['Access-Control-Allow-Credentials'], 'true')
        self.assertEqual(response.headers['Cache-Control'], 'no-store')

    def test_server_failure_is_generic_and_sse_ends_cleanly(self):
        with patch.object(app, 'connection', side_effect=RuntimeError('PRIVATE database details')):
            response = self.client.get('/health')
            self.assertEqual(response.status_code, 500)
            self.assertNotIn(b'PRIVATE', response.data)
            self.assertIn(b'service_unavailable', next(app.event_stream({})))

    def test_production_refuses_sqlite(self):
        with patch.object(app, 'ENV', 'production'):
            with self.assertRaisesRegex(ValueError, 'PostgreSQL'):
                app.init()

    def test_production_cookie_flags_and_password_whitespace(self):
        with patch.object(app, 'ENV', 'production'):
            value = app.cookie('test', 'value', 10)
            self.assertIn('HttpOnly', value)
            self.assertIn('Secure', value)
            self.assertIn('SameSite=Lax', value)
        self.assertEqual(app.secret({'password': '  correct horse battery  '}, 'password'), '  correct horse battery  ')

    def test_development_signing_key_is_atomic_across_workers(self):
        import subprocess
        import sys
        target = self.tmp.name + '/concurrent.key'
        env = dict(os.environ, GANIT_ENV='development', GANIT_LEASE_KEY_FILE=target)
        env.pop('GANIT_LEASE_SIGNING_KEY', None)
        workers = [subprocess.Popen([sys.executable, '-c', 'import app; print(app.public_key())'], env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE) for _ in range(8)]
        results = [worker.communicate(timeout=10) for worker in workers]
        self.assertTrue(all(worker.returncode == 0 for worker in workers))
        self.assertEqual(len({out.strip() for out, _ in results}), 1)
        self.assertEqual(len(Path(target).read_bytes()), 32)
        self.assertEqual(Path(target).stat().st_mode & 0o777, 0o600)

    def test_upgrade_preserves_legacy_data_and_retires_unbound_sessions(self):
        path = self.tmp.name + '/legacy.sqlite3'
        with database.connect(path) as db:
            db.executescript(Path('migrations/001_foundation.sql').read_text())
            db.execute("INSERT INTO users VALUES('teacher','teacher@legacy.local','Legacy teacher','teacher','salt','hash')")
            db.execute("INSERT INTO classrooms VALUES('room','Old class','Old school',1,'teacher')")
            db.execute("INSERT INTO devices(id,name,classroom_id) VALUES('legacy-device','Old board','room')")
            db.execute("INSERT INTO sessions VALUES('old-token','teacher',9999999999)")
            database.migrate(db)
            database.migrate(db)
            self.assertEqual(db.execute('SELECT COUNT(*) AS n FROM classrooms').fetchone()['n'], 1)
            self.assertEqual(db.execute('SELECT COUNT(*) AS n FROM classroom_assignments').fetchone()['n'], 1)
            self.assertEqual(db.execute('SELECT COUNT(*) AS n FROM sessions').fetchone()['n'], 0)
            self.assertEqual(db.execute('SELECT must_change_password FROM users').fetchone()['must_change_password'], 1)
            self.assertEqual(db.execute('SELECT MAX(version) AS v FROM schema_migrations').fetchone()['v'], 6)


if __name__ == '__main__':
    unittest.main()
