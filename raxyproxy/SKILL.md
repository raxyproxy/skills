---
name: raxyproxy
description: Generate and use RaxyProxy residential, mobile, and datacenter proxies in your AI workflows. Use this skill whenever you need to scrape websites, bypass IP rate limits, collect geo-specific data, test content from different countries, or verify ads and pricing across regions. Requires RAXYPROXY_API_KEY environment variable.
allowed-tools: Bash(curl:*) Bash(bash:*) Bash(python3:*)
---

# RaxyProxy Proxy Manager

RaxyProxy provides residential, mobile, and datacenter proxies across 195+ countries via HTTP/HTTPS and SOCKS5.

## Setup check

```!
[ -n "$RAXYPROXY_API_KEY" ] && echo "✓ API key configured" || echo "✗ RAXYPROXY_API_KEY is not set — run: export RAXYPROXY_API_KEY='raxy_...'"
```

## List your proxy packages

Run this first to get your package IDs:

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/list-packages.sh
```

## Get proxy strings

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
# 20 US proxies, HTTP, rotating
bash ${CLAUDE_SKILL_DIR}/scripts/get-proxies.sh 42 20 us

# 5 sticky proxies from UK and Germany, SOCKS5
bash ${CLAUDE_SKILL_DIR}/scripts/get-proxies.sh 42 5 gb,de sticky socks5

# 50 proxies, no geo filter
bash ${CLAUDE_SKILL_DIR}/scripts/get-proxies.sh 42 50
```

Output format: `login:password@proxy.raxyproxy.com:823` (one per line)

## Check balance

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/get-balance.sh
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

## Geo-targeting (append to username with __)

```
LOGIN__cr.us              → US only
LOGIN__cr.us,gb,de        → US, UK, Germany
LOGIN__nocr.cn,ru         → exclude China, Russia
LOGIN__cr.us;state.texas  → US, Texas (2× billing)
LOGIN__cr.us;city.newyork → US, New York City (2× billing)
LOGIN__cr.us;zip.10001    → specific ZIP code (2× billing)
```

Note: State/city/zip/ASN targeting costs 2× traffic on Residential, Mobile, and Datacenter.
Premium Residential has no 2× surcharge at any targeting level.

## Sticky sessions (same IP across requests)

```bash
# Port-based: same IP as long as you reuse the same port (10000–20000)
curl -x http://LOGIN:PASS@proxy.raxyproxy.com:10001 https://target.com

# Session ID: same IP for ~30 min (or custom TTL)
curl -x "http://LOGIN__sessid.my-session-1:PASS@proxy.raxyproxy.com:823" https://target.com
```

## Proxy types

| Type | Price | Best for |
|------|-------|----------|
| `residential` | from $1.69/GB | Sites with bot detection |
| `mobile` | from $3.99/GB | Mobile-gated content, carrier-specific |
| `datacenter` | from $0.79/GB | Public APIs, high-volume pipelines |
| `residential_premium` | from $6.90/GB | Maximum reliability, no geo surcharge |

## Ports

- HTTP rotating: `823`
- SOCKS5 rotating: `824`
- Sticky (port-based): `10000–20000`
