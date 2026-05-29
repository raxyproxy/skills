#!/usr/bin/env bash
set -euo pipefail

TYPE="${1:?Usage: list-locations.sh <countries|states|cities|zipcodes|asns> <pool_type> [countries=us[,gb]] [states=california[,texas]]}"
POOL_TYPE="${2:?Usage: list-locations.sh <countries|states|cities|zipcodes|asns> <pool_type> [countries] [states]}"
COUNTRIES="${3:-}"
STATES="${4:-}"

if [ -z "${RAXYPROXY_API_KEY:-}" ]; then
  echo "Error: RAXYPROXY_API_KEY is not set." >&2
  exit 1
fi

case "$TYPE" in
  countries|states|cities|zipcodes|asns) ;;
  *)
    echo "Unknown type: $TYPE (expected countries|states|cities|zipcodes|asns)" >&2
    exit 1
    ;;
esac

URL="https://raxyproxy.com/api/v1/locations/${TYPE}?pool_type=${POOL_TYPE}"
[ -n "$COUNTRIES" ] && URL="${URL}&countries=${COUNTRIES}"
[ -n "$STATES" ]    && URL="${URL}&states=${STATES}"

curl -sf "$URL" -H "Authorization: Bearer ${RAXYPROXY_API_KEY}" | \
python3 -c "
import json, sys
d = json.load(sys.stdin)['data']
print(f\"{d['type']} for pool_type={d['pool_type']} (filters={d['filters']}) — {d['count']} entries\")
print()
for item in d['items']:
    code = item.get('code', '')
    name = item.get('name', '')
    cnt  = item.get('count', 0)
    print(f\"  {code:<15} {name:<35} pool={cnt:,}\")
"
