#!/usr/bin/env bash
set -euo pipefail
flutter build web --release --no-web-resources-cdn
python3 -m http.server 8080 --directory build/web
