#!/usr/bin/env bash
set -euo pipefail

ACTION="${1:?Usage: allowed-ips.sh <list|add|remove> <package_id> [ip]}"
PACKAGE_ID="${2:?Usage: allowed-ips.sh <list|add|remove> <package_id> [ip]}"
IP="${3:-}"

if [ -z "${RAXYPROXY_API_KEY:-}" ]; then
  echo "Error: RAXYPROXY_API_KEY is not set." >&2
  exit 1
fi

BASE="https://raxyproxy.com/api/v1/packages/${PACKAGE_ID}/allowed-ips"
AUTH="Authorization: Bearer ${RAXYPROXY_API_KEY}"

case "$ACTION" in
  list)
    curl -sf "$BASE" -H "$AUTH" | \
    python3 -c "
import json, sys
d = json.load(sys.stdin)['data']
ips = d.get('ips', [])
print(f\"{len(ips)} / {d.get('max', 5)} whitelisted IPs:\")
for ip in ips:
    print(f\"  {ip}\")
"
    ;;
  add)
    [ -z "$IP" ] && { echo "Error: IP required for 'add'."; exit 1; }
    curl -sf -X POST "$BASE" -H "$AUTH" -H "Content-Type: application/json" \
      -d "{\"ip\":\"${IP}\"}" | \
    python3 -c "
import json, sys
d = json.load(sys.stdin)['data']
print('Added. Whitelist now:', ', '.join(d['ips']))
"
    ;;
  remove)
    [ -z "$IP" ] && { echo "Error: IP required for 'remove'."; exit 1; }
    HTTP=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE "${BASE}/${IP}" -H "$AUTH")
    if [ "$HTTP" = "204" ]; then
      echo "Removed ${IP} from whitelist."
    else
      echo "Failed (HTTP ${HTTP})."
      exit 1
    fi
    ;;
  *)
    echo "Unknown action: $ACTION (expected list|add|remove)"
    exit 1
    ;;
esac
