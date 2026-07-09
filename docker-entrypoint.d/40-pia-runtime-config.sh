#!/bin/sh
# Generate the runtime config the SPA reads at startup (assets/config.json)
# from env vars, using the envsubst that ships with the nginx image.
# Runs automatically via the nginx image's /docker-entrypoint.d/ mechanism.
set -e

HTML_DIR="${PIA_HTML_DIR:-/usr/share/nginx/html}"
TEMPLATE="$HTML_DIR/assets/config.template.json"
CONFIG="$HTML_DIR/assets/config.json"

if [ ! -f "$TEMPLATE" ]; then
  echo "[pia] $TEMPLATE not found; skipping runtime config generation"
  exit 0
fi

export SERVER_URL="${SERVER_URL:-}"
export CLIENT_ID="${CLIENT_ID:-}"
export CLIENT_SECRET="${CLIENT_SECRET:-}"

# Only substitute our known variables so nothing else in the file is touched.
envsubst '${SERVER_URL} ${CLIENT_ID} ${CLIENT_SECRET}' < "$TEMPLATE" > "$CONFIG"

echo "[pia] wrote $CONFIG (SERVER_URL=${SERVER_URL:-<empty>}, CLIENT_ID set: $([ -n "$CLIENT_ID" ] && echo yes || echo no))"
