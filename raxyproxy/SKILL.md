---
name: raxyproxy
description: Generate and use RaxyProxy residential, mobile, and datacenter proxies in your AI workflows. Use this skill whenever you need to scrape websites, bypass IP rate limits, collect geo-specific data, test content from different countries, verify ads and pricing across regions, manage proxy package settings (whitelist, protocols, password rotation), check usage stats, or top up traffic. Requires RAXYPROXY_API_KEY environment variable.
allowed-tools: Bash(curl:*) Bash(bash:*) Bash(python3:*)
---

# RaxyProxy Proxy Manager

RaxyProxy provides residential, mobile, and datacenter proxies across 195+ countries via HTTP/HTTPS and SOCKS5. This skill manages packages, generates proxy strings with full geo + session targeting, and lets you tune package settings — all from the same CLI surface.

## Setup check

```!
[ -n "$RAXYPROXY_API_KEY" ] && echo "✓ API key configured" || echo "✗ RAXYPROXY_API_KEY is not set — run: export RAXYPROXY_API_KEY='raxy_...'"
```

Get your key at https://raxyproxy.com/app/api-keys

## Discover what you have

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/list-packages.sh   # list packages
bash ${CLAUDE_SKILL_DIR}/scripts/get-balance.sh     # wallet balance
```

## Generate proxy strings

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/get-proxies.sh <package_id> [quantity] [countries] [type] [protocol]
```

| Argument | Default | Description |
|----------|---------|-------------|
| `package_id` | required | From list-packages output |
| `quantity` | 10 | Number of proxies (1–1000) |
| `countries` | all | Comma-separated ISO codes: `us,gb,de` |
| `type` | rotating | `rotating` or `sticky` |
| `protocol` | http | `http` or `socks5` |

Examples:
```bash
bash ${CLAUDE_SKILL_DIR}/scripts/get-proxies.sh 42 20 us                 # 20 US rotating HTTP proxies
bash ${CLAUDE_SKILL_DIR}/scripts/get-proxies.sh 42 5 gb,de sticky socks5 # 5 sticky GB+DE SOCKS5
bash ${CLAUDE_SKILL_DIR}/scripts/get-proxies.sh 42 50                    # 50 rotating, any country
```

Output format: `login:password@proxy.raxyproxy.com:823` (one per line). Use the `format` query parameter for other shapes — see https://raxyproxy.com/docs/api/packages-proxies for the full list (e.g. `?format=host:port:user:pass`).

For richer query parameters (sessid, sessttl, anonymous, exclude_states, exclude_cities, exclude_zipcodes, exclude_asns) call the endpoint with curl directly — those control sticky-session strings and per-credential exclusions documented at `/docs/api/packages-proxies`.

## Discover available locations

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/list-locations.sh countries residential
bash ${CLAUDE_SKILL_DIR}/scripts/list-locations.sh states    residential us
bash ${CLAUDE_SKILL_DIR}/scripts/list-locations.sh cities    residential us california
bash ${CLAUDE_SKILL_DIR}/scripts/list-locations.sh zipcodes  residential us california
bash ${CLAUDE_SKILL_DIR}/scripts/list-locations.sh asns      residential us
```

Use the returned `code` values directly with `get-proxies.sh` or as `countries` / `states` / `cities` query params.

## Manage package settings

```bash
# Generate a new password (cuts off live clients using the old one)
bash ${CLAUDE_SKILL_DIR}/scripts/rotate-password.sh 42

# Cap concurrent TCP connections (1–2000)
bash ${CLAUDE_SKILL_DIR}/scripts/set-threads.sh 42 500

# Enable specific protocols (at least one must remain on)
bash ${CLAUDE_SKILL_DIR}/scripts/set-protocols.sh 42 http,socks5
bash ${CLAUDE_SKILL_DIR}/scripts/set-protocols.sh 42 http          # disables SOCKS5 (port 824)

# IP whitelist — when non-empty, password auth is disabled
bash ${CLAUDE_SKILL_DIR}/scripts/allowed-ips.sh list   42
bash ${CLAUDE_SKILL_DIR}/scripts/allowed-ips.sh add    42 203.0.113.7
bash ${CLAUDE_SKILL_DIR}/scripts/allowed-ips.sh remove 42 203.0.113.7
```

## Buy more traffic (top-up)

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/top-up.sh 42 25   # add 25 GB to package 42, charged from wallet balance
```

Returns exit code 2 (and a `Top up your wallet…` hint) when wallet balance is insufficient.

## Inspect usage

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/get-stats.sh      42 7d  hour     # week of hourly buckets
bash ${CLAUDE_SKILL_DIR}/scripts/get-host-usage.sh 42 30d 10       # top 10 destinations over 30 days
bash ${CLAUDE_SKILL_DIR}/scripts/get-errors.sh     42 7d  100      # recent error events per host & code
```

## Using proxies

### curl
```bash
curl -x "http://LOGIN:PASS@proxy.raxyproxy.com:823" https://target.com
# SOCKS5:
curl --socks5-hostname proxy.raxyproxy.com:824 -U LOGIN:PASS https://target.com
```

### Python (requests)
```python
proxy_str = "LOGIN:PASS@proxy.raxyproxy.com:823"
proxies = {"http": f"http://{proxy_str}", "https": f"http://{proxy_str}"}
resp = requests.get(url, proxies=proxies, timeout=30)
```

### Node.js (fetch with proxy-agent)
```javascript
import { ProxyAgent } from 'undici';
const dispatcher = new ProxyAgent('http://LOGIN:PASS@proxy.raxyproxy.com:823');
const resp = await fetch(url, { dispatcher });
```

### Playwright
```javascript
const browser = await chromium.launch();
const context = await browser.newContext({
    proxy: { server: 'http://proxy.raxyproxy.com:823', username: 'LOGIN', password: 'PASS' }
});
```

## Geo-targeting (append to username with `__`)

```
LOGIN__cr.us               → US only
LOGIN__cr.us,gb,de         → US, UK, Germany
LOGIN__nocr.cn,ru          → exclude China, Russia
LOGIN__cr.us;state.texas   → US, Texas (2× billing)
LOGIN__cr.us;city.newyork  → US, New York City (2× billing)
LOGIN__cr.us;zip.10001     → specific ZIP code (2× billing)
LOGIN__cr.us;nostate.california → US, excluding California (2× billing)
LOGIN__cr.us;asn.15169     → US, ASN 15169 only (2× billing)
LOGIN__cr.us;noasn.as20947 → US, excluding ASN 20947 (2× billing)
LOGIN__cr.us;anon.1        → US, anonymous exits only
```

State/city/zip/ASN targeting costs 2× traffic on Residential, Mobile, and Datacenter. **Premium Residential has no 2× surcharge at any targeting level.**

## Sticky sessions (same IP across requests)

```bash
# Port-based: same IP as long as you reuse the same port (10000–20000)
curl -x http://LOGIN:PASS@proxy.raxyproxy.com:10001 https://target.com

# sessid: same IP for ~30 min (or custom TTL via sessttl), standard rotating port
curl -x "http://LOGIN__sessid.worker-1:PASS@proxy.raxyproxy.com:823" https://target.com

# sessid + custom TTL (1–120 min)
curl -x "http://LOGIN__sessid.worker-1;sessttl.10:PASS@proxy.raxyproxy.com:823" https://target.com
```

## Proxy types

| Type | Price | Best for |
|------|-------|----------|
| `residential` | from $1.69/GB | Sites with bot detection |
| `mobile` | from $3.37/GB | Mobile-gated content, carrier-specific |
| `datacenter` | from $0.69/GB | Public APIs, high-volume pipelines |
| `residential_premium` | from $6.90/GB | Maximum reliability, no geo surcharge |

## Ports

- HTTP rotating: `823`
- SOCKS5 rotating: `824`
- Sticky (port-based): `10000–20000`
