"""Real HTTP integration tests, run against SQLite or a disposable PostgreSQL schema."""
import http.cookiejar
import json
import os
import tempfile
import threading
import time
import unittest
import urllib.error
import urllib.parse
import urllib.request

import app

PASSWORD = 'test-only-initial-password-123'
CHANGED = 'test-only-changed-password-456'
ORIGIN = 'http://localhost:8080'


class Client:
    def __init__(self, base, installation=None):
        self.base = base
        self.installation = installation or 'browser-' + app.uid()
        self.jar = http.cookiejar.CookieJar()
        self.opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(self.jar))
        self.token = None

    def call(self, path, body=None, method=None, token=None):
        headers = {'Content-Type': 'application/json', 'Origin': ORIGIN,
                   'X-Installation-ID': self.installation}
        if token or self.token:
            headers['Authorization'] = 'Bearer ' + (token or self.token)
        request = urllib.request.Request(self.base + path,
            data=None if body is None else json.dumps(body).encode(),
            headers=headers, method=method or ('GET' if body is None else 'POST'))
        try:
            with self.opener.open(request, timeout=8) as response:
                return response.status, json.load(response)
        except urllib.error.HTTPError as error:
            with error:
                return error.code, json.load(error)

    def login(self, email, password=PASSWORD):
        code, value = self.call('/login', {'email': email, 'password': password,
                                         'installationId': self.installation})
        if code == 200:
            self.token = value['token']
        return code, value

    def stream(self):
        return self.opener.open(urllib.request.Request(self.base + '/events/stream',
            headers={'Authorization': 'Bearer ' + self.token, 'Origin': ORIGIN}), timeout=8)


def read_snapshot(stream, predicate=lambda value: True):
    deadline = time.time() + 7
    while time.time() < deadline:
        line = stream.readline().decode().strip()
        if line.startswith('data: '):
            value = json.loads(line[6:])
            if 'overview' in value and predicate(value):
                return value
    raise AssertionError('Live snapshot did not arrive automatically')


class CentralTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.schema = None
        base_db = os.environ.get('GANIT_TEST_DATABASE_URL', '')
        if base_db:
            import psycopg
            self.schema = 'ganit_test_' + app.uid()
            with psycopg.connect(base_db, autocommit=True) as c:
                c.execute('CREATE SCHEMA ' + self.schema)
            app.DATABASE_URL = base_db + ('&' if '?' in base_db else '?') + urllib.parse.urlencode({'options': '-csearch_path=' + self.schema})
        else:
            app.DATABASE_URL = ''
        app.DB = self.tmp.name + '/test.sqlite3'
        app.LEASE_KEY = None
        app.OFFLINE_AFTER = 10
        app.SSE_INTERVAL = .1
        app.init()
        self.super_id = app.create_user('admin@test.local', 'Administrator', 'super_admin', PASSWORD)
        self.teacher_id = app.create_user('teacher@test.local', 'Teacher A', 'teacher', PASSWORD)
        self.other_id = app.create_user('other@test.local', 'Teacher B', 'teacher', PASSWORD)
        self.school_admin_id = app.create_user('school@test.local', 'School Admin', 'school_admin', PASSWORD)
        self.viewer_id = app.create_user('viewer@test.local', 'Viewer', 'viewer', PASSWORD)
        self.server = app.ThreadingHTTPServer(('127.0.0.1', 0), app.Handler)
        self.server.daemon_threads = True
        self.thread = threading.Thread(target=lambda: self.server.serve_forever(poll_interval=.05), daemon=True)
        self.thread.start()
        self.base = 'http://127.0.0.1:' + str(self.server.server_port)
        self.admin = Client(self.base)
        self.assertEqual(self.admin.login('admin@test.local')[0], 200)
        self.sid = self.admin.call('/schools', {'name': 'School A', 'code': 'A', 'location': 'District'})[1]['id']
        self.other_sid = self.admin.call('/schools', {'name': 'School B', 'code': 'B'})[1]['id']
        self.cid = self.admin.call('/classrooms', {'name': 'Class A', 'school_id': self.sid, 'grade': 1, 'teacher_ids': [self.teacher_id]})[1]['id']
        self.other_cid = self.admin.call('/classrooms', {'name': 'Class B', 'school_id': self.other_sid, 'grade': 2, 'teacher_ids': [self.other_id]})[1]['id']
        with app.connection() as c:
            c.execute('INSERT INTO user_schools VALUES(?,?)', (self.school_admin_id, self.sid))
            c.execute('INSERT INTO user_schools VALUES(?,?)', (self.viewer_id, self.sid))
        self.teacher = Client(self.base)
        self.other = Client(self.base)
        self.school = Client(self.base)
        self.viewer = Client(self.base)
        for client, email in [(self.teacher, 'teacher@test.local'), (self.other, 'other@test.local'), (self.school, 'school@test.local'), (self.viewer, 'viewer@test.local')]:
            self.assertEqual(client.login(email)[0], 200)
        self.streams = []

    def tearDown(self):
        for stream in self.streams:
            stream.close()
        time.sleep(.3)
        self.server.shutdown()
        self.server.server_close()
        if self.schema:
            import psycopg
            with psycopg.connect(os.environ['GANIT_TEST_DATABASE_URL'], autocommit=True) as c:
                c.execute('DROP SCHEMA ' + self.schema + ' CASCADE')
        self.tmp.cleanup()

    def enroll(self, client=None, cid=None):
        client = client or self.teacher
        code, value = client.call('/devices/register', {'id': client.installation,
            'installationId': client.installation, 'classroom_id': cid or self.cid, 'name': 'Board'})
        self.assertIn(code, (200, 201), value)
        client.token = value['token']
        return value

    def beat(self, client=None, cid=None, **extra):
        client = client or self.teacher
        return client.call('/devices/' + client.installation + '/heartbeat', {
            'version': '1.2.0', 'mode': 'learn', 'grade': 1 if client is self.teacher else 2,
            'chapterId': 'G1-C10' if client is self.teacher else 'G2-C08',
            'classroomId': cid or (self.cid if client is self.teacher else self.other_cid),
            'lastInteractionAt': time.time(), 'networkState': 'online', 'health': 'ok',
            'errorCount': 0, 'activeSessions': 1, **extra})

    def event(self, client=None, action='started', mode='quiz', **extra):
        client = client or self.teacher
        return {'id': app.uid(), 'type': ('lesson' if mode == 'learn' else mode) + '_' + action,
            'sessionId': app.uid(), 'mode': mode, 'grade': 1,
            'chapterId': 'G1-C10', 'classroomId': self.cid,
            'occurredAt': time.time(), 'durationSeconds': 12 if action == 'completed' else 0, **extra}

    def test_auth_password_hash_logout_and_health(self):
        guest = Client(self.base)
        self.assertEqual(guest.call('/dashboard')[0], 401)
        self.assertEqual(guest.login('admin@test.local', 'wrong')[0], 401)
        self.assertEqual(guest.call('/health')[1]['schemaVersion'], 5)
        with app.connection() as c:
            user = c.execute('SELECT * FROM users WHERE id=?', (self.super_id,)).fetchone()
            self.assertNotEqual(user['password_hash'], PASSWORD)
            self.assertIsNone(c.execute('SELECT * FROM sessions WHERE token_hash=?', (self.admin.token,)).fetchone())
        self.assertEqual(self.admin.call('/logout', {})[0], 200)
        self.assertEqual(self.admin.call('/dashboard')[0], 401)

    def test_roles_and_school_isolation(self):
        self.assertEqual(self.teacher.call('/dashboard')[0], 403)
        self.assertEqual(self.teacher.call('/events/stream')[0], 403)
        self.assertEqual(self.teacher.call('/schools', {'name': 'No', 'code': 'N'})[0], 403)
        self.assertEqual(self.viewer.call('/classrooms', {'name': 'No', 'school_id': self.sid, 'grade': 1})[0], 403)
        school_dash = self.school.call('/dashboard')[1]
        self.assertEqual([s['id'] for s in school_dash['schools']], [self.sid])
        self.assertEqual([r['id'] for r in school_dash['classrooms']], [self.cid])
        self.assertEqual(self.school.call('/classrooms/' + self.other_cid, {'name': 'Attack'}, method='PATCH')[0], 403)
        self.assertEqual(self.school.call('/users/' + self.other_id, {'status': 'disabled'}, method='PATCH')[0], 403)
        self.assertEqual(self.viewer.call('/dashboard')[1]['users'], [])
        self.assertEqual([r['id'] for r in self.teacher.call('/me/classrooms')[1]['classrooms']], [self.cid])

    def test_account_creation_first_password_change_and_assignments(self):
        code, user = self.school.call('/users', {'name': 'New teacher', 'email': 'new@test.local', 'password': PASSWORD,
            'role': 'teacher', 'school_ids': [self.sid], 'classroom_ids': [self.cid]})
        self.assertEqual(code, 201, user)
        self.assertNotIn('password', user)
        newcomer = Client(self.base)
        code, login = newcomer.login('new@test.local')
        self.assertEqual(login['user']['must_change_password'], 1)
        self.assertEqual(newcomer.call('/devices/register', {'id': newcomer.installation, 'name': 'New board', 'classroom_id': self.cid})[1]['code'], 'password_change_required')
        code, changed = newcomer.call('/auth/change-password', {'currentPassword': PASSWORD, 'newPassword': CHANGED})
        self.assertEqual(code, 200, changed)
        newcomer.token = changed['token']
        self.assertEqual(changed['user']['must_change_password'], 0)
        self.enroll(newcomer)
        self.assertEqual(self.school.call('/users', {'name': 'Bad', 'email': 'bad@test.local', 'password': PASSWORD,
            'role': 'super_admin', 'school_ids': [self.sid]})[0], 403)
        self.assertEqual(self.school.call('/users', {'name': 'Bad', 'email': 'bad@test.local', 'password': PASSWORD,
            'role': 'teacher', 'school_ids': [self.other_sid]})[0], 403)

    def test_registration_identity_duplicate_and_unknown_device(self):
        self.assertEqual(self.other.call('/devices/register', {'id': self.other.installation, 'name': 'Bad', 'classroom_id': self.cid})[0], 403)
        value = self.enroll()
        self.assertIn('offlineLease', value)
        from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PublicKey
        payload, signature = value['offlineLease'].split('.')
        Ed25519PublicKey.from_public_bytes(app.unb64(value['leasePublicKey'])).verify(app.unb64(signature), payload.encode())
        self.assertEqual(json.loads(app.unb64(payload))['role'], 'teacher')
        self.assertEqual(self.enroll()['id'], self.teacher.installation)
        self.assertEqual(self.beat()[0], 200)
        outsider = Client(self.base, self.teacher.installation)
        self.assertEqual(outsider.login('teacher@test.local')[0], 403)
        self.assertEqual(outsider.call('/devices/register', {'id': outsider.installation, 'name': 'Forged', 'classroom_id': self.cid})[0], 401)
        self.assertEqual(self.teacher.call('/devices/unknown-device-identity/heartbeat', {'classroomId': self.cid})[0], 404)
        with app.connection() as c:
            self.assertEqual(c.execute('SELECT COUNT(*) AS n FROM devices').fetchone()['n'], 1)

    def test_heartbeat_fields_status_and_multiple_live_sse_sessions(self):
        self.enroll()
        self.enroll(self.other, self.other_cid)
        stream_a = self.admin.stream()
        stream_b = self.school.stream()
        self.streams += [stream_a, stream_b]
        self.assertEqual(read_snapshot(stream_a)['overview']['devices'], 2)
        self.assertEqual(read_snapshot(stream_b)['overview']['devices'], 1)
        self.assertEqual(self.beat()[0], 200)
        self.assertEqual(self.beat(self.other)[0], 200)
        online_a = read_snapshot(stream_a, lambda d: d['overview']['onlineClassrooms'] == 2)
        online_b = read_snapshot(stream_b, lambda d: d['overview']['onlineClassrooms'] == 1)
        self.assertEqual(online_a['overview']['activeLessons'], 2)
        self.assertEqual(online_b['devices'][0]['chapter_id'], 'G1-C10')
        # Simulate elapsed heartbeat expiry in the database; no dashboard GET/refresh.
        with app.connection() as c:
            c.execute('UPDATE devices SET last_seen=?', (time.time() - 20,))
        offline_a = read_snapshot(stream_a, lambda d: d['overview']['onlineClassrooms'] == 0)
        self.assertEqual(offline_a['overview']['offlineClassrooms'], 2)
        self.assertEqual(self.beat()[0], 200)
        read_snapshot(stream_b, lambda d: d['overview']['onlineClassrooms'] == 1)

    def test_offline_event_replay_is_idempotent_and_aggregate_only(self):
        self.enroll()
        started = self.event()
        completed = self.event(action='completed', sessionId=started['sessionId'], occurredAt=time.time() - 120)
        batch = {'events': [started, completed]}
        for _ in range(2):
            code, value = self.teacher.call('/devices/' + self.teacher.installation + '/events', batch)
            self.assertEqual(code, 200, value)
            self.assertEqual(len(value['acknowledged']), 2)
        duplicate_complete = {**completed, 'id': app.uid()}
        self.teacher.call('/devices/' + self.teacher.installation + '/events', {'events': [duplicate_complete]})
        dash = self.admin.call('/dashboard')[1]
        self.assertEqual(dash['analytics']['quizSessions'], 1)
        self.assertEqual(dash['analytics']['averageSessionDuration'], 12)
        with app.connection() as c:
            self.assertEqual(c.execute('SELECT COUNT(*) AS n FROM activity_events').fetchone()['n'], 2)
            columns = set(dict(c.execute('SELECT * FROM activity_events LIMIT 1').fetchone()))
            self.assertFalse(columns & {'student_name', 'answers', 'score', 'mistakes', 'profile'})

    def test_privacy_allowlist_rejects_answers_names_and_raw_errors(self):
        self.enroll()
        self.assertEqual(self.beat(studentName='Do not store')[0], 400)
        bad = self.event(answers=[1, 2], studentName='Do not store')
        self.assertEqual(self.teacher.call('/devices/' + self.teacher.installation + '/events', {'events': [bad]})[0], 400)
        raw = self.event(type='app_error', errorCode='A private raw error message')
        self.assertEqual(self.teacher.call('/devices/' + self.teacher.installation + '/events', {'events': [raw]})[0], 400)
        with app.connection() as c:
            self.assertEqual(c.execute('SELECT COUNT(*) AS n FROM activity_events').fetchone()['n'], 0)

    def test_revocation_forced_logout_disable_teacher_and_classroom(self):
        self.enroll()
        self.assertEqual(self.beat()[0], 200)
        self.admin.call('/devices/' + self.teacher.installation, {'require_reauth': True}, method='PATCH')
        self.assertEqual(self.beat()[0], 401)
        self.assertEqual(self.teacher.call('/auth/refresh', {'installationId': self.teacher.installation})[0], 401)
        self.assertEqual(self.teacher.login('teacher@test.local')[0], 200)
        self.assertEqual(self.beat()[0], 200)
        self.admin.call('/devices/' + self.teacher.installation, {'revoked': True}, method='PATCH')
        self.assertIn(self.beat()[0], (401, 403))
        self.assertEqual(self.teacher.login('teacher@test.local')[0], 403)
        self.admin.call('/users/' + self.teacher_id, {'status': 'disabled'}, method='PATCH')
        self.assertEqual(self.teacher.login('teacher@test.local')[0], 401)
        self.admin.call('/classrooms/' + self.other_cid, {'status': 'disabled'}, method='PATCH')
        self.assertEqual(self.other.call('/devices/register', {'id': self.other.installation, 'name': 'Blocked', 'classroom_id': self.other_cid})[0], 403)

    def test_refresh_rotation_cookie_flags_reuse_and_expiry(self):
        self.enroll()
        old = next(cookie.value for cookie in self.teacher.jar if cookie.name.startswith('gs_refresh'))
        code, refreshed = self.teacher.call('/auth/refresh', {'installationId': self.teacher.installation})
        self.assertEqual(code, 200, refreshed)
        self.assertNotIn('refreshToken', refreshed)
        self.teacher.token = refreshed['token']
        new = next(cookie.value for cookie in self.teacher.jar if cookie.name.startswith('gs_refresh'))
        self.assertNotEqual(old, new)
        request = urllib.request.Request(self.base + '/auth/refresh', data=json.dumps({'installationId': self.teacher.installation}).encode(), headers={'Origin': ORIGIN, 'Content-Type': 'application/json', 'Cookie': app.cookie_name('gs_refresh', self.teacher.installation) + '=' + old})
        with self.assertRaises(urllib.error.HTTPError) as error:
            urllib.request.urlopen(request)
        self.assertEqual(error.exception.code, 401)
        error.exception.close()
        self.assertEqual(self.teacher.call('/me')[0], 401)
        with app.connection() as c:
            self.assertTrue(c.execute("SELECT id FROM alerts WHERE code='suspicious_session'").fetchone())
            c.execute('UPDATE sessions SET expires=1 WHERE token_hash=?', (app.digest(self.admin.token),))
        self.assertEqual(self.admin.call('/dashboard')[1]['code'], 'session_expired')
        self.assertIn('HttpOnly', app.cookie('example', 'proof', 10))
        self.assertNotIn('proof', json.dumps(refreshed))

    def test_password_reset_single_use_and_revoked_sessions(self):
        self.assertEqual(self.teacher.call('/users/' + self.teacher_id + '/password-reset', {})[0], 403)
        code, value = self.school.call('/users/' + self.teacher_id + '/password-reset', {})
        self.assertEqual(code, 201)
        reset = value['resetToken']
        guest = Client(self.base)
        self.assertEqual(guest.call('/auth/reset-password', {'resetToken': reset, 'newPassword': CHANGED})[0], 200)
        self.assertEqual(guest.call('/auth/reset-password', {'resetToken': reset, 'newPassword': CHANGED})[0], 400)
        self.assertEqual(self.teacher.call('/me')[0], 401)
        self.assertEqual(guest.login('teacher@test.local', PASSWORD)[0], 401)
        self.assertEqual(guest.login('teacher@test.local', CHANGED)[0], 200)
        with app.connection() as c:
            self.assertIsNone(c.execute('SELECT * FROM password_reset_tokens WHERE token_hash=?', (reset,)).fetchone())

    def test_versions_health_alert_configuration_and_resolution(self):
        self.enroll()
        self.assertEqual(self.school.call('/versions', {'version': '2.0.0', 'approved': True})[0], 403)
        self.assertEqual(self.admin.call('/versions', {'version': '1.3.0', 'approved': True, 'supported': True})[0], 200)
        self.assertEqual(self.beat()[0], 200)
        self.assertEqual(self.school.call('/alert-rules/' + self.sid, {'offline_seconds': 12, 'error_threshold': 2, 'login_threshold': 3}, method='PATCH')[0], 200)
        self.assertEqual(self.school.call('/alert-rules/' + self.other_sid, {'offline_seconds': 12}, method='PATCH')[0], 403)
        self.beat(health='degraded')
        dash = self.admin.call('/dashboard')[1]
        self.assertEqual(dash['overview']['outdatedDevices'], 1)
        self.assertTrue(any(a['code'] == 'unhealthy_heartbeat' for a in dash['alerts']))
        alert_id = dash['alerts'][0]['id']
        self.assertEqual(self.viewer.call('/alerts/' + alert_id, {'status': 'resolved'}, method='PATCH')[0], 403)
        self.assertEqual(self.school.call('/alerts/' + alert_id, {'status': 'resolved'}, method='PATCH')[0], 200)
        self.admin.call('/versions', {'version': '1.2.0', 'approved': False, 'supported': False})
        self.assertEqual(self.beat()[0], 426)

    def test_throttling_audit_invalid_origin_and_unknown_routes(self):
        stranger = Client(self.base)
        for _ in range(10):
            self.assertEqual(stranger.login('teacher@test.local', 'incorrect')[0], 401)
        self.assertEqual(stranger.login('teacher@test.local', 'incorrect')[0], 429)
        self.assertTrue(any(log['action'] == 'login_failed' for log in self.admin.call('/dashboard')[1]['audit']))
        request = urllib.request.Request(self.base + '/health', headers={'Origin': 'https://untrusted.example'})
        with self.assertRaises(urllib.error.HTTPError) as error:
            urllib.request.urlopen(request)
        self.assertEqual(error.exception.code, 403)
        error.exception.close()
        self.assertEqual(self.admin.call('/missing')[0], 404)
        self.assertEqual(self.admin.call('/classrooms', {'name': '', 'school_id': self.sid, 'grade': 9})[0], 400)
        self.assertEqual(self.admin.call('/schools', {'name': 'duplicate', 'code': 'A'})[0], 409)

    def test_multiple_teachers_and_no_cross_school_reassignment(self):
        self.assertEqual(self.admin.call('/classrooms/' + self.cid, {'teacher_ids': [self.teacher_id, self.other_id]}, method='PATCH')[0], 200)
        self.assertEqual(len(self.admin.call('/dashboard')[1]['classrooms'][0]['teacher_ids']), 2)
        self.assertEqual(self.school.call('/users/' + self.other_id, {'status': 'disabled'}, method='PATCH')[0], 403)
        self.enroll()
        self.assertEqual(self.school.call('/devices/' + self.teacher.installation, {'classroom_id': self.other_cid}, method='PATCH')[0], 403)
        self.assertEqual(self.admin.call('/devices/' + self.teacher.installation, {'classroom_id': self.other_cid}, method='PATCH')[0], 200)
        self.assertEqual(self.beat()[0], 401)

    def test_reassigned_device_history_and_shared_staff_are_school_scoped(self):
        self.enroll()
        event = self.event()
        self.assertEqual(self.teacher.call('/devices/' + self.teacher.installation + '/events', {'events': [event]})[0], 200)
        with app.connection() as c:
            c.execute('INSERT INTO error_events VALUES(?,?,?,?,?)', (app.uid(), self.teacher.installation, self.cid, 'render_error', time.time()))
            c.execute('INSERT INTO user_schools VALUES(?,?)', (self.teacher_id, self.other_sid))
        staff = next(u for u in self.school.call('/dashboard')[1]['users'] if u['id'] == self.teacher_id)
        self.assertEqual(staff['school_ids'], [self.sid])
        self.assertNotIn(self.super_id, [u['id'] for u in self.school.call('/dashboard')[1]['users']])
        self.assertEqual(self.admin.call('/devices/' + self.teacher.installation, {'classroom_id': self.other_cid}, method='PATCH')[0], 200)
        with app.connection() as c:
            c.execute('DELETE FROM user_schools WHERE user_id=?', (self.viewer_id,))
            c.execute('INSERT INTO user_schools VALUES(?,?)', (self.viewer_id, self.other_sid))
        self.assertEqual(self.viewer.call('/devices/' + self.teacher.installation + '/activity')[1]['events'], [])
        self.assertEqual(self.viewer.call('/devices/' + self.teacher.installation + '/errors')[1]['errors'], [])
        self.assertEqual(len(self.admin.call('/devices/' + self.teacher.installation + '/activity')[1]['events']), 1)

    def test_required_entities_and_versioned_migrations(self):
        expected = {'users','roles','schools','classrooms','teachers','devices','device_sessions','classroom_assignments','heartbeats','activity_events','usage_daily','app_versions','error_events','audit_logs','password_reset_tokens','refresh_tokens'}
        with app.connection() as c:
            if app.DATABASE_URL:
                names = {r['table_name'] for r in c.execute('SELECT table_name FROM information_schema.tables WHERE table_schema=current_schema()')}
            else:
                names = {r['name'] for r in c.execute("SELECT name FROM sqlite_master WHERE type='table'")}
            self.assertTrue(expected <= names)
            self.assertEqual([r['version'] for r in c.execute('SELECT version FROM schema_migrations ORDER BY version')], [1,2,3,4,5])
        app.init()  # migration re-entry is idempotent


if __name__ == '__main__':
    unittest.main()
