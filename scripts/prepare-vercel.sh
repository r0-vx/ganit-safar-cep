#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
flutter analyze
flutter test
flutter build web --release --no-web-resources-cdn --no-wasm-dry-run
cp deployment/vercel.json build/web/vercel.json
printf '.last_build_id\n' > build/web/.vercelignore
