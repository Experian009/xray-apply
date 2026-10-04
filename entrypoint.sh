#!/bin/sh
set -eu

PORT="${PORT:-8080}"
XRAY_PORT="${XRAY_PORT:-8081}"
WS_PATH="${WS_PATH:-/vless}"
# UUID зашит в образ по умолчанию; можно переопределить переменной окружения UUID
UUID="${UUID:-70ed0384-5330-4cfa-bd71-838fc4d083f5}"

export PORT XRAY_PORT WS_PATH UUID

# Xray слушает только localhost — наружу его проксирует nginx
envsubst '${XRAY_PORT} ${WS_PATH} ${UUID}' < /etc/xray/config.json.tmpl > /etc/xray/config.json
# nginx: ${PORT} наружу; / -> сайт с котиком (и health check), /vless -> Xray
envsubst '${PORT} ${XRAY_PORT}' < /etc/nginx/nginx.conf.tmpl > /etc/nginx/nginx.conf

mkdir -p /run/nginx
nginx -t -q
echo "Starting nginx on 0.0.0.0:${PORT} (site: /, VLESS+WS: /vless -> 127.0.0.1:${XRAY_PORT})"
nginx
echo "Starting Xray: VLESS+WS on 127.0.0.1:${XRAY_PORT}, ws path ${WS_PATH}"
exec /usr/local/bin/xray run -c /etc/xray/config.json
