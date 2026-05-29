#!/usr/bin/env bash
set -euo pipefail

PACKAGE_ID="${1:?Usage: set-threads.sh <package_id> <threads 1-2000>}"
THREADS="${2:?Usage: set-threads.sh <package_id> <threads 1-2000>}"

if [ -z "${RAXYPROXY_API_KEY:-}" ]; then
  echo "Error: RAXYPROXY_API_KEY is not set." >&2
  exit 1
fi

curl -sf -X PATCH "https://raxyproxy.com/api/v1/packages/${PACKAGE_ID}/threads" \
  -H "Authorization: Bearer ${RAXYPROXY_API_KEY}" \
  -H "Content-Type: application/json" \
  -d "{\"threads\":${THREADS}}" | \
python3 -c "
import json, sys
d = json.load(sys.stdin)['data']
print(f\"Max concurrent connections: {d['threads']}\")
"
