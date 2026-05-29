#!/usr/bin/env bash
set -euo pipefail

PACKAGE_ID="${1:?Usage: get-stats.sh <package_id> [period=30d] [aggregate=day]}"
PERIOD="${2:-30d}"
AGGREGATE="${3:-day}"

if [ -z "${RAXYPROXY_API_KEY:-}" ]; then
  echo "Error: RAXYPROXY_API_KEY is not set." >&2
  exit 1
fi

curl -sf "https://raxyproxy.com/api/v1/packages/${PACKAGE_ID}/stats?period=${PERIOD}&aggregate=${AGGREGATE}" \
  -H "Authorization: Bearer ${RAXYPROXY_API_KEY}" | \
python3 -c "
import json, sys
d = json.load(sys.stdin)['data']
print(f\"Period {d['period']} (aggregate={d['aggregate']})\")
print(f\"Used    : {d['used_gb']:.4f} / {d['quota_gb']:.4f} GB ({d['usage_pct']:.1f}%)\")
print(f\"Available: {d['available_gb']:.4f} GB\")
print()
for b in d['history']:
    print(f\"  {b['datetime']:>22}  {b['traffic_gb']:>10.6f} GB  {b['requests']:>10} req\")
"
