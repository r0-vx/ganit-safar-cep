#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
: "${GANIT_API_URL:=http://127.0.0.1:8787}"
flutter build web --release --no-web-resources-cdn --no-wasm-dry-run --output build/local-web --dart-define="GANIT_API_URL=$GANIT_API_URL"
python3 -m http.server 8080 --bind 127.0.0.1 --directory build/local-web
