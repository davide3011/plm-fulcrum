#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="/data/fulcrum.conf"
TEMPLATE="/fulcrum-tpl/fulcrum-plm-docker.conf.template"

: "${RPC_USER:?RPC_USER is not set. Copy .env.example to .env and fill in values.}"
: "${RPC_PASSWORD:?RPC_PASSWORD is not set. Copy .env.example to .env and fill in values.}"
: "${PUBLIC_HOST:?PUBLIC_HOST is not set. Set it to the public IP of this server in .env.}"

mkdir -p /data
envsubst < "$TEMPLATE" > "$CONFIG_FILE"
chmod 600 "$CONFIG_FILE"

echo "[entrypoint] fulcrum.conf written to $CONFIG_FILE"
exec "$@"
