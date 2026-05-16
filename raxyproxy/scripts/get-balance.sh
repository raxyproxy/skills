#!/usr/bin/env bash
set -euo pipefail

if [ -z "${RAXYPROXY_API_KEY:-}" ]; then
  echo "Error: RAXYPROXY_API_KEY is not set." >&2
  echo "Run: export RAXYPROXY_API_KEY='raxy_...'" >&2
  echo "Get your key at: https://raxyproxy.com/app/api-keys" >&2
  exit 1
fi

curl -sf "https://raxyproxy.com/api/v1/account" \
  -H "Authorization: Bearer ${RAXYPROXY_API_KEY}" | \
python3 -c "
import json, sys
d = json.load(sys.stdin)['data']
print(f\"Account : {d['email']}\")
print(f\"Balance : \${d['balance_usd']:.2f} USD\")
"
