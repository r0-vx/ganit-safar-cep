"""Ganit Safar management API. Run via WSGI/TLS in production; loopback in dev."""
import argparse
from contextvars import ContextVar
from contextlib import contextmanager
import base64
import hashlib
import hmac
import ipaddress
import json
import os
import re
import secrets
import threading
import time
from collections import Counter, defaultdict
from datetime import datetime, timezone
from http.cookies import SimpleCookie
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlsplit

import database

DB = os.environ.get('GANIT_DB', str(Path(__file__).with_name('development.sqlite3')))
DATABASE_URL = os.environ.get('DATABASE_URL', '')
ENV = os.environ.get('GANIT_ENV', 'development')
ORIGIN = os.environ.get('GANIT_ALLOWED_ORIGIN', 'http://localhost:8080')
ACCESS_TTL = int(os.environ.get('GANIT_ACCESS_TTL', '900'))
TTL = ACCESS_TTL
REFRESH_TTL = int(os.environ.get('GANIT_REFRESH_TTL', str(30 * 86400)))
OFFLINE_TTL = int(os.environ.get('GANIT_OFFLINE_TTL', str(7 * 86400)))
OFFLINE_AFTER = int(os.environ.get('GANIT_OFFLINE_AFTER', '90'))
SSE_INTERVAL = float(os.environ.get('GANIT_SSE_INTERVAL', '2'))
ROLES = {'super_admin', 'school_admin', 'teacher', 'viewer'}
ADMINS = {'super_admin', 'school_admin'}
MODES = {'idle', 'learn', 'practice', 'quiz'}
ERROR_CODES = {'render_error', 'unhandled_error', 'sync_failed', 'queue_overflow', 'storage_error'}
EVENT_TYPES = {f'{name}_{action}' for name in ('lesson', 'practice', 'quiz') for action in ('started', 'completed', 'left')} | {'app_error'}
LEASE_KEY = None


_presentation = ContextVar('presentation_dataset', default=False)


def is_presentation():
    return _presentation.get()


@contextmanager
def dataset(presentation=False):
    if presentation and os.environ.get('GANIT_PRESENTATION_ENABLED') != '1':
        reject(404, 'not_found', 'Presentation environment is not enabled')
    token = _presentation.set(presentation)
    try:
        yield
    finally:
        _presentation.reset(token)


def connection():
    presentation = is_presentation()
    schema = os.environ.get('GANIT_PRESENTATION_SCHEMA', 'ganit_presentation') if presentation else os.environ.get('GANIT_DB_SCHEMA', '')
    path = DB + '.presentation' if presentation else DB
    return database.connect(path, DATABASE_URL, schema if DATABASE_URL else '')


def digest(value):
    return hashlib.sha256(value.encode()).hexdigest()


def password_hash(password, salt):
    return hashlib.scrypt(password.encode(), salt=bytes.fromhex(salt), n=16384, r=8, p=1).hex()


def uid():
    return secrets.token_hex(16)


def b64(value):
    return base64.urlsafe_b64encode(value).decode().rstrip('=')


def unb64(value):
    return base64.urlsafe_b64decode(value + '=' * (-len(value) % 4))


def signing_key():
    global LEASE_KEY
    if LEASE_KEY is not None:
        return LEASE_KEY
    from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey
    value = os.environ.get('GANIT_LEASE_SIGNING_KEY', '')
    if value:
        LEASE_KEY = Ed25519PrivateKey.from_private_bytes(unb64(value))
    else:
        if ENV == 'production':
            raise ValueError('GANIT_LEASE_SIGNING_KEY is required')
        path = Path(os.environ.get('GANIT_LEASE_KEY_FILE', DB + '.offline.key'))
        path.parent.mkdir(parents=True, exist_ok=True)
        # Publish a completely written file atomically: multiple development
        # workers must never observe the zero-byte file between create/write.
        temporary = path.with_name(path.name + '.' + uid() + '.tmp')
        try:
            fd = os.open(temporary, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
            with os.fdopen(fd, 'wb') as stream:
                stream.write(secrets.token_bytes(32))
                stream.flush()
                os.fsync(stream.fileno())
            try:
                os.link(temporary, path)
            except FileExistsError:
                pass
        finally:
            temporary.unlink(missing_ok=True)
        LEASE_KEY = Ed25519PrivateKey.from_private_bytes(path.read_bytes())
    return LEASE_KEY


def public_key():
    from cryptography.hazmat.primitives import serialization
    return b64(signing_key().public_key().public_bytes(serialization.Encoding.Raw, serialization.PublicFormat.Raw))


def init():
    if ENV == 'production':
        origins = allowed_origins()
        if not DATABASE_URL.startswith(('postgresql://', 'postgres://')) or not re.search(r'[?&]sslmode=(require|verify-ca|verify-full)(?:&|$)', DATABASE_URL):
            raise ValueError('Production requires PostgreSQL with explicit TLS sslmode')
        if not origins:
            raise ValueError('At least one approved HTTPS origin is required')
        if not os.environ.get('GANIT_TRUSTED_PROXY_CIDRS', ''):
            raise ValueError('Configure the trusted HTTPS proxy CIDRs')
        for value in os.environ['GANIT_TRUSTED_PROXY_CIDRS'].split(','):
            ipaddress.ip_network(value.strip())
        if any(not origin.startswith('https://') for origin in origins):
            raise ValueError('Production origins must use HTTPS')
        if not os.environ.get('GANIT_PUBLIC_URL', '').startswith('https://'):
            raise ValueError('GANIT_PUBLIC_URL must be HTTPS')
    if DATABASE_URL:
        import psycopg
        from psycopg import sql
        schemas = [os.environ.get('GANIT_DB_SCHEMA', '')]
        if os.environ.get('GANIT_PRESENTATION_ENABLED') == '1':
            demo_schema = os.environ.get('GANIT_PRESENTATION_SCHEMA', 'ganit_presentation')
            if demo_schema == (schemas[0] or 'public'):
                raise ValueError('Live and presentation schemas must differ')
            schemas.append(demo_schema)
        with psycopg.connect(database.postgres_url(DATABASE_URL)) as raw:
            for schema in schemas:
                if schema:
                    if not re.fullmatch(r'[a-z][a-z0-9_]{0,62}', schema):
                        raise ValueError('Invalid database schema')
                    raw.execute(sql.SQL('CREATE SCHEMA IF NOT EXISTS {}').format(sql.Identifier(schema)))
    with connection() as c:
        database.migrate(c)
    if os.environ.get('GANIT_PRESENTATION_ENABLED') == '1':
        with dataset(True), connection() as c:
            database.migrate(c)
    signing_key()


def allowed_origins():
    return {value.strip() for value in os.environ.get('GANIT_ALLOWED_ORIGINS', ORIGIN).split(',') if value.strip()}


def audit(c, actor, action, target='', school_id=None):
    c.execute('INSERT INTO audit_logs VALUES(?,?,?,?,?,?)', (uid(), time.time(), actor, action, target, school_id))
    c.execute('UPDATE system_state SET revision=revision+1 WHERE id=1')


def create_user(email, name, role, password):
    role = 'super_admin' if role == 'admin' else role
    if role not in ROLES or len(password) < 12:
        raise ValueError('Use a supported role and a password of at least 12 characters')
    user_id, salt = uid(), secrets.token_hex(16)
    with connection() as c:
        c.execute('INSERT INTO users(id,email,name,role,salt,password_hash,created_at) VALUES(?,?,?,?,?,?,?)', (user_id, email.lower().strip(), name, role, salt, password_hash(password, salt), time.time()))
        if role == 'teacher':
            c.execute('INSERT INTO teachers VALUES(?,?)', (user_id, time.time()))
        audit(c, 'setup', 'user_created', user_id)
    return user_id


class APIError(Exception):
    def __init__(self, status, code, message):
        self.status, self.code, self.message = status, code, message


def reject(status, code, message):
    raise APIError(status, code, message)


def required(body, key, limit=160):
    value = body.get(key)
    if not isinstance(value, str) or not value.strip() or len(value) > limit:
        reject(400, 'invalid_request', f'Check {key}')
    return value.strip()


def secret(body, key):
    value = body.get(key)
    if not isinstance(value, str) or not value or len(value) > 1024:
        reject(400, 'invalid_request', f'Check {key}')
    return value


def number(body, key, default=0, maximum=1000000):
    value = body.get(key, default)
    if isinstance(value, bool) or not isinstance(value, (float, int)) or not 0 <= value <= maximum:
        reject(400, 'invalid_request', f'Check {key}')
    return value


def public_user(user):
    return {key: user[key] for key in ('id', 'name', 'email', 'role', 'status', 'last_login', 'must_change_password')}


def school_scope(c, user):
    if user['role'] == 'super_admin':
        return {r['id'] for r in c.execute('SELECT id FROM schools')}
    return {r['school_id'] for r in c.execute('SELECT school_id FROM user_schools WHERE user_id=?', (user['id'],))}


def schools_for(c, user):
    scopes = school_scope(c, user)
    return [dict(r) for r in c.execute('SELECT id,name,status FROM schools ORDER BY name') if r['id'] in scopes]


def create_school_login(c, actor, school):
    # The unique mapping makes this a single school account, never one account
    # per classroom. The password is returned once and only a salted hash stays.
    if c.execute('SELECT user_id FROM school_logins WHERE school_id=?', (school['id'],)).fetchone():
        reject(409, 'school_login_exists', 'This school already has a login')
    user_id, salt = uid(), secrets.token_hex(16)
    username = 'school-' + uid()[:12]
    password = secrets.token_urlsafe(15)
    c.execute('INSERT INTO users(id,email,name,role,salt,password_hash,created_at) VALUES(?,?,?,?,?,?,?)',
              (user_id, username, school['name'], 'school_admin', salt, password_hash(password, salt), time.time()))
    c.execute('INSERT INTO user_schools VALUES(?,?)', (user_id, school['id']))
    c.execute('INSERT INTO school_logins VALUES(?,?,?)', (school['id'], user_id, time.time()))
    audit(c, actor['id'], 'school_login_created', user_id, school['id'])
    return {'username': username, 'password': password, 'schoolName': school['name']}


def rooms_for(c, user, active_only=False):
    rows = list(c.execute('SELECT c.*,s.name AS school_name,s.status AS school_status FROM classrooms c JOIN schools s ON s.id=c.school_id ORDER BY c.name'))
    if user['role'] == 'teacher':
        assigned = {r['classroom_id'] for r in c.execute('SELECT classroom_id FROM classroom_assignments WHERE user_id=?', (user['id'],))}
        scopes = school_scope(c, user)
        rows = [r for r in rows if r['id'] in assigned and r['school_id'] in scopes]
    else:
        schools = school_scope(c, user)
        rows = [r for r in rows if r['school_id'] in schools]
    if active_only:
        rows = [r for r in rows if r['status'] == 'active' and r['school_status'] == 'active']
    return [dict(r) for r in rows]


def require_admin(user, super_only=False):
    if user['role'] not in ({'super_admin'} if super_only else ADMINS):
        reject(403, 'forbidden', 'Administrator permission required')


def room_access(c, user, room_id, active=False):
    room = next((r for r in rooms_for(c, user, active) if r['id'] == room_id), None)
    if room is None:
        reject(403, 'unassigned_classroom', 'Classroom is unavailable or not assigned')
    return room


def user_access(c, actor, target_id):
    target = c.execute('SELECT * FROM users WHERE id=?', (target_id,)).fetchone()
    if target is None:
        reject(404, 'not_found', 'Unknown user')
    require_admin(actor)
    if actor['role'] != 'super_admin':
        target_schools = school_scope(c, target)
        if target['role'] != 'teacher' or not target_schools or not target_schools <= school_scope(c, actor):
            reject(403, 'forbidden', 'User is outside your school scope')
    return target


def invalidate_user(c, user_id):
    c.execute('DELETE FROM sessions WHERE user_id=?', (user_id,))
    c.execute('UPDATE refresh_tokens SET revoked=1 WHERE user_id=?', (user_id,))


def invalidate_device(c, device_id):
    c.execute('DELETE FROM sessions WHERE device_id=?', (device_id,))
    c.execute('UPDATE refresh_tokens SET revoked=1 WHERE device_id=?', (device_id,))
    c.execute("UPDATE devices SET reauth_required=1,connection_state='locked' WHERE id=?", (device_id,))


def cookie_name(prefix, installation):
    return ('demo_' if is_presentation() else '') + prefix + '_' + digest(installation)[:20]


def cookie_value(headers, name):
    jar = SimpleCookie()
    try:
        jar.load(headers.get('Cookie', ''))
        return jar[name].value if name in jar else ''
    except Exception:
        return ''


def cookie(name, value, ttl):
    secure = '; Secure' if ENV == 'production' else ''
    same_site = os.environ.get('GANIT_COOKIE_SAMESITE', 'Lax')
    if same_site not in ('Lax', 'Strict', 'None'):
        raise ValueError('Invalid cookie SameSite policy')
    return f'{name}={value}; Path=/; Max-Age={ttl}; HttpOnly; SameSite={same_site}{secure}'


def device_proof(c, headers, device_id):
    proof = cookie_value(headers, cookie_name('gs_device', device_id))
    return bool(proof and c.execute('SELECT token_hash FROM device_sessions WHERE token_hash=? AND device_id=? AND revoked=0 AND expires>?', (digest(proof), device_id, time.time())).fetchone())


def version_info(c, version, rows=None):
    if rows is None:
        rows = [dict(r) for r in c.execute('SELECT * FROM app_versions')]
    def sort_key(value):
        return tuple(int(part) for part in value.split('-')[0].split('+')[0].split('.'))
    approved = [r['version'] for r in rows if r['approved'] and r['supported']]
    latest = max(approved, key=sort_key) if approved else None
    match = next((r for r in rows if r['version'] == version), None)
    return {'latest': latest, 'unsupported': bool(match and not match['supported']), 'outdated': bool((match and not match['approved']) or (latest and (not valid_version(version) or sort_key(version) < sort_key(latest))))}


def status(device, c=None):
    device = dict(device)
    if device['revoked']:
        return 'needs_attention'
    if not device['active']:
        return 'disabled'
    if device['health'] != 'ok' or device.get('reauth_required', 0):
        return 'needs_attention'
    if c and version_info(c, device['version'])['outdated']:
        return 'needs_attention'
    if device.get('connection_state') == 'signed_out':
        return 'offline'
    if not device['last_seen']:
        return 'never_connected'
    return 'online' if time.time() - device['last_seen'] < OFFLINE_AFTER else 'offline'


def alert(c, code, key, school=None, classroom=None, device=None, severity='warning'):
    return c.execute('INSERT INTO alerts(id,alert_key,severity,school_id,classroom_id,device_id,at,code) VALUES(?,?,?,?,?,?,?,?) ON CONFLICT DO NOTHING', (uid(), key, severity, school, classroom, device, time.time(), code)).rowcount == 1


def rate_limit(c, identity, user=None, maximum=10):
    identity = digest(identity)
    now = time.time()
    if c.postgres:
        c.execute('SELECT pg_advisory_xact_lock(?)', (int(identity[:15], 16),))
    else:
        c.execute('INSERT INTO login_attempts VALUES(?,?,0) ON CONFLICT DO NOTHING', (identity, now))
    c.execute('DELETE FROM login_attempts WHERE identity=? AND started_at<?', (identity, now - 300))
    row = c.execute('SELECT * FROM login_attempts WHERE identity=?', (identity,)).fetchone()
    if row and row['count'] >= maximum:
        reject(429, 'rate_limited', 'Wait five minutes before trying again')
    return identity, int(row['count']) if row else 0


def login_failed(c, identity, count, user):
    c.execute('INSERT INTO login_attempts VALUES(?,?,?) ON CONFLICT(identity) DO UPDATE SET count=login_attempts.count+1', (identity, time.time(), count + 1))
    scopes = school_scope(c, user) if user else {None}
    for sid in scopes or {None}:
        rule = c.execute('SELECT login_threshold FROM alert_rules WHERE school_id=?', (sid,)).fetchone() if sid else None
        if count + 1 >= (rule['login_threshold'] if rule else 5):
            alert(c, 'repeated_login_failures', f'login:{identity}:{int(time.time() // 300)}:{sid}', school=sid)
    audit(c, user['id'] if user else 'unknown', 'login_failed')
    c.commit()


def check_device(c, user, device_id, headers, legacy_secret=None):
    row = c.execute('SELECT * FROM devices WHERE id=?', (device_id,)).fetchone()
    if row is None:
        alert(c, 'unknown_device', f'unknown:{device_id}:{int(time.time() // 3600)}')
        c.commit()
        reject(404, 'unknown_device', 'Register this installation first')
    device = dict(row)
    room = room_access(c, user, device['classroom_id'], active=True)
    legacy = ENV != 'production' and legacy_secret and hmac.compare_digest(device['secret_hash'], digest(legacy_secret))
    if not device_proof(c, headers, device_id) and not legacy:
        alert(c, 'unknown_device', f'proof:{device_id}:{int(time.time() // 3600)}', room['school_id'], room['id'], device_id)
        c.commit()
        reject(403, 'device_identity_rejected', 'Device identity proof is invalid')
    if device['revoked'] or not device['active']:
        reject(403, 'device_revoked' if device['revoked'] else 'device_disabled', 'Device is unavailable')
    return device, room


def classroom_user(user):
    return user['role'] == 'teacher' or (os.environ.get('GANIT_APP_SURFACE') == 'classroom' and user['role'] in ADMINS)


def issue_session(c, user, installation, headers, device_id=None, family=None):
    surface = os.environ.get('GANIT_APP_SURFACE', 'auto')
    if (surface == 'dashboard' and user['role'] == 'teacher') or (surface == 'classroom' and not classroom_user(user)):
        reject(403, 'wrong_portal', 'Use the correct sign-in page for this account')
    school_login = c.execute('SELECT s.status FROM school_logins l JOIN schools s ON s.id=l.school_id WHERE l.user_id=?', (user['id'],)).fetchone()
    if school_login and school_login['status'] != 'active':
        reject(403, 'school_disabled', 'This school is disabled')
    now, access, refresh = time.time(), secrets.token_urlsafe(40), secrets.token_urlsafe(48)
    family = family or uid()
    c.execute('INSERT INTO sessions(token_hash,user_id,expires,device_id,install_id,family_id,created_at) VALUES(?,?,?,?,?,?,?)', (digest(access), user['id'], now + ACCESS_TTL, device_id, installation, family, now))
    c.execute('INSERT INTO refresh_tokens(token_hash,user_id,install_id,device_id,family_id,expires,created_at) VALUES(?,?,?,?,?,?,?)', (digest(refresh), user['id'], installation, device_id, family, now + REFRESH_TTL, now))
    body = {'token': access, 'expiresAt': now + ACCESS_TTL, 'user': public_user(user), 'classrooms': rooms_for(c, user, True), 'schools': schools_for(c, user), 'leasePublicKey': public_key(), 'serverTime': now}
    if device_id and classroom_user(user) and not user['must_change_password']:
        device, room = check_device(c, user, device_id, headers)
        payload = {'deviceId': device_id, 'userId': user['id'], 'role': 'teacher', 'teacherName': user['name'], 'classroomId': room['id'], 'classroomName': room['name'], 'schoolName': room['school_name'], 'grade': room['grade'], 'issuedAt': now, 'expiresAt': now + OFFLINE_TTL, 'permissions': ['learn', 'practice', 'quiz', 'local_teacher']}
        encoded = b64(json.dumps(payload, separators=(',', ':'), sort_keys=True).encode())
        body['offlineLease'] = encoded + '.' + b64(signing_key().sign(encoded.encode()))
        body['device'] = {'id': device_id, 'name': device['name'], 'classroomId': room['id'], 'classroomName': room['name'], 'schoolName': room['school_name'], 'grade': room['grade']}
        c.execute('UPDATE devices SET last_login=?,teacher_id=?,reauth_required=0 WHERE id=?', (now, user['id'], device_id))
    cookies = [cookie(cookie_name('gs_refresh', installation), refresh, REFRESH_TTL)]
    if device_id:
        proof = cookie_value(headers, cookie_name('gs_device', device_id))
        if proof:
            c.execute('UPDATE device_sessions SET expires=? WHERE token_hash=? AND device_id=? AND revoked=0', (now + REFRESH_TTL, digest(proof), device_id))
            cookies.append(cookie(cookie_name('gs_device', device_id), proof, REFRESH_TTL))
    return body, cookies


def authenticate(c, headers):
    token = headers.get('Authorization', '').removeprefix('Bearer ')
    session = c.execute('SELECT * FROM sessions WHERE token_hash=?', (digest(token),)).fetchone() if token else None
    if not session:
        reject(401, 'reauth_required', 'Sign in again')
    if session['expires'] <= time.time():
        c.execute('DELETE FROM sessions WHERE token_hash=?', (digest(token),))
        audit(c, session['user_id'], 'session_expired', session['device_id'] or session['install_id'])
        c.commit()
        reject(401, 'session_expired', 'Session expired')
    user = c.execute('SELECT * FROM users WHERE id=?', (session['user_id'],)).fetchone()
    if not user or user['status'] != 'active':
        reject(401, 'account_disabled', 'Account is unavailable')
    return dict(user), dict(session)


def valid_version(value):
    return isinstance(value, str) and bool(re.fullmatch(r'\d+\.\d+\.\d+(?:[-+][A-Za-z0-9.-]+)?', value))


def chapter_id(value, grade):
    if value == '' or value in {'count','place','add','subtract','multiply','divide','fraction','shape','measure','time','money','pattern','data','word'}:
        return value
    match = re.fullmatch(r'G([1-4])-C(\d{2})', value) if isinstance(value, str) else None
    if not match or int(match[1]) != grade or not 1 <= int(match[2]) <= {1:29,2:22,3:14,4:14}[grade]:
        reject(400, 'private_payload_rejected', 'Use an approved chapter identifier, not free text')
    return value


def manage_assignments(c, actor, teacher_id, classroom_ids):
    if not isinstance(classroom_ids, list) or any(not isinstance(v, str) for v in classroom_ids):
        reject(400, 'invalid_request', 'classroom_ids must be a list')
    for cid in classroom_ids:
        room = room_access(c, actor, cid)
        if room['school_id'] not in school_scope(c, c.execute('SELECT * FROM users WHERE id=?', (teacher_id,)).fetchone()):
            reject(403, 'unassigned_school', 'Teacher is not assigned to that school')
    owned = {room['id'] for room in rooms_for(c, actor)}
    for row in list(c.execute('SELECT classroom_id FROM classroom_assignments WHERE user_id=?', (teacher_id,))):
        if row['classroom_id'] in owned:
            c.execute('DELETE FROM classroom_assignments WHERE user_id=? AND classroom_id=?', (teacher_id, row['classroom_id']))
    for cid in set(classroom_ids):
        c.execute('INSERT INTO classroom_assignments VALUES(?,?) ON CONFLICT DO NOTHING', (cid, teacher_id))


def snapshot(c, user):
    if user['role'] == 'teacher':
        reject(403, 'forbidden', 'Teachers cannot access the admin dashboard')
    scopes = school_scope(c, user)
    rooms = rooms_for(c, user)
    allowed = {room['id'] for room in rooms}
    schools = [dict(r) for r in c.execute('SELECT * FROM schools ORDER BY name') if r['id'] in scopes]
    school_logins = {r['school_id']: r['email'] for r in c.execute('SELECT l.school_id,u.email FROM school_logins l JOIN users u ON u.id=l.user_id')}
    for school in schools:
        school['login_id'] = school_logins.get(school['id'])
    devices = []
    now = time.time()
    version_rows = [dict(r) for r in c.execute('SELECT * FROM app_versions')]
    user_rows = [dict(r) for r in c.execute('SELECT id,name,email,role,status,last_login,must_change_password FROM users')]
    user_names = {r['id']: r['name'] for r in user_rows}
    user_scopes = defaultdict(set)
    for r in c.execute('SELECT * FROM user_schools'):
        user_scopes[r['user_id']].add(r['school_id'])
    assigned_rooms = defaultdict(list)
    assigned_teachers = defaultdict(list)
    for r in c.execute('SELECT * FROM classroom_assignments'):
        assigned_rooms[r['user_id']].append(r['classroom_id'])
        assigned_teachers[r['classroom_id']].append(r['user_id'])
    rules_map = {r['school_id']: dict(r) for r in c.execute('SELECT * FROM alert_rules')}
    heartbeat_times = defaultdict(list)
    for r in c.execute('SELECT device_id,at FROM heartbeats WHERE at>? ORDER BY at', (now - 7 * 86400,)):
        heartbeat_times[r['device_id']].append(r['at'])

    for row in c.execute('SELECT * FROM devices ORDER BY name'):
        if row['classroom_id'] not in allowed:
            if user['role'] == 'super_admin' and row['classroom_id'] not in {r['id'] for r in c.execute('SELECT id FROM classrooms')}:
                alert(c, 'unassigned_device', 'unassigned:' + row['id'], device=row['id'])
            continue
        d = dict(row)
        d.pop('secret_hash', None)
        room = next(r for r in rooms if r['id'] == d['classroom_id'])
        d.update(school_id=room['school_id'], school_name=room['school_name'], classroom_name=room['name'])
        d['status'] = status(d)
        if d['status'] not in ('disabled','needs_attention') and version_info(c, d['version'], version_rows)['outdated']:
            d['status'] = 'needs_attention'
        d['online'] = bool(d['active'] and not d['revoked'] and not d['reauth_required'] and d['connection_state'] == 'online' and d['last_seen'] and now - d['last_seen'] < OFFLINE_AFTER)
        if not d['online'] and d['connection_state'] == 'online':
            changed = c.execute("UPDATE devices SET connection_state='offline' WHERE id=? AND connection_state='online'", (d['id'],)).rowcount
            if changed:
                audit(c, 'system', 'device_disconnected', d['id'], room['school_id'])
        d['last_heartbeat'] = d['last_seen']
        d['version_state'] = version_info(c, d['version'], version_rows)
        d['teacher_name'] = user_names.get(d['teacher_id'], '')
        rule = rules_map.get(room['school_id'])
        offline_seconds = rule['offline_seconds'] if rule else 600
        if not d['online'] and now - (d['last_seen'] or d['created_at'] or now) > offline_seconds:
            alert(c, 'classroom_offline', f'offline:{d["id"]}:{int(d["last_seen"] or d["created_at"])}', room['school_id'], room['id'], d['id'])
        if d['version_state']['outdated']:
            if alert(c, 'outdated_version', f'version:{d["id"]}:{d["version"]}:{d["version_state"]["latest"]}', room['school_id'], room['id'], d['id']):
                audit(c, 'system', 'version_mismatch', d['id'], room['school_id'])
        devices.append(d)
    for room in rooms:
        room['teacher_ids'] = assigned_teachers[room['id']]
        room['online'] = any(d['online'] and d['classroom_id'] == room['id'] for d in devices)
        room['current_activities'] = [{'mode': d['current_mode'], 'chapter': d['chapter_id']} for d in devices if d['classroom_id'] == room['id'] and d['online']]
    users = []
    if user['role'] in ADMINS:
        for target in sorted(user_rows, key=lambda r: r['name']):
            target_scopes = school_scope(c, target) if target['role'] == 'super_admin' else user_scopes[target['id']]
            if user['role'] != 'super_admin' and (not (target_scopes & scopes) or (target['role'] != 'teacher' and target['id'] != user['id'])):
                continue
            item = public_user(target)
            item['school_ids'] = sorted(target_scopes if user['role'] == 'super_admin' else target_scopes & scopes)
            item['classroom_ids'] = [rid for rid in assigned_rooms[target['id']] if rid in allowed]
            item['manageable'] = user['role'] == 'super_admin' or (target['role'] == 'teacher' and target_scopes <= scopes)
            users.append(item)
    events = [dict(r) for r in c.execute('SELECT * FROM activity_events WHERE occurred_at>? ORDER BY occurred_at DESC', (now - 7 * 86400,)) if r['classroom_id'] in allowed]
    errors = [dict(r) for r in c.execute('SELECT * FROM error_events WHERE at>? ORDER BY at DESC', (now - 7 * 86400,)) if r['classroom_id'] in allowed]
    usage = [dict(r) for r in c.execute('SELECT * FROM usage_daily WHERE day>=? ORDER BY day', (datetime.fromtimestamp(now - 6 * 86400, timezone.utc).date().isoformat(),)) if r['classroom_id'] in allowed]
    chapters = defaultdict(lambda: {'started': 0, 'completed': 0})
    for e in events:
        if e['chapter_id']:
            chapters[e['chapter_id']]['started' if e['event_type'].endswith('_started') else 'completed' if e['event_type'].endswith('_completed') else 'other'] = chapters[e['chapter_id']].get('started' if e['event_type'].endswith('_started') else 'completed' if e['event_type'].endswith('_completed') else 'other', 0) + 1
    completed = [e for e in events if e['event_type'].endswith('_completed')]
    today = datetime.now(timezone.utc).date().isoformat()
    analytics = {'dailyActiveClassrooms': len({e['classroom_id'] for e in events if datetime.fromtimestamp(e['occurred_at'], timezone.utc).date().isoformat() == today}), 'weeklyActiveClassrooms': len({e['classroom_id'] for e in events}), 'lessonsStarted': sum(e['event_type'] == 'lesson_started' for e in events), 'lessonsCompleted': sum(e['event_type'] == 'lesson_completed' for e in events), 'practiceSessions': sum(e['event_type'] == 'practice_started' for e in events), 'quizSessions': sum(e['event_type'] == 'quiz_started' for e in events), 'averageSessionDuration': round(sum(e['duration_seconds'] for e in completed) / max(1, len(completed)), 1), 'todayUsage': sum(r['started'] for r in usage if r['day'] == today), 'weeklyUsage': sum(r['started'] for r in usage), 'chapterUsage': dict(chapters), 'usageDaily': usage, 'practiceByClass': dict(Counter(str(e['grade']) for e in events if e['event_type'] == 'practice_started')), 'quizByClass': dict(Counter(str(e['grade']) for e in events if e['event_type'] == 'quiz_started')), 'teacherActivity': dict(Counter(e['teacher_id'] for e in events if e['event_type'].endswith('_started'))), 'versionDistribution': dict(Counter(d['version'] or 'unknown' for d in devices)), 'errorFrequency': dict(Counter(e['code'] for e in errors))}
    uptime = {}
    for device in devices:
        beats = heartbeat_times[device['id']]
        observed = sum(min(OFFLINE_AFTER, max(0, right - left)) for left, right in zip(beats, beats[1:]))
        if beats:
            observed += min(OFFLINE_AFTER, now - beats[-1])
        window = min(7 * 86400, max(0, now - (device['created_at'] or now)))
        uptime[device['id']] = {'observedConnectedSeconds': round(observed), 'estimatedOfflineSeconds': round(max(0, window - observed)), 'estimate': True}
    analytics['deviceAvailability'] = uptime
    alerts = [dict(r) for r in c.execute('SELECT * FROM alerts ORDER BY at DESC') if (r['school_id'] in scopes or (r['school_id'] is None and user['role'] == 'super_admin'))]
    system_actions = {'teacher_login','teacher_logout','device_registered','device_connected','device_disconnected','device_revoked','session_expired','version_mismatch'}
    scoped_logs = [dict(r) for r in c.execute('SELECT * FROM audit_logs ORDER BY at DESC LIMIT 500') if user['role'] == 'super_admin' or r['school_id'] in scopes]
    logs = scoped_logs if user['role'] in ADMINS else []
    system_events = [r for r in scoped_logs if r['action'] in system_actions]
    rules = [dict(r) for r in c.execute('SELECT * FROM alert_rules') if r['school_id'] in scopes]
    overview = {'schools': len(schools), 'classrooms': len(rooms), 'devices': len(devices), 'onlineClassrooms': sum(r['online'] for r in rooms), 'offlineClassrooms': sum(not r['online'] for r in rooms), 'recentlyActiveClassrooms': len({d['classroom_id'] for d in devices if d['last_seen'] and now - d['last_seen'] < 300}), 'activeTeachers': len({d['teacher_id'] for d in devices if d['online'] and d['teacher_id']}), 'activeLessons': sum(d['online'] and d['current_mode'] == 'learn' for d in devices), 'activePractice': sum(d['online'] and d['current_mode'] == 'practice' for d in devices), 'activeQuizzes': sum(d['online'] and d['current_mode'] == 'quiz' for d in devices), 'attention': sum(d['status'] in ('needs_attention', 'disabled') for d in devices), 'outdatedDevices': sum(d['version_state']['outdated'] for d in devices)}
    return {'overview': overview, 'schools': schools, 'classrooms': rooms, 'devices': devices, 'users': users, 'teachers': [u for u in users if u['role'] == 'teacher'], 'analytics': analytics, 'events': events[:100], 'errors': errors[:100], 'alerts': alerts[:200], 'audit': logs[:100], 'systemEvents': system_events[:50], 'versions': sorted(version_rows, key=lambda r: r['updated_at'], reverse=True), 'alertRules': rules, 'revision': c.execute('SELECT revision FROM system_state WHERE id=1').fetchone()['revision'], 'statusBucket': int(now // 5), 'offlineAfterSeconds': OFFLINE_AFTER, 'mode': ENV, 'dataMode': 'presentation' if is_presentation() else 'live', 'serverTime': now, 'sampleHistory': is_presentation()}


def execute(method, target, headers, body):
    """Single domain boundary shared by the WSGI and loopback transports."""
    path = urlsplit(target).path.rstrip('/') or '/'
    origin = headers.get('Origin')
    if origin not in (None, *allowed_origins()):
        reject(403, 'origin_rejected', 'Origin is not allowed')
    if ENV == 'production' and headers.get('X-Forwarded-Proto') != 'https':
        reject(400, 'https_required', 'HTTPS is required')
    if method in ('POST', 'PATCH') and not isinstance(body, dict):
        reject(400, 'invalid_request', 'JSON object required')
    installation = str(body.get('installationId', headers.get('X-Installation-ID', 'legacy')))[:128]
    with connection() as c:
        if path in ('/login', '/auth/reset-password', '/auth/reauthenticate') and method == 'POST':
            ip = headers.get('X-Ganit-Request-IP', 'local')
            ip_key, ip_count = rate_limit(c, 'source:' + ip, maximum=60)
            c.execute('INSERT INTO login_attempts VALUES(?,?,?) ON CONFLICT(identity) DO UPDATE SET count=login_attempts.count+1', (ip_key, time.time(), ip_count + 1))
        if path == '/health' and method == 'GET':
            c.execute('SELECT 1')
            return 200, {'ok': True, 'mode': ENV, 'database': 'postgresql' if DATABASE_URL else 'sqlite-development', 'schemaVersion': 6, 'leasePublicKey': public_key(), 'dataMode': 'presentation' if is_presentation() else 'live', 'portal': os.environ.get('GANIT_APP_SURFACE', 'auto')}, []
        if path == '/login' and method == 'POST':
            email = required(body, 'email', 254).lower()
            password = body.get('password', '')
            if not isinstance(password, str) or len(password) > 1024:
                reject(400, 'invalid_request', 'Invalid password length')
            user = c.execute('SELECT * FROM users WHERE email=?', (email,)).fetchone()
            identity, count = rate_limit(c, email, user)
            hashed = password_hash(password, user['salt'] if user else '00' * 16)
            if not user or not hmac.compare_digest(user['password_hash'], hashed) or user['status'] != 'active':
                login_failed(c, identity, count, user)
                reject(401, 'invalid_credentials', 'Check your sign-in details or account status')
            user = dict(user)
            c.execute('DELETE FROM login_attempts WHERE identity=?', (identity,))
            c.execute('UPDATE users SET last_login=? WHERE id=?', (time.time(), user['id']))
            user['last_login'] = time.time()
            device_id = None
            if classroom_user(user) and not user['must_change_password']:
                row = c.execute('SELECT id FROM devices WHERE id=?', (installation,)).fetchone()
                if row:
                    check_device(c, user, installation, headers)
                    device_id = installation
            result, cookies = issue_session(c, user, installation, headers, device_id)
            for sid in school_scope(c, user) or {None}:
                audit(c, user['id'], 'teacher_login' if user['role'] == 'teacher' else 'login', device_id or installation, sid)
            return 200, result, cookies
        if path == '/auth/logout' and method == 'POST':
            if origin not in allowed_origins():
                reject(403, 'origin_required', 'Logout requires the approved application origin')
            refresh = cookie_value(headers, cookie_name('gs_refresh', installation))
            token = c.execute('SELECT user_id,family_id FROM refresh_tokens WHERE token_hash=? AND install_id=?', (digest(refresh), installation)).fetchone() if refresh else None
            if token:
                c.execute('DELETE FROM sessions WHERE family_id=?', (token['family_id'],))
                c.execute('UPDATE refresh_tokens SET revoked=1 WHERE family_id=?', (token['family_id'],))
                role = c.execute('SELECT role FROM users WHERE id=?', (token['user_id'],)).fetchone()
                d = c.execute('SELECT c.school_id FROM devices d JOIN classrooms c ON c.id=d.classroom_id WHERE d.id=?', (installation,)).fetchone()
                audit(c, token['user_id'], 'teacher_logout' if role and role['role'] == 'teacher' else 'logout', installation, d['school_id'] if d else None)
                c.execute("UPDATE devices SET connection_state='signed_out',current_mode='idle',session_count=0 WHERE id=?", (installation,))
            return 200, {'ok': True}, [cookie(cookie_name('gs_refresh', installation), '', 0)]
        if path == '/auth/refresh' and method == 'POST':
            if origin not in allowed_origins():
                reject(403, 'origin_required', 'Refresh requires the approved application origin')
            refresh = cookie_value(headers, cookie_name('gs_refresh', installation))
            row = c.execute('SELECT * FROM refresh_tokens WHERE token_hash=? AND install_id=?', (digest(refresh), installation)).fetchone() if refresh else None
            if not row:
                reject(401, 'reauth_required', 'Sign in again')
            row = dict(row)
            if row['used_at'] is not None:
                c.execute('UPDATE refresh_tokens SET revoked=1 WHERE family_id=?', (row['family_id'],))
                c.execute('DELETE FROM sessions WHERE family_id=?', (row['family_id'],))
                alert(c, 'suspicious_session', 'reuse:' + row['family_id'], severity='critical')
                audit(c, row['user_id'], 'refresh_reuse_detected', row['install_id'])
                c.commit()
                reject(401, 'refresh_reuse', 'Session was revoked; sign in again')
            user = c.execute('SELECT * FROM users WHERE id=?', (row['user_id'],)).fetchone()
            if row['revoked'] or row['expires'] < time.time() or not user or user['status'] != 'active':
                reject(401, 'reauth_required', 'Session expired or account disabled')
            if row['device_id']:
                device, _ = check_device(c, user, row['device_id'], headers)
                if device['reauth_required']:
                    reject(401, 'reauth_required', 'Administrator requires sign-in again')
            updated = c.execute('UPDATE refresh_tokens SET used_at=? WHERE token_hash=? AND used_at IS NULL AND revoked=0', (time.time(), row['token_hash'])).rowcount
            if updated != 1:
                reject(401, 'refresh_reuse', 'Session was already refreshed')
            # Access tokens in this family are replaced together with the refresh token.
            c.execute('DELETE FROM sessions WHERE family_id=?', (row['family_id'],))
            result, cookies = issue_session(c, dict(user), installation, headers, row['device_id'], row['family_id'])
            return 200, result, cookies
        if path == '/auth/reset-password' and method == 'POST':
            reset = required(body, 'resetToken', 256)
            password = secret(body, 'newPassword')
            if len(password) < 12:
                reject(400, 'weak_password', 'Use at least 12 characters')
            reset_identity, reset_count = rate_limit(c, 'reset:' + digest(reset))
            row = c.execute('SELECT * FROM password_reset_tokens WHERE token_hash=?', (digest(reset),)).fetchone()
            if not row or row['used_at'] is not None or row['expires'] <= time.time():
                login_failed(c, reset_identity, reset_count, None)
                reject(400, 'invalid_reset', 'Reset token is expired or already used')
            if c.execute('UPDATE password_reset_tokens SET used_at=? WHERE token_hash=? AND used_at IS NULL', (time.time(), digest(reset))).rowcount != 1:
                reject(400, 'invalid_reset', 'Reset token was already used')
            salt = secrets.token_hex(16)
            c.execute('UPDATE users SET salt=?,password_hash=?,must_change_password=0 WHERE id=?', (salt, password_hash(password, salt), row['user_id']))
            invalidate_user(c, row['user_id'])
            audit(c, row['user_id'], 'password_reset_completed')
            return 200, {'ok': True}, []
        user, session = authenticate(c, headers)
        if user['must_change_password'] and path not in ('/me', '/auth/change-password', '/logout'):
            reject(403, 'password_change_required', 'Change the initial password before continuing')
        if path == '/logout' and method == 'POST':
            c.execute('DELETE FROM sessions WHERE family_id=?', (session['family_id'],))
            c.execute('UPDATE refresh_tokens SET revoked=1 WHERE family_id=?', (session['family_id'],))
            audit(c, user['id'], 'teacher_logout' if user['role'] == 'teacher' else 'logout', session['device_id'] or '')
            return 200, {'ok': True}, [cookie(cookie_name('gs_refresh', session['install_id']), '', 0)]
        if path == '/auth/change-password' and method == 'POST':
            old = secret(body, 'currentPassword')
            new = secret(body, 'newPassword')
            if len(new) < 12 or old == new:
                reject(400, 'weak_password', 'Choose a different password of at least 12 characters')
            if not hmac.compare_digest(user['password_hash'], password_hash(old, user['salt'])):
                reject(401, 'invalid_credentials', 'Current password is incorrect')
            salt = secrets.token_hex(16)
            c.execute('UPDATE users SET salt=?,password_hash=?,must_change_password=0 WHERE id=?', (salt, password_hash(new, salt), user['id']))
            invalidate_user(c, user['id'])
            user = dict(c.execute('SELECT * FROM users WHERE id=?', (user['id'],)).fetchone())
            audit(c, user['id'], 'password_changed')
            result, cookies = issue_session(c, user, session['install_id'], headers, session['device_id'])
            return 200, result, cookies
        if path == '/auth/reauthenticate' and method == 'POST':
            password = secret(body, 'password')
            identity, count = rate_limit(c, 'reauth:' + user['id'], user)
            if not hmac.compare_digest(user['password_hash'], password_hash(password, user['salt'])):
                login_failed(c, identity, count, user)
                reject(401, 'invalid_credentials', 'Check your password')
            c.execute('DELETE FROM login_attempts WHERE identity=?', (identity,))
            return 200, {'ok': True}, []
        if path in ('/me', '/me/classrooms') and method == 'GET':
            return 200, {'user': public_user(user), 'classrooms': rooms_for(c, user, True), 'schools': schools_for(c, user)}, []
        if path == '/dashboard/demo' and method == 'GET':
            require_admin(user, True)
            if os.environ.get('GANIT_APP_SURFACE') == 'classroom':
                reject(403, 'forbidden', 'Demo preview is available only in the dashboard')
            with dataset(True), connection() as preview:
                return 200, snapshot(preview, user), []
        if path in ('/dashboard', '/events/stream') and method == 'GET':
            if user['role'] not in ADMINS | {'viewer'}:
                reject(403, 'forbidden', 'Administrative monitoring permission required')
            return 200, None if path.endswith('/stream') else snapshot(c, user), []
        if path == '/schools' and method == 'POST':
            require_admin(user, True)
            school_id = uid()
            c.execute('INSERT INTO schools(id,name,location,code,admin_contact,created_at) VALUES(?,?,?,?,?,?)', (school_id, required(body, 'name'), str(body.get('location', ''))[:200], (str(body.get('code','')).strip() or 'SCH-' + school_id[:8].upper())[:60], str(body.get('admin_contact', ''))[:254], time.time()))
            login = create_school_login(c, user, {'id': school_id, 'name': required(body, 'name')})
            audit(c, user['id'], 'school_created', school_id, school_id)
            return 201, {'id': school_id, 'login': login}, []
        if re.fullmatch(r'/schools/[^/]+/login', path) and method == 'POST':
            require_admin(user, True)
            school = c.execute('SELECT id,name,status FROM schools WHERE id=?', (path.split('/')[2],)).fetchone()
            if not school:
                reject(404, 'not_found', 'Unknown school')
            if school['status'] != 'active':
                reject(400, 'invalid_request', 'Choose an active school')
            return 201, {'login': create_school_login(c, user, school)}, []
        if path.startswith('/schools/') and method == 'PATCH':
            school_id = path.split('/')[2]
            require_admin(user, True)
            row = c.execute('SELECT * FROM schools WHERE id=?', (school_id,)).fetchone()
            if not row:
                reject(404, 'not_found', 'Unknown school')
            state = body.get('status', row['status'])
            if state not in ('active', 'disabled'):
                reject(400, 'invalid_request', 'Invalid school status')
            c.execute('UPDATE schools SET name=?,location=?,code=?,admin_contact=?,status=? WHERE id=?', (str(body.get('name', row['name']))[:160], str(body.get('location', row['location']))[:200], str(body.get('code', row['code']))[:60], str(body.get('admin_contact', row['admin_contact']))[:254], state, school_id))
            if state != 'active':
                for row in c.execute('SELECT d.id FROM devices d JOIN classrooms c ON c.id=d.classroom_id WHERE c.school_id=?', (school_id,)):
                    invalidate_device(c, row['id'])
            audit(c, user['id'], 'school_updated', school_id, school_id)
            return 200, {'ok': True}, []
        if path == '/classrooms' and method == 'POST':
            require_admin(user)
            school_id = body.get('school_id')
            if not school_id and ENV != 'production' and body.get('school') and user['role'] == 'super_admin':
                existing = c.execute('SELECT id FROM schools WHERE name=?', (str(body['school']),)).fetchone()
                school_id = existing['id'] if existing else uid()
                if not existing:
                    c.execute('INSERT INTO schools(id,name,code,created_at) VALUES(?,?,?,?)', (school_id, str(body['school'])[:160], school_id, time.time()))
            if school_id not in school_scope(c, user):
                reject(403, 'forbidden', 'School is outside your scope')
            school = c.execute('SELECT * FROM schools WHERE id=?', (school_id,)).fetchone()
            grade = number(body, 'grade', 0, 4)
            if grade not in range(1, 5) or not school or school['status'] != 'active':
                reject(400, 'invalid_request', 'Choose an active school and class 1–4')
            classroom_id = uid()
            c.execute('INSERT INTO classrooms(id,name,school,grade,school_id,section,created_at) VALUES(?,?,?,?,?,?,?)', (classroom_id, required(body, 'name'), school['name'], grade, school_id, str(body.get('section', ''))[:30], time.time()))
            teachers = body.get('teacher_ids', [body['teacher_id']] if body.get('teacher_id') else [])
            assign_teachers(c, user, classroom_id, teachers)
            audit(c, user['id'], 'classroom_created', classroom_id, school_id)
            return 201, {'id': classroom_id}, []
        if path.startswith('/classrooms/') and method == 'PATCH':
            require_admin(user)
            classroom_id = path.split('/')[2]
            room = room_access(c, user, classroom_id)
            state = body.get('status', room['status'])
            grade = number(body, 'grade', room['grade'], 4)
            if state not in ('active', 'disabled', 'archived') or grade not in range(1, 5):
                reject(400, 'invalid_request', 'Invalid classroom status or grade')
            c.execute('UPDATE classrooms SET name=?,grade=?,section=?,status=? WHERE id=?', (str(body.get('name', room['name']))[:160], grade, str(body.get('section', room['section']))[:30], state, classroom_id))
            if 'teacher_ids' in body or 'teacher_id' in body:
                assign_teachers(c, user, classroom_id, body.get('teacher_ids', [body['teacher_id']] if body.get('teacher_id') else []))
                for d in c.execute('SELECT id FROM devices WHERE classroom_id=?', (classroom_id,)):
                    invalidate_device(c, d['id'])
            if state != 'active':
                for d in c.execute('SELECT id FROM devices WHERE classroom_id=?', (classroom_id,)):
                    invalidate_device(c, d['id'])
            audit(c, user['id'], 'classroom_updated', classroom_id, room['school_id'])
            return 200, {'ok': True}, []
        if path == '/users' and method == 'POST':
            require_admin(user)
            role = body.get('role', 'teacher')
            if role not in ROLES or (user['role'] != 'super_admin' and role != 'teacher'):
                reject(403, 'forbidden', 'Role is not available to this administrator')
            schools = body.get('school_ids', [])
            if not isinstance(schools, list) or (role != 'super_admin' and not schools) or not set(schools) <= school_scope(c, user):
                reject(403, 'forbidden', 'Choose assigned schools')
            password = secret(body, 'password')
            if len(password) < 12:
                reject(400, 'weak_password', 'Use at least 12 characters')
            email = required(body, 'email', 254).lower()
            if '@' not in email:
                reject(400, 'invalid_request', 'Check the email address')
            user_id, salt = uid(), secrets.token_hex(16)
            c.execute('INSERT INTO users(id,email,name,role,salt,password_hash,must_change_password,created_at) VALUES(?,?,?,?,?,?,1,?)', (user_id, email, required(body, 'name'), role, salt, password_hash(password, salt), time.time()))
            for school in set(schools):
                c.execute('INSERT INTO user_schools VALUES(?,?)', (user_id, school))
            if role == 'teacher':
                c.execute('INSERT INTO teachers VALUES(?,?)', (user_id, time.time()))
                manage_assignments(c, user, user_id, body.get('classroom_ids', []))
            audit(c, user['id'], 'user_created', user_id, schools[0] if len(schools) == 1 else None)
            return 201, {'id': user_id, 'mustChangePassword': True}, []
        if path.startswith('/users/'):
            target_id = path.split('/')[2]
            target_user = user_access(c, user, target_id)
            target_scopes = school_scope(c, target_user)
            sid = next(iter(target_scopes)) if len(target_scopes) == 1 else None
            if method == 'POST' and path.endswith('/password-reset'):
                reset = secrets.token_urlsafe(40)
                c.execute('INSERT INTO password_reset_tokens VALUES(?,?,?,?,NULL)', (digest(reset), target_id, time.time(), time.time() + 1800))
                audit(c, user['id'], 'password_reset_issued', target_id, sid)
                return 201, {'resetToken': reset, 'expiresIn': 1800}, []
            if method == 'POST' and path.endswith('/revoke-sessions'):
                invalidate_user(c, target_id)
                audit(c, user['id'], 'user_sessions_revoked', target_id, sid)
                return 200, {'ok': True}, []
            if method == 'PATCH':
                state = body.get('status', target_user['status'])
                if state not in ('active', 'disabled'):
                    reject(400, 'invalid_request', 'Invalid user status')
                if target_user['role'] == 'super_admin' and state != 'active' and c.execute("SELECT COUNT(*) AS n FROM users WHERE role='super_admin' AND status='active'").fetchone()['n'] <= 1:
                    reject(409, 'last_administrator', 'Keep an active super administrator')
                if 'school_ids' in body:
                    require_admin(user, True)
                    schools = body['school_ids']
                    school_login = c.execute('SELECT school_id FROM school_logins WHERE user_id=?', (target_id,)).fetchone()
                    if school_login and (not isinstance(schools, list) or set(schools) != {school_login['school_id']}):
                        reject(400, 'invalid_request', 'A school login belongs to its original school')
                    if not isinstance(schools, list) or not set(schools) <= school_scope(c, user):
                        reject(400, 'invalid_request', 'Invalid schools')
                    c.execute('DELETE FROM user_schools WHERE user_id=?', (target_id,))
                    for school in set(schools):
                        c.execute('INSERT INTO user_schools VALUES(?,?)', (target_id, school))
                if 'classroom_ids' in body:
                    if target_user['role'] != 'teacher':
                        reject(400, 'invalid_request', 'Only teachers can have classroom assignments')
                    manage_assignments(c, user, target_id, body['classroom_ids'])
                c.execute('UPDATE users SET name=?,status=? WHERE id=?', (str(body.get('name', target_user['name']))[:160], state, target_id))
                invalidate_user(c, target_id)
                if state != 'active':
                    for scope in target_scopes:
                        alert(c, 'teacher_disabled', 'disabled-user:' + target_id, school=scope)
                audit(c, user['id'], 'user_updated', target_id, sid)
                return 200, {'ok': True}, []
        if path == '/devices/register' and method == 'POST':
            if user['role'] not in ADMINS | {'teacher'}:
                reject(403, 'forbidden', 'Device registration is not allowed')
            room = room_access(c, user, body.get('classroom_id'), True)
            device_id = required(body, 'id', 128)
            if len(device_id) < 16 or device_id != installation and installation != 'legacy':
                reject(400, 'invalid_request', 'Use this installation identity')
            name = required(body, 'name')
            existing = c.execute('SELECT * FROM devices WHERE id=?', (device_id,)).fetchone()
            legacy = ENV != 'production' and isinstance(body.get('secret'), str) and len(body['secret']) >= 32
            if existing:
                proof = device_proof(c, headers, device_id) or (legacy and hmac.compare_digest(existing['secret_hash'], digest(body['secret'])))
                if existing['revoked'] or not existing['active'] or not proof:
                    reject(403, 'device_identity_rejected', 'Device identity rejected or revoked')
                if existing['classroom_id'] != room['id']:
                    reject(409, 'already_assigned', 'Only an administrator can reassign a device')
            else:
                c.execute('INSERT INTO devices(id,secret_hash,name,classroom_id,teacher_id,version,created_at) VALUES(?,?,?,?,?,?,?)', (device_id, digest(body['secret']) if legacy else '', name, room['id'], user['id'], '', time.time()))
            c.execute('UPDATE device_sessions SET revoked=1 WHERE device_id=?', (device_id,))
            proof = secrets.token_urlsafe(48)
            c.execute('INSERT INTO device_sessions VALUES(?,?,?,?,0)', (digest(proof), device_id, time.time(), time.time() + REFRESH_TTL))
            proof_cookie = cookie(cookie_name('gs_device', device_id), proof, REFRESH_TTL)
            verified_headers = dict(headers)
            verified_headers['Cookie'] = headers.get('Cookie', '') + '; ' + cookie_name('gs_device', device_id) + '=' + proof
            c.execute('UPDATE devices SET reauth_required=0 WHERE id=?', (device_id,))
            result, cookies = issue_session(c, user, device_id, verified_headers, device_id)
            result['id'] = device_id
            audit(c, user['id'], 'device_registered' if not existing else 'device_authenticated', device_id, room['school_id'])
            return 200 if existing else 201, result, cookies + [proof_cookie]
        if path == '/me/device' and method == 'GET':
            if not session['device_id']:
                return 200, {'device': None}, []
            device, room = check_device(c, user, session['device_id'], headers)
            device.pop('secret_hash', None)
            return 200, {'device': device, 'classroom': room}, []
        if path.startswith('/devices/'):
            device_id = path.split('/')[2]
            if method == 'POST' and (path.endswith('/heartbeat') or path.endswith('/sync') or path.endswith('/events')):
                device, room = check_device(c, user, device_id, headers, body.get('secret'))
                legacy = ENV != 'production' and body.get('secret')
                if not legacy and session['device_id'] != device_id:
                    reject(403, 'device_identity_rejected', 'Session is not bound to this device')
                if device['reauth_required']:
                    reject(401, 'reauth_required', 'Sign in again')
                if path.endswith('/events'):
                    return 200, ingest_events(c, user, device, room, body), []
                return 200, heartbeat(c, user, device, room, body), []
            require_admin(user) if method != 'GET' else None
            row = c.execute('SELECT * FROM devices WHERE id=?', (device_id,)).fetchone()
            if not row:
                reject(404, 'not_found', 'Unknown device')
            device = dict(row)
            room = room_access(c, user, device['classroom_id'])
            if user['role'] == 'teacher':
                reject(403, 'forbidden', 'Teachers cannot manage devices')
            if method == 'GET' and path.endswith('/activity'):
                return 200, {'events': [dict(r) for r in c.execute('SELECT * FROM activity_events WHERE device_id=? ORDER BY occurred_at DESC LIMIT 200', (device_id,)) if r['classroom_id'] in {room['id'] for room in rooms_for(c, user)}]}, []
            if method == 'GET' and path.endswith('/errors'):
                return 200, {'errors': [dict(r) for r in c.execute('SELECT * FROM error_events WHERE device_id=? ORDER BY at DESC LIMIT 200', (device_id,)) if r['classroom_id'] in {room['id'] for room in rooms_for(c, user)}]}, []
            if method == 'PATCH':
                classroom_id = body.get('classroom_id', device['classroom_id'])
                new_room = room_access(c, user, classroom_id)
                active = int(bool(body.get('active', device['active'])))
                revoked = int(bool(body.get('revoked', device['revoked']))) or device['revoked']
                c.execute('UPDATE devices SET name=?,classroom_id=?,active=?,revoked=? WHERE id=?', (str(body.get('name', device['name']))[:160], classroom_id, active, revoked, device_id))
                if revoked or not active or classroom_id != device['classroom_id'] or body.get('force_logout') or body.get('require_reauth'):
                    invalidate_device(c, device_id)
                if revoked:
                    c.execute('UPDATE device_sessions SET revoked=1 WHERE device_id=?', (device_id,))
                    alert(c, 'device_revoked', 'revoked:' + device_id, new_room['school_id'], classroom_id, device_id, 'critical')
                audit(c, user['id'], 'device_revoked' if revoked else 'device_updated', device_id, new_room['school_id'])
                return 200, {'ok': True}, []
        if path == '/versions' and method == 'POST':
            require_admin(user, True)
            version = body.get('version')
            if not valid_version(version):
                reject(400, 'invalid_request', 'Use a semantic app version')
            now = time.time()
            c.execute('INSERT INTO app_versions VALUES(?,?,?,?,?) ON CONFLICT(version) DO UPDATE SET approved=?,supported=?,updated_at=?', (version, int(bool(body.get('approved'))), int(body.get('supported', True)), now, now, int(bool(body.get('approved'))), int(body.get('supported', True)), now))
            audit(c, user['id'], 'version_updated', version)
            return 200, {'ok': True}, []
        if path.startswith('/alerts/') and method == 'PATCH':
            require_admin(user)
            alert_id = path.split('/')[2]
            row = c.execute('SELECT * FROM alerts WHERE id=?', (alert_id,)).fetchone()
            if not row or not (row['school_id'] in school_scope(c, user) or user['role'] == 'super_admin'):
                reject(403, 'forbidden', 'Alert is outside your scope')
            state = body.get('status')
            if state not in ('open', 'resolved'):
                reject(400, 'invalid_request', 'Invalid alert status')
            c.execute('UPDATE alerts SET status=?,resolved_at=? WHERE id=?', (state, time.time() if state == 'resolved' else None, alert_id))
            audit(c, user['id'], 'alert_updated', alert_id, row['school_id'])
            return 200, {'ok': True}, []
        if path.startswith('/alert-rules/') and method == 'PATCH':
            require_admin(user)
            sid = path.split('/')[2]
            if sid not in school_scope(c, user):
                reject(403, 'forbidden', 'School is outside your scope')
            offline = int(number(body, 'offline_seconds', 600, 7 * 86400))
            errors = int(number(body, 'error_threshold', 3, 100))
            logins = int(number(body, 'login_threshold', 5, 10))
            if offline < OFFLINE_AFTER or errors < 1 or logins < 1:
                reject(400, 'invalid_request', 'Alert thresholds are too small')
            c.execute('INSERT INTO alert_rules VALUES(?,?,?,?) ON CONFLICT(school_id) DO UPDATE SET offline_seconds=?,error_threshold=?,login_threshold=?', (sid, offline, errors, logins, offline, errors, logins))
            audit(c, user['id'], 'alert_rules_updated', sid, sid)
            return 200, {'ok': True}, []
        reject(404, 'not_found', 'Unknown route')


def assign_teachers(c, actor, classroom_id, teachers):
    room = room_access(c, actor, classroom_id)
    if not isinstance(teachers, list) or len(teachers) > 50:
        reject(400, 'invalid_request', 'teacher_ids must be a list')
    for teacher_id in teachers:
        teacher = c.execute("SELECT * FROM users WHERE id=? AND role='teacher' AND status='active'", (teacher_id,)).fetchone()
        if not teacher:
            reject(400, 'invalid_request', 'Unknown or inactive teacher')
        c.execute('INSERT INTO user_schools VALUES(?,?) ON CONFLICT DO NOTHING', (teacher_id, room['school_id'])) if actor['role'] == 'super_admin' else None
        if room['school_id'] not in school_scope(c, teacher):
            reject(403, 'forbidden', 'Teacher belongs to another school')
    c.execute('DELETE FROM classroom_assignments WHERE classroom_id=?', (classroom_id,))
    for teacher_id in set(teachers):
        c.execute('INSERT INTO classroom_assignments VALUES(?,?)', (classroom_id, teacher_id))
    c.execute('UPDATE classrooms SET teacher_id=? WHERE id=?', (teachers[0] if teachers else None, classroom_id))


def heartbeat(c, user, device, room, body):
    allowed = {'secret', 'activity', 'version', 'health', 'mode', 'grade', 'chapterId', 'lastInteractionAt', 'networkState', 'errorCount', 'activeSessions', 'classroomId'}
    if set(body) - allowed:
        reject(400, 'private_payload_rejected', 'Only anonymous heartbeat fields are accepted')
    if body.get('classroomId', room['id']) != room['id']:
        reject(403, 'unassigned_classroom', 'Heartbeat classroom does not match')
    version = body.get('version', '1.2.0')
    if not valid_version(version):
        reject(400, 'invalid_request', 'Invalid app version')
    vi = version_info(c, version)
    if vi['unsupported']:
        alert(c, 'unsupported_version', f'unsupported:{device["id"]}:{version}', room['school_id'], room['id'], device['id'], 'critical')
        c.commit()
        reject(426, 'unsupported_version', 'Reconnect with a supported version')
    mode = body.get('mode', 'idle')
    grade = number(body, 'grade', room['grade'], 4)
    chapter = chapter_id(body.get('chapterId', ''), grade)
    network = body.get('networkState', 'online')
    health = body.get('health', 'ok')
    if mode not in MODES or grade not in range(1, 5) or network not in ('online', 'offline') or health not in ('ok', 'degraded', 'error'):
        reject(400, 'invalid_request', 'Invalid heartbeat state')
    now = time.time()
    last_interaction = min(now + 60, number(body, 'lastInteractionAt', now, now + 300))
    error_count = int(number(body, 'errorCount', 0, 1000000))
    session_count = int(number(body, 'activeSessions', 0, 10))
    if not device['last_seen'] or now - device['last_seen'] >= OFFLINE_AFTER:
        audit(c, user['id'], 'device_connected', device['id'], room['school_id'])
    c.execute('UPDATE devices SET last_seen=?,last_sync=?,activity=?,version=?,health=?,current_mode=?,current_grade=?,chapter_id=?,last_interaction=?,network_state=?,error_count=?,session_count=?,teacher_id=? WHERE id=?', (now, now, int(number(body, 'activity', device['activity'])), version, health, mode, grade, chapter, last_interaction, network, error_count, session_count, user['id'], device['id']))
    c.execute("UPDATE devices SET connection_state='online' WHERE id=?", (device['id'],))
    if device['version'] != version or not device.get('version_updated_at'):
        c.execute('UPDATE devices SET version_updated_at=? WHERE id=?', (now, device['id']))
    c.execute('INSERT INTO heartbeats VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?)', (uid(), device['id'], room['id'], user['id'], now, mode, grade, chapter, last_interaction, network, health, error_count, session_count, version))
    if health != 'ok':
        alert(c, 'unhealthy_heartbeat', f'health:{device["id"]}:{health}:{int(now // 3600)}', room['school_id'], room['id'], device['id'])
    else:
        c.execute("UPDATE alerts SET status='resolved',resolved_at=? WHERE device_id=? AND status='open' AND code IN ('classroom_offline','unhealthy_heartbeat')", (now, device['id']))
    c.execute('UPDATE system_state SET revision=revision+1 WHERE id=1')
    return {'syncedAt': now, 'classroom': room['name'], 'school': room['school_name'], 'active': True, 'serverTime': now, 'versionState': vi}


def ingest_events(c, user, device, room, body):
    if set(body) != {'events'} or not isinstance(body['events'], list) or not 1 <= len(body['events']) <= 100:
        reject(400, 'invalid_request', 'Send 1–100 anonymous events')
    acknowledged = []
    now = time.time()
    for item in body['events']:
        if not isinstance(item, dict) or set(item) - {'id', 'type', 'sessionId', 'mode', 'grade', 'chapterId', 'occurredAt', 'durationSeconds', 'classroomId', 'errorCode'}:
            reject(400, 'private_payload_rejected', 'Individual answer/profile fields are not accepted')
        event_id = required(item, 'id', 128)
        session_id = required(item, 'sessionId', 128)
        event_type = item.get('type')
        mode = item.get('mode')
        grade = number(item, 'grade', room['grade'], 4)
        if event_type not in EVENT_TYPES or mode not in MODES or grade not in range(1, 5) or item.get('classroomId') != room['id']:
            reject(400, 'invalid_request', 'Invalid event or classroom context')
        expected = 'learn' if event_type.startswith('lesson_') else 'practice' if event_type.startswith('practice_') else 'quiz' if event_type.startswith('quiz_') else mode
        if mode != expected:
            reject(400, 'invalid_request', 'Event does not match mode')
        occurred = number(item, 'occurredAt', now, now + 300)
        duration = number(item, 'durationSeconds', 0, 86400)
        if occurred < now - 30 * 86400:
            acknowledged.append(event_id)
            continue
        existing = c.execute('SELECT device_id FROM activity_events WHERE id=?', (event_id,)).fetchone()
        if existing and existing['device_id'] != device['id']:
            reject(409, 'event_identity_conflict', 'Event identity belongs to another installation')
        inserted = c.execute('INSERT INTO activity_events VALUES(?,?,?,?,?,?,?,?,?,?,?,?) ON CONFLICT DO NOTHING', (event_id, device['id'], room['id'], user['id'], event_type, session_id, mode, grade, chapter_id(item.get('chapterId', ''), grade), occurred, now, duration)).rowcount
        if inserted and event_type != 'app_error':
            day = datetime.fromtimestamp(occurred, timezone.utc).date().isoformat()
            started, completed = int(event_type.endswith('_started')), int(event_type.endswith('_completed'))
            c.execute('INSERT INTO usage_daily VALUES(?,?,?,?,?,?) ON CONFLICT(day,classroom_id,mode) DO UPDATE SET started=usage_daily.started+?,completed=usage_daily.completed+?,duration_seconds=usage_daily.duration_seconds+?', (day, room['id'], mode, started, completed, duration if completed else 0, started, completed, duration if completed else 0))
        if inserted and event_type == 'app_error':
            code = item.get('errorCode')
            if code not in ERROR_CODES:
                reject(400, 'private_payload_rejected', 'Use a known error category, not a message or stack trace')
            c.execute('INSERT INTO error_events VALUES(?,?,?,?,?)', (uid(), device['id'], room['id'], code, occurred))
            c.execute('UPDATE devices SET last_error=? WHERE id=?', (code, device['id']))
            count = c.execute('SELECT COUNT(*) AS n FROM error_events WHERE device_id=? AND at>?', (device['id'], now - 1800)).fetchone()['n']
            rule = c.execute('SELECT error_threshold FROM alert_rules WHERE school_id=?', (room['school_id'],)).fetchone()
            if count >= (rule['error_threshold'] if rule else 3):
                alert(c, 'repeated_app_errors', f'errors:{device["id"]}:{int(now // 1800)}', room['school_id'], room['id'], device['id'])
        acknowledged.append(event_id)
    c.execute('UPDATE system_state SET revision=revision+1 WHERE id=1')
    return {'acknowledged': acknowledged}


def event_stream(headers):
    previous = None
    while True:
        try:
            with connection() as c:
                user, _ = authenticate(c, headers)
                body = snapshot(c, user)
            raw = json.dumps(body, separators=(',', ':'), sort_keys=True)
            signature = digest(raw)
            if signature != previous:
                yield f'event: snapshot\nid: {body["revision"]}\ndata: {raw}\n\n'.encode()
                previous = signature
            else:
                yield b': keepalive\n\n'
        except APIError as error:
            yield ('event: auth_required\ndata: ' + json.dumps({'code': error.code}) + '\n\n').encode()
            return
        except Exception:
            # Once SSE headers have been sent, terminate cleanly and let the
            # client reconnect. Never expose database errors in event payloads.
            yield b'event: service_unavailable\ndata: {"code":"server_error"}\n\n'
            return
        time.sleep(SSE_INTERVAL)


class Handler(BaseHTTPRequestHandler):
    protocol_version = 'HTTP/1.1'

    def log_message(self, *args):
        pass  # No passwords, tokens, request bodies or child data in access logs.

    def response_headers(self, code, cookies=(), streaming=False, length=None):
        self.send_response(code)
        origin = self.headers.get('Origin')
        if origin in allowed_origins():
            self.send_header('Access-Control-Allow-Origin', origin)
            self.send_header('Access-Control-Allow-Credentials', 'true')
        self.send_header('Vary', 'Origin')
        self.send_header('Cache-Control', 'no-store')
        self.send_header('X-Content-Type-Options', 'nosniff')
        self.send_header('Content-Type', 'text/event-stream' if streaming else 'application/json; charset=utf-8')
        if streaming:
            self.send_header('X-Accel-Buffering', 'no')
            self.send_header('Connection', 'close')
        elif length is not None:
            self.send_header('Content-Length', str(length))
        for value in cookies:
            self.send_header('Set-Cookie', value)
        self.end_headers()

    def send(self, code, body, cookies=()):
        raw = json.dumps(body).encode()
        self.response_headers(code, cookies, length=len(raw))
        self.wfile.write(raw)

    def do_OPTIONS(self):
        if self.headers.get('Origin') not in allowed_origins():
            return self.send(403, {'error': 'Origin not allowed'})
        self.send_response(204)
        self.send_header('Access-Control-Allow-Origin', self.headers['Origin'])
        self.send_header('Access-Control-Allow-Credentials', 'true')
        self.send_header('Access-Control-Allow-Headers', 'Authorization,Content-Type,X-Installation-ID')
        self.send_header('Access-Control-Allow-Methods', 'GET,POST,PATCH,OPTIONS')
        self.send_header('Content-Length', '0')
        self.send_header('Vary', 'Origin')
        self.end_headers()

    def do_GET(self):
        self.handle_api()

    def do_POST(self):
        self.handle_api()

    def do_PATCH(self):
        self.handle_api()

    def handle_api(self):
        try:
            size = int(self.headers.get('Content-Length', '0'))
            if size < 0 or size > 131072:
                return self.send(413, {'error': 'Request too large', 'code': 'request_too_large'})
            body = json.loads(self.rfile.read(size) or b'{}') if size else {}
            headers = dict(self.headers)
            headers['X-Ganit-Request-IP'] = self.client_address[0]
            code, result, cookies = execute(self.command, self.path, headers, body)
            if result is None:
                self.response_headers(200, streaming=True)
                for frame in event_stream(dict(self.headers)):
                    self.wfile.write(frame)
                    self.wfile.flush()
                self.close_connection = True
            else:
                self.send(code, result, cookies)
        except APIError as error:
            self.send(error.status, {'error': error.message, 'code': error.code})
        except (ValueError, KeyError, TypeError, json.JSONDecodeError):
            self.send(400, {'error': 'Check required fields and values', 'code': 'invalid_request'})
        except (BrokenPipeError, ConnectionResetError):
            self.close_connection = True
        except Exception as error:
            if 'Integrity' in type(error).__name__ or 'UniqueViolation' in type(error).__name__:
                self.send(409, {'error': 'Record already exists or relationship is invalid', 'code': 'conflict'})
            else:
                self.send(500, {'error': 'Management service error', 'code': 'server_error'})


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--create-user')
    parser.add_argument('--name', default='Administrator')
    parser.add_argument('--role', choices=sorted(ROLES | {'admin'}), default='super_admin')
    parser.add_argument('--port', type=int, default=8787)
    args = parser.parse_args()
    init()
    if args.create_user:
        import getpass
        create_user(args.create_user, args.name, args.role, getpass.getpass('Password (12+ characters): '))
    else:
        if ENV == 'production':
            raise SystemExit('Use Gunicorn server.wsgi behind the configured HTTPS proxy in production')
        server = ThreadingHTTPServer(('127.0.0.1', args.port), Handler)
        server.daemon_threads = True
        print(f'Management API (local development): http://127.0.0.1:{args.port}', flush=True)
        server.serve_forever()
