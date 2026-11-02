"""Production WSGI transport; domain/auth logic stays in app.py."""
import json
import ipaddress
import os
import sys
import threading

from flask import Flask, Response, request, stream_with_context

sys.path.insert(0, os.path.dirname(__file__))
import app as domain

application = Flask(__name__)
application.config['MAX_CONTENT_LENGTH'] = 131072
_ready = False
_ready_lock = threading.Lock()

def ensure_ready():
    global _ready
    with _ready_lock:
        if not _ready:
            domain.init()
            _ready = True

if not os.environ.get('VERCEL'):
    ensure_ready()

def scoped_stream(headers, presentation):
    with domain.dataset(presentation):
        yield from domain.event_stream(headers)


@application.route('/', defaults={'path': ''}, methods=['GET', 'POST', 'PATCH', 'OPTIONS'])
@application.route('/<path:path>', methods=['GET', 'POST', 'PATCH', 'OPTIONS'])
def route(path):
    path = request.args.get('ganit_path', path)
    if path.startswith('api/'):
        path = path[4:]
    presentation = path == 'presentation' or path.startswith('presentation/')
    if presentation:
        path = path[len('presentation'):].lstrip('/')
    origin = request.headers.get('Origin')
    headers = dict(request.headers)
    try:
        if os.environ.get('VERCEL') and not domain.DATABASE_URL:
            return Response(json.dumps({'code': 'service_not_configured', 'error': 'Hosted database setup is pending. No demo data is substituted.'}), status=503, content_type='application/json', headers={'Cache-Control': 'no-store'})
        if presentation:
            domain.reject(404,'not_found','This sign-in environment is no longer available')
        ensure_ready()
        peer = request.remote_addr or ''
        secure_proxy = False
        if domain.ENV == 'production':
            try:
                secure_proxy = any(ipaddress.ip_address(peer) in ipaddress.ip_network(value.strip()) for value in os.environ.get('GANIT_TRUSTED_PROXY_CIDRS', '').split(',') if value.strip())
            except ValueError:
                pass
            if os.environ.get('VERCEL') == '1':
                # The platform terminates TLS; additionally require an approved
                # deployment host. This branch is never enabled on our VM host.
                secure_proxy = ('https://' + request.host) in domain.allowed_origins()
            if not secure_proxy or request.headers.get('X-Forwarded-Proto') != 'https':
                domain.reject(400, 'https_required', 'Use the approved HTTPS proxy')
        headers['X-Forwarded-Proto'] = 'https' if secure_proxy else request.scheme
        # Only the trusted proxy may supply the original address. Never trust
        # browser-supplied forwarding headers on the loopback development server.
        forwarded = request.headers.get('X-Forwarded-For', '').split(',')[-1].strip()
        headers['X-Ganit-Request-IP'] = forwarded if secure_proxy and forwarded else peer
        if request.content_length and request.content_length > 131072:
            domain.reject(413, 'request_too_large', 'Request too large')
        if request.method == 'OPTIONS':
            if origin not in domain.allowed_origins():
                domain.reject(403, 'origin_rejected', 'Origin is not allowed')
            response = Response(status=204)
            response.headers['Access-Control-Allow-Headers'] = 'Authorization,Content-Type,X-Installation-ID'
            response.headers['Access-Control-Allow-Methods'] = 'GET,POST,PATCH,OPTIONS'
        else:
            body = request.get_json(silent=True) if request.content_length else {}
            with domain.dataset(presentation):
                code, result, cookies = domain.execute(request.method, '/' + path, headers, body)
            if result is None:
                response = Response(stream_with_context(scoped_stream(headers, presentation)), content_type='text/event-stream')
                response.headers['X-Accel-Buffering'] = 'no'
            else:
                response = Response(json.dumps(result), status=code, content_type='application/json')
            for value in cookies:
                response.headers.add('Set-Cookie', value)
    except domain.APIError as error:
        response = Response(json.dumps({'error': error.message, 'code': error.code}), status=error.status, content_type='application/json')
    except (ValueError, TypeError, KeyError):
        response = Response(json.dumps({'error': 'Check required fields', 'code': 'invalid_request'}), status=400, content_type='application/json')
    except Exception as error:
        conflict = 'Integrity' in type(error).__name__ or 'UniqueViolation' in type(error).__name__
        response = Response(json.dumps({'error': 'Record conflict' if conflict else 'Management service error', 'code': 'conflict' if conflict else 'server_error'}), status=409 if conflict else 500, content_type='application/json')
    if origin in domain.allowed_origins():
        response.headers['Access-Control-Allow-Origin'] = origin
        response.headers['Access-Control-Allow-Credentials'] = 'true'
    response.headers['Vary'] = 'Origin'
    response.headers['Cache-Control'] = 'no-store'
    response.headers['X-Content-Type-Options'] = 'nosniff'
    return response
