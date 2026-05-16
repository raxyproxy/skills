#!/usr/bin/env bash
set -euo pipefail

PACKAGE_ID="${1:?Usage: get-proxies.sh <package_id> [quantity] [countries] [type] [protocol]}"
QUANTITY="${2:-10}"
COUNTRIES="${3:-}"
TYPE="${4:-rotating}"
PROTOCOL="${5:-http}"

if [ -z "${RAXYPROXY_API_KEY:-}" ]; then
  echo "Error: RAXYPROXY_API_KEY is not set." >&2
  echo "Run: export RAXYPROXY_API_KEY='raxy_...'" >&2
  echo "Get your key at: https://raxyproxy.com/app/api-keys" >&2
  exit 1
fi

URL="https://raxyproxy.com/api/v1/packages/${PACKAGE_ID}/proxies"
URL="${URL}?quantity=${QUANTITY}&type=${TYPE}&protocol=${PROTOCOL}"
[ -n "$COUNTRIES" ] && URL="${URL}&countries=${COUNTRIES}"

curl -sf "$URL" \
  -H "Authorization: Bearer ${RAXYPROXY_API_KEY}" \
  -H "Accept: text/plain"
