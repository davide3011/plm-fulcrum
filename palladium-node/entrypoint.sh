#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="/root/.palladium"
CONFIG_FILE="$CONFIG_DIR/palladium.conf"
TEMPLATE="/palladium-node/config/palladium.conf.template"

mkdir -p "$CONFIG_DIR"

# Validate required variables before rendering
: "${RPC_USER:?RPC_USER is not set. Copy .env.example to .env and fill in values.}"
: "${RPC_PASSWORD:?RPC_PASSWORD is not set. Copy .env.example to .env and fill in values.}"
: "${MAX_CONNECTIONS:=50}"

envsubst < "$TEMPLATE" > "$CONFIG_FILE"
chmod 600 "$CONFIG_FILE"

echo "[entrypoint] palladium.conf written to $CONFIG_FILE"
exec "$@"
