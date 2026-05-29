#!/usr/bin/env bash
set -euo pipefail

PACKAGE_ID="${1:?Usage: rotate-password.sh <package_id>}"

if [ -z "${RAXYPROXY_API_KEY:-}" ]; then
  echo "Error: RAXYPROXY_API_KEY is not set." >&2
  echo "Run: export RAXYPROXY_API_KEY='raxy_...'" >&2
  exit 1
fi

curl -sf -X POST "https://raxyproxy.com/api/v1/packages/${PACKAGE_ID}/rotate-password" \
  -H "Authorization: Bearer ${RAXYPROXY_API_KEY}" | \
python3 -c "
import json, sys
d = json.load(sys.stdin)['data']
print(f\"New password : {d['password']}\")
print(f\"Rotated at   : {d['rotated_at']}\")
print()
print('WARNING: all clients using the old password are now disconnected.')
"
