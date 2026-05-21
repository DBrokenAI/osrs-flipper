# OSRS Flipper

A single-file, zero-install Old School RuneScape Grand Exchange flipping dashboard. Live margins, multi-timeframe signals, volume surge detection, position tracking, slot allocation, and 90-day price anchoring — all from `prices.runescape.wiki` and Jagex's official endpoints.

No backend. No database. One HTML file.

## Features

**Strategy presets** — switch how the table ranks items based on what you're trying to do:

- 🎯 **Reliable** — stability-weighted gp/hr. Filters out volatile items, predictable fills.
- ⚡ **Max gp/hr** — raw expected hourly profit, original behavior.
- 📈 **Discount Hunter** — only items currently below their 24h average, ranked most-discounted first.
- 🔮 **Brewing Deals** — early-deal detection: discount + momentum + buyer pressure.
- 🚀 **Big Movers** — volume surge as leading indicator. Catches items where activity is heating up before the price has fully reacted.
- 💎 **Position Trades** — long-hold candidates at multi-month lows with technical reversal signals.

**Live signals on every row:**

- ⚡ Velocity chip — live tick-to-tick price slope from in-memory history
- 🔗 Multi-timeframe confirmation — when 5m + 1h + 24h + 24h-position all agree on direction
- 🚀 Volume surge chip — current hour vs 24h average pace
- 📈 Outlook chip — short-term trend direction
- vs 24h pill — discount/premium relative to recent average
- Stability score (0–100) with colored bar

**Money management:**

- 💼 **Cash + slot allocator** — type your bank, picks the best 8 (or 3 F2P) items to deploy capital across, sized for full 4-hour GE buy-limit cycles
- 📌 **Position tracker** — log buys, get live Net per item + total P&L + Sell/Hold/Cut verdict based on 24h history and break-even math
- ⭐ **Watchlist + alerts** — star items, set per-item Net targets, get browser notifications + ping sound when hit
- ⚠ Bond conversion fee (10%) automatically deducted from Net on bonds

**Specialized tabs:**

- 🪄 **Alching** — high-alch profit per cast, auto-derived from every item's `highalch` field with live nature rune price
- 🛡️ **Sets** — combine pieces vs decombine arbitrage across 14 known armor sets
- 🧪 **Decanting** — all dose conversions (4→3, 4→2, 4→1, 3→2, 3→1, 2→1), surfaces best ratio per potion family
- 🌿 **Herbs** — grimy → clean profit, auto-detected from item names

**Chart modal** for any item:

- Wiki real-time series (5m / 1h / 6h ranges)
- Horizontal reference lines: 24h average instabuy, 24h average instasell, your current Buy@
- 90-day average from Jagex's official `itemdb_oldschool` endpoint (independent of wiki API) for long-term context

**Tax + cut handling:**

- 2% GE tax (Jagex's current rate as of May 2025)
- Per-item exemption list (bonds, energy potions, food, teleport tabs, charged jewellery, tools)
- Configurable `Cut` (flat gp) + `Edge %` (percentage above market) with auto-cap at 1.5% of margin per side so bumps preserve ≥97% of raw margin

**View modes:**

- 💻 Desktop — full table, every column, dense
- 📱 Mobile — card-based stack, big tappable price pills, scrollable tabs, collapsible filters
- First-load picker detects your device and recommends; toggle button in header swaps anytime

**News feed:** pulls Jagex's OSRS news RSS, scans posts for item-name mentions, surfaces them as one-click chart chips. Helps you spot pre-update accumulation candidates.

## Quick start

### Option 1: GitHub Pages (recommended — public, free, HTTPS)

1. Push this repo to GitHub
2. Settings → Pages → deploy from `main` branch, root folder
3. Wait a minute, visit `https://YOUR-USERNAME.github.io/REPO-NAME/`
4. Done. Use from any device.

### Option 2: Local Windows (PowerShell)

```powershell
# In this folder:
powershell -ExecutionPolicy Bypass -File .\server.ps1
```

Or right-click `server.ps1` → **Run with PowerShell**. Browser auto-opens to `http://localhost:8080/`.

### Option 3: Local with Python

```bash
python -m http.server 8080
# then open http://localhost:8080
```

### Option 4: Local with Node

```bash
npx serve -p 8080
# then open http://localhost:8080
```

### ⚠ Why not just double-click the HTML file?

Browsers treat `file://` URLs as unique untrusted origins. CORS, clipboard, notifications, and some fetches are blocked. Use one of the methods above to get full functionality.

## Tech & data sources

| Source | What it provides |
|---|---|
| [prices.runescape.wiki](https://prices.runescape.wiki/) `/latest` | Real-time high/low + timestamps (1 min upstream cadence) |
| `/5m`, `/1h`, `/24h` | Rolling-window averages and volumes |
| `/mapping` | Item catalog with names, GE limits, high-alch, members flag, icons |
| `/timeseries` | Per-item historical candles for charts |
| [secure.runescape.com/m=itemdb_oldschool](https://secure.runescape.com) `/api/graph/{id}.json` | Jagex's official 180-day daily price history |
| [secure.runescape.com/m=news](https://secure.runescape.com) `/latest_news.rss?oldschool=true` | Official OSRS news RSS |
| [oldschool.runescape.wiki](https://oldschool.runescape.wiki) `/w/Special:Filepath/` | Item icons |

The wiki API + RuneLite partnership feeds back into Jagex's official trade data. All endpoints used here are public, free, and CORS-friendly (`corsproxy.io` fallback for Jagex's older endpoints when needed).

## Local data

Settings, watchlist, alert targets, and open positions persist to `localStorage` keyed at the page's origin. Switching devices or hosts means starting fresh. No data ever leaves your browser.

Polling cadence:

- `/latest` — every **6 seconds** (matches Flippr's pace)
- `/5m` — every 30 seconds
- `/1h` + `/24h` — every 60 seconds
- News RSS — once per hour
- Jagex 180-day — once per item, cached 24h, fetched lazily when you open a chart

## Limitations & honest caveats

- This tool **does not place offers in-game** — it only surfaces opportunities. Place your buy/sell orders yourself in the OSRS Grand Exchange.
- For live position tracking from your actual offers, install **[RuneLite](https://runelite.net) + the Flipping Utilities plugin**. This dashboard is the strategic/scoring layer; RuneLite handles in-game offer state with perfect accuracy.
- The wiki API updates ~once per minute upstream, so polling faster than ~10s returns cached data. The 6s default is for responsiveness on transitions, not extra freshness.
- The tax-exempt list is based on the current published Jagex/Wiki rules. If Jagex changes it, the list needs updating manually (in the `TAX_EXEMPT_NAMES` set near the top of the script section).

## License

MIT. See [LICENSE](./LICENSE).
