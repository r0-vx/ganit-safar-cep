#!/usr/bin/env python3
"""Package only compiled assets and allowlisted API source; never local data."""
import argparse
import json
import shutil
from pathlib import Path

root = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser()
parser.add_argument('--web-build', default='build/production-web')
parser.add_argument('--output', required=True)
parser.add_argument('--project-id', required=True)
args = parser.parse_args()
out = (root / args.output).resolve()
if root / 'build' not in out.parents:
    raise SystemExit('Package output must be inside build/')
out.mkdir(parents=True, exist_ok=True)
shutil.copytree(root / args.web_build, out / 'public', dirs_exist_ok=True,
                ignore=shutil.ignore_patterns('.vercel', 'vercel.json', '.last_build_id'))
(out / 'api').mkdir(exist_ok=True)
(out / 'api/index.py').write_text('import os, sys\nsys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "server"))\nfrom wsgi import application as app\n')
(out / 'server').mkdir(exist_ok=True)
for name in ['app.py', 'database.py', 'wsgi.py', 'ca-certificates.crt']:
    shutil.copyfile(root / 'server' / name, out / 'server' / name)
shutil.copytree(root / 'server/migrations', out / 'server/migrations', dirs_exist_ok=True)
shutil.copyfile(root / 'server/requirements.lock', out / 'requirements.txt')
(out / '.python-version').write_text('3.12\n')
config = {
    '$schema': 'https://openapi.vercel.sh/vercel.json',
    'framework': None, 'buildCommand': None, 'installCommand': None,
    'outputDirectory': 'public',
    'functions': {'api/index.py': {'maxDuration': 30, 'includeFiles': 'server/**'}},
    'headers': [{'source': '/(.*)', 'headers': [
        {'key': 'X-Content-Type-Options', 'value': 'nosniff'},
        {'key': 'Referrer-Policy', 'value': 'strict-origin-when-cross-origin'}]}],
    'rewrites': [
        {'source': '/api/:path*', 'destination': '/api/index?ganit_path=:path*'},
        {'source': '/(.*)', 'destination': '/index.html'}]
}
(out / 'vercel.json').write_text(json.dumps(config, indent=2) + '\n')
(out / '.vercel').mkdir(exist_ok=True)
(out / '.vercel/project.json').write_text(json.dumps({'projectId': args.project_id, 'orgId': 'team_8lr39odAfdz4mzO5zjuXak98'}))
print('Packaged', out)
