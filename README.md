# RaxyProxy Agent Skills

> Proxy superpowers for Claude Code, Cursor, Gemini CLI, Codex, and 40+ other AI agents.

---

## Install

```bash
npx skills add raxyproxy/skills
```

That's it. The skill `raxyproxy` is now available in your AI agent. Invoke it with `/raxyproxy`.

---

## Setup

Get your API key at [raxyproxy.com/app/api-keys](https://raxyproxy.com/app/api-keys) and set it in your environment:

```bash
export RAXYPROXY_API_KEY="raxy_..."
```

To make it permanent, add it to `~/.claude/settings.json`:

```json
{
  "env": {
    "RAXYPROXY_API_KEY": "raxy_..."
  }
}
```

---

## What it does

Once installed, your AI agent can:

- **Generate proxy strings** — rotating or sticky, HTTP or SOCKS5
- **Target any country** — 195+ countries, or exclude specific ones
- **Geo-target precisely** — by state, city, ZIP code, or ASN
- **List your packages** — see IDs, types, and remaining traffic
- **Check your balance** — account balance and email

---

## Try these prompts

**Web scraping**
```
Using RaxyProxy rotating IPs from the US and Germany, scrape these 200
product pages, extract prices and stock status, retry any 429s with a
fresh IP, and output a CSV.
```

**SEO monitoring**
```
Using RaxyProxy from the US, UK, DE, FR, and JP, pull Google top-10
results for these 15 keywords. Diff against last week's snapshot and
flag ranking changes over 3 positions.
```

**Price tracking**
```
Using RaxyProxy residential IPs from 10 countries, check these 50
product URLs on Amazon and flag price differences over 10% between
regions. Sort by largest gap.
```

**Ad verification**
```
Using RaxyProxy mobile IPs from the US, Brazil, and India, load these
8 landing pages and verify the Meta Pixel and GA4 tags fire with the
correct campaign IDs.
```

---

## Available skills

| Skill | Invocation | Description |
|-------|-----------|-------------|
| `raxyproxy` | `/raxyproxy` | Generate proxies, list packages, check balance |

---

## Proxy types

| Type | From | Best for |
|------|------|----------|
| Residential | $1.69/GB | Sites with bot detection |
| Mobile | $3.99/GB | Carrier-gated & mobile content |
| Datacenter | $0.79/GB | High-volume pipelines & public APIs |
| Premium Residential | $6.90/GB | Maximum reliability, no geo surcharge |

---

## Links

- [Documentation](https://raxyproxy.com/docs/for-ai)
- [API Keys](https://raxyproxy.com/app/api-keys)
- [Pricing](https://raxyproxy.com/pricing)
- [raxyproxy.com](https://raxyproxy.com)
