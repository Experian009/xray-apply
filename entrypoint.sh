#!/bin/sh
set -eu

PORT="${PORT:-8080}"
WS_PATH="${WS_PATH:-/vless}"

if [ -z "${UUID:-}" ]; then
  echo "ERROR: environment variable UUID is not set." >&2
  echo "Generate one, e.g.:  uuidgen   (or: cat /proc/sys/kernel/random/uuid)" >&2
  echo "Then set UUID in the Apply.build dashboard -> Service -> Environment variables." >&2
  exit 1
fi

export PORT WS_PATH UUID
envsubst '${PORT} ${WS_PATH} ${UUID}' < /etc/xray/config.json.tmpl > /etc/xray/config.json

echo "Starting Xray: VLESS+WS on 0.0.0.0:${PORT}, ws path ${WS_PATH}"
exec /usr/local/bin/xray run -c /etc/xray/config.json
