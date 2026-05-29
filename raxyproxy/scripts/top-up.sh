#!/usr/bin/env bash
set -euo pipefail

PACKAGE_ID="${1:?Usage: top-up.sh <package_id> <quantity_gb>}"
GB="${2:?Usage: top-up.sh <package_id> <quantity_gb>}"

if [ -z "${RAXYPROXY_API_KEY:-}" ]; then
  echo "Error: RAXYPROXY_API_KEY is not set." >&2
  exit 1
fi

HTTP=$(curl -s -o /tmp/raxy_topup_resp.json -w "%{http_code}" \
  -X POST "https://raxyproxy.com/api/v1/packages/${PACKAGE_ID}/top-up" \
  -H "Authorization: Bearer ${RAXYPROXY_API_KEY}" \
  -H "Content-Type: application/json" \
  -d "{\"quantity_gb\":${GB}}")

if [ "$HTTP" = "402" ]; then
  echo "Insufficient wallet balance. Top up your wallet at https://raxyproxy.com/app/billing"
  exit 2
fi

if [ "$HTTP" != "200" ]; then
  echo "Top-up failed (HTTP ${HTTP}):"
  cat /tmp/raxy_topup_resp.json
  rm -f /tmp/raxy_topup_resp.json
  exit 1
fi

python3 -c "
import json
d = json.load(open('/tmp/raxy_topup_resp.json'))['data']
print(f\"Added {d['traffic_added_gb']} GB.\")
print(f\"New quota   : {d['new_quota_gb']} GB\")
print(f\"Charged USD : {d['amount_charged_usd']}\")
print(f\"Balance USD : {d['balance_usd']}\")
"
rm -f /tmp/raxy_topup_resp.json
