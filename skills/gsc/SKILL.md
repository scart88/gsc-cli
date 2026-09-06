---
name: gsc
description: Automates Google Search Console, Google Indexing API, live URL index inspection, sitemap batch submission, and search ranking analytics (queries, impressions, positions, CTR). Trigger whenever checking SEO rankings, inspecting Google indexing status, analyzing search impressions/clicks, or notifying Googlebot of new/updated pages.
---

# Google Search Console & Indexing API (GSC CLI) Agent Skill

This skill allows AI agents (Google Antigravity, Claude Code, Cursor, Codex, etc.) to programmatically interact with Google Search Console and the Google Indexing API using the `gsc` CLI tool.

## Key Capabilities
- **Search Analytics**: Query real keyword rankings, impressions, clicks, CTR, and average SERP positions.
- **Growth Intelligence**: Uncover striking-distance Page 2 opportunities, CTR underperformers, and keyword cannibalization conflicts.
- **Trend & Decay Analysis**: 28-day period-over-period decay detection (decaying, surging, new, lost).
- **Crawl Optimization**: Scan sitemaps for 90-day zero-impression zombie pages wasting crawl budget.
- **Instant Googlebot Indexing**: Ping Google's Indexing API with `URL_UPDATED` or `URL_DELETED` to trigger immediate crawling.
- **Live URL Inspection**: Query Search Console API for actual index status (`PASS`, coverage state, canonical assigned by Google, crawl date).
- **Bulk Sitemap Audit**: Inspect entire XML sitemaps to identify indexed vs queued URLs.
- **Multi-domain Management**: Easily view or switch active domains across projects.

---

## Agent Rule: Always Use `--json` Flag
When running `gsc` commands from agent tools (`run_command`), **always append `--json`** to receive clean, machine-readable JSON output instead of ANSI terminal formatting:

```bash
gsc top-queries --json
gsc opportunities --json
gsc inspect https://example.com/page --json
gsc performance --days 30 --json
```

---

## Common Agent Workflows

### 1. Analyzing Keyword Rankings & Opportunities
When the user asks about traffic, rankings, or keyword performance:
```bash
# Get top 20 queries for the active domain (sorted by impressions)
gsc top-queries -s imp --limit 20 --json

# Find highest-ranking queries (page 1 rankings, pos ascending)
gsc top-queries -s pos --limit 20 --json

# Find striking-distance opportunities (Page 2 keywords to push to Top 3)
gsc opportunities --min-imp 10 --json

# Find Top 10 queries with low CTR (easy title tag rewrites)
gsc underperformers --json

# Detect multiple URLs competing for the same search query
gsc cannibalization --json

# Detect traffic drops and ranking decay
gsc decay --json
```
**Interpretation Advice**:
- Sort queries by impressions to find high-volume search terms.
- Striking-distance keywords (position 7–20 with high impressions) are prime candidates for on-page content expansion to push them into Top 3.
- CTR underperformers already rank on Page 1—simply rewrite their `<title>` and meta description with emotional hooks or benefit promises to double traffic.

### 2. Multi-Dimensional Performance & Geographic Analytics
When checking high-level performance, devices, geographic breakdown, or rich snippets:
```bash
# Full 360° executive dashboard (Totals, Devices, Countries, Snippets, Queries, Pages, Cities)
gsc performance --days 30 --json

# Device breakdown (Desktop vs Mobile vs Tablet clicks share)
gsc devices --json

# Top countries driving organic search impressions & clicks
gsc countries --limit 20 --json

# Top visitor cities and on-site engagement (via GA4)
gsc cities --limit 20 --json

# Search appearance & rich snippets (Review stars, Product snippets, FAQ rich results)
gsc snippets --json
```

### 3. Inspecting Page Index Status
When the user asks if a specific URL is indexed or why it's not showing up on Google:
```bash
gsc inspect https://example.com/features/new-feature --json
```
**Interpreting the JSON Response**:
- `verdict: "PASS"`: The page is successfully indexed and eligible for search results.
- `coverageState: "Crawled - currently not indexed"`: Google crawled the page but decided not to index it (often due to thin content, duplicate canonical, or low internal linking).
- `coverageState: "Discovered - currently not indexed"`: Google knows about the URL (via sitemap or link) but has not yet crawled it. You can trigger `gsc index <url>` to accelerate crawling.
- `robotsTxtState: "DISALLOWED"`: The page is blocked by `robots.txt`.

### 3. Pinging Googlebot After Creating/Updating Content
Whenever you generate a new blog post, landing page, or programmatic SEO route, notify Googlebot immediately:
```bash
gsc index https://example.com/blog/new-post --json
```
*(If a page was permanently deleted, use `gsc remove <url> --json` to protect store crawl health).*

### 4. Auditing Sitemaps
To bulk check whether all URLs in a sitemap are actually indexed:
```bash
gsc inspect-sitemap https://example.com/sitemap.xml --delay 300 --json
```

### 5. Managing Active Domains & Credentials
```bash
# Check current environment & key
gsc where --json

# List all verified domain properties accessible by key (and their linked GA4 status)
gsc domains --json

# Set or switch active domain globally
gsc use example.com --json
```

### 6. Post-Click Engagement & GA4 Correlation (Bounce Rate)
When checking visitor engagement, bounce rates, or correlating SERP rankings with on-site retention:
```bash
# Interactive setup wizard for Google Analytics 4
gsc connect-ga4

# Or link a GA4 Property ID directly to active domain
gsc config set-ga4 123456789 --json

# View top landing pages with sessions, bounce rates, engagement rates, and avg duration (isolated to domain)
gsc ga4 --organic --json

# Correlate Search Console rankings (clicks, impressions, position) with GA4 bounce rates per landing page
gsc correlation --json

# By default, GA4 queries include the target domain and all subdomains.
# Pass --site-only to restrict GA4 strictly to the apex website host:
gsc correlation --site-only --json

# Pass --all-hosts if you want to include all hostnames sending data to the GA4 property:
gsc correlation --all-hosts --json

# Stream live active visitors on site right now
gsc realtime --json

# Google Ads campaign performance (clicks, cost, CPC, conversions, CPA)
gsc ads --json

# Omnichannel traffic sources breakdown (Organic, Paid, Direct, Referral)
gsc channels --json

# Discover all GA4 properties accessible by your service account
gsc ga4-properties --json
```
**Interpretation Advice**:
- **🚨 HIGH BOUNCE (Clicks >= 10, Bounce > 70%)**: Searchers clicked but immediately left. Indicates search intent mismatch, slow page load (LCP), or misleading title hooks.
- **⭐ HIDDEN GEM (Position > 7, High Time on Page / Low Bounce)**: High visitor satisfaction despite lower rankings. Build internal links to push it into Top 3.
- **⚠️ TRACKING GAP (High Clicks, Low Sessions)**: Clicks recorded in Search Console aren't appearing in GA4. Check for broken GA4 tags or redirect loops.
- **📢 GOOGLE ADS ROI**: Track ad clicks, cost, CPC, and conversion CPA alongside organic search metrics without needing Google Ads API keys.

---

## Error Handling & Onboarding
- If `gsc` returns an error about missing credentials: Direct the user to run `gsc connect` in their terminal (which automatically scans `~/Downloads` for service account JSON keys or accepts a drag-and-drop), or run `gsc open` to reveal `~/.config/gsc/` in Finder.
- If `gsc` returns an error about permission restricted in Search Console: Ensure the service account email is added as an **Owner** in Google Search Console Settings -> Users and permissions.
- If `gsc ga4` or `gsc ga4-properties` returns 403 Forbidden:
  - If the error indicates an API has not been used or is disabled: Click the direct activation link output by the CLI (or enable **Google Analytics Data API** and **Google Analytics Admin API** in Google Cloud Console > APIs & Services > Library) and wait 1–2 minutes.
  - If the error indicates insufficient permissions: Add the service account email as a **Viewer** in Google Analytics 4 (Admin > Account Access Management to cover all properties, or Property Access Management).
