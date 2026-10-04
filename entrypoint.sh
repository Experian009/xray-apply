#!/bin/sh
set -eu

PORT="${PORT:-8080}"
WS_PATH="${WS_PATH:-/vless}"
# UUID зашит в образ по умолчанию; можно переопределить переменной окружения UUID
UUID="${UUID:-70ed0384-5330-4cfa-bd71-838fc4d083f5}"

export PORT WS_PATH UUID
envsubst '${PORT} ${WS_PATH} ${UUID}' < /etc/xray/config.json.tmpl > /etc/xray/config.json

echo "Starting Xray: VLESS+WS on 0.0.0.0:${PORT}, ws path ${WS_PATH}"
exec /usr/local/bin/xray run -c /etc/xray/config.json
