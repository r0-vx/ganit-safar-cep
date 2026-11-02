#!/usr/bin/env bash
set -euo pipefail
: "${GANIT_API_URL:?Set the public HTTPS API URL, including /api when using the supplied proxy}"
: "${GANIT_LEASE_PUBLIC_KEY:?Set the server Ed25519 public key, never its private signing key}"
if [[ "$GANIT_API_URL" != https://* && "$GANIT_API_URL" != /api ]]; then
  echo 'Production monitoring requires HTTPS or the same-origin /api route.' >&2
  exit 1
fi
"${FLUTTER_BIN:-flutter}" build web --release --no-web-resources-cdn --no-wasm-dry-run \
  --output build/production-web \
  --dart-define=GANIT_MANAGED=true \
  --dart-define="GANIT_API_URL=$GANIT_API_URL" \
  --dart-define="GANIT_LEASE_PUBLIC_KEY=$GANIT_LEASE_PUBLIC_KEY" \
  --dart-define="GANIT_MONITOR_POLL_SECONDS=${GANIT_MONITOR_POLL_SECONDS:-0}" \
  --dart-define=GANIT_APP_VERSION=1.2.0
