#!/usr/bin/env bash
set -euo pipefail

PACKAGE_ID="${1:?Usage: get-host-usage.sh <package_id> [period=30d] [top=10]}"
PERIOD="${2:-30d}"
TOP="${3:-10}"

if [ -z "${RAXYPROXY_API_KEY:-}" ]; then
  echo "Error: RAXYPROXY_API_KEY is not set." >&2
  exit 1
fi

curl -sf "https://raxyproxy.com/api/v1/packages/${PACKAGE_ID}/stats/hosts?period=${PERIOD}&top=${TOP}" \
  -H "Authorization: Bearer ${RAXYPROXY_API_KEY}" | \
python3 -c "
import json, sys
d = json.load(sys.stdin)['data']
print(f\"Top {d['top']} destinations over period={d['period']}\")
print()
for h in d['hosts']:
    print(f\"  {h['host']:<35} {h['traffic_gb']:>10.6f} GB  {h['requests']:>10} req\")
"
