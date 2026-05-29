#!/usr/bin/env bash
set -euo pipefail

PACKAGE_ID="${1:?Usage: get-errors.sh <package_id> [period=7d] [limit=50]}"
PERIOD="${2:-7d}"
LIMIT="${3:-50}"

if [ -z "${RAXYPROXY_API_KEY:-}" ]; then
  echo "Error: RAXYPROXY_API_KEY is not set." >&2
  exit 1
fi

curl -sf "https://raxyproxy.com/api/v1/packages/${PACKAGE_ID}/stats/errors?period=${PERIOD}&limit=${LIMIT}" \
  -H "Authorization: Bearer ${RAXYPROXY_API_KEY}" | \
python3 -c "
import json, sys
d = json.load(sys.stdin)['data']
events = d.get('errors', [])
print(f\"{len(events)} error events over period={d['period']}\")
print()
for e in events:
    dt   = e.get('datetime', '')
    code = e.get('error', e.get('code', ''))
    host = e.get('host', '')
    n    = e.get('count', '')
    print(f\"  {dt}  {code:<22}  {host:<30}  {n}\")
"
