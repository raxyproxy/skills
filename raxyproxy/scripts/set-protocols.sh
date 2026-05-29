#!/usr/bin/env bash
set -euo pipefail

PACKAGE_ID="${1:?Usage: set-protocols.sh <package_id> <http|socks5|http,socks5>}"
PROTOCOLS="${2:?Usage: set-protocols.sh <package_id> <http|socks5|http,socks5>}"

if [ -z "${RAXYPROXY_API_KEY:-}" ]; then
  echo "Error: RAXYPROXY_API_KEY is not set." >&2
  exit 1
fi

# Build JSON array: http,socks5 -> ["http","socks5"]
JSON_ARR=$(echo "$PROTOCOLS" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read().strip().split(',')))")

curl -sf -X PATCH "https://raxyproxy.com/api/v1/packages/${PACKAGE_ID}/protocols" \
  -H "Authorization: Bearer ${RAXYPROXY_API_KEY}" \
  -H "Content-Type: application/json" \
  -d "{\"protocols\":${JSON_ARR}}" | \
python3 -c "
import json, sys
d = json.load(sys.stdin)['data']
print('Active protocols:', ', '.join(d['protocols']))
"
