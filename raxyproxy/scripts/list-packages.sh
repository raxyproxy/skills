#!/usr/bin/env bash
set -euo pipefail

if [ -z "${RAXYPROXY_API_KEY:-}" ]; then
  echo "Error: RAXYPROXY_API_KEY is not set." >&2
  echo "Run: export RAXYPROXY_API_KEY='raxy_...'" >&2
  echo "Get your key at: https://raxyproxy.com/app/api-keys" >&2
  exit 1
fi

curl -sf "https://raxyproxy.com/api/v1/packages" \
  -H "Authorization: Bearer ${RAXYPROXY_API_KEY}" | \
python3 - <<'EOF'
import json, sys

raw = sys.stdin.read()
pkgs = json.loads(raw).get("data", [])

if not pkgs:
    print("No packages found.")
    sys.exit(0)

print(f"{'ID':<6} {'Type':<22} {'Status':<10} {'Available':<12} {'Name'}")
print("-" * 70)
for p in pkgs:
    avail = f"{float(p.get('available_gb', 0)):.2f} GB"
    print(f"{p['id']:<6} {p['type']:<22} {p['status']:<10} {avail:<12} {p['name']}")
EOF
