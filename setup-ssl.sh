#!/usr/bin/env bash
set -euo pipefail

SSL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/ssl"
CERT="$SSL_DIR/fulcrum-plm.crt"
KEY="$SSL_DIR/fulcrum-plm.key"

mkdir -p "$SSL_DIR"

if [[ -f "$CERT" && -f "$KEY" ]]; then
    echo "SSL certificate already exists — skipping generation."
    echo "  cert: $CERT"
    echo "  key:  $KEY"
    openssl x509 -in "$CERT" -noout -subject -dates
    exit 0
fi

echo "Generating self-signed SSL certificate (RSA-4096, valid 10 years) ..."
openssl req -x509 -newkey rsa:4096 \
    -keyout "$KEY" \
    -out    "$CERT" \
    -days 3650 -nodes \
    -subj "/CN=plm-fulcrum"

chmod 600 "$KEY"

echo "Done."
echo "  cert: $CERT"
echo "  key:  $KEY"
