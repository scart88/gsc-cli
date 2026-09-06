---
name: gsc
description: Automates Google Search Console, Google Indexing API, live URL index inspection, sitemap batch submission, and search ranking analytics (queries, impressions, positions, CTR). Trigger whenever checking SEO rankings, inspecting Google indexing status, analyzing search impressions/clicks, or notifying Googlebot of new/updated pages.
---

# Google Search Console & Indexing API (GSC CLI) Agent Skill

This skill allows AI agents (Google Antigravity, Claude Code, Cursor, Codex, etc.) to programmatically interact with Google Search Console and the Google Indexing API using the `gsc` CLI tool.

## Key Capabilities
- **Search Analytics**: Query real keyword rankings, impressions, clicks, CTR, and average SERP positions.
- **Instant Googlebot Indexing**: Ping Google's Indexing API with `URL_UPDATED` or `URL_DELETED` to trigger immediate crawling.
- **Live URL Inspection**: Query Search Console API for actual index status (`PASS`, coverage state, canonical assigned by Google, crawl date).
- **Bulk Sitemap Audit**: Inspect entire XML sitemaps to identify indexed vs queued URLs.
- **Multi-domain Management**: Easily view or switch active domains across projects.

---

## Agent Rule: Always Use `--json` Flag
When running `gsc` commands from agent tools (`run_command`), **always append `--json`** to receive clean, machine-readable JSON output instead of ANSI terminal formatting:

```bash
gsc top-queries --json
gsc inspect https://example.com/page --json
gsc performance --days 30 --json
```

---

## Common Agent Workflows

### 1. Analyzing Keyword Rankings & SEO Opportunities
When the user asks about traffic, rankings, or keyword performance:
```bash
# Get top 20 queries for the active domain
gsc top-queries --limit 20 --json

# Get queries for a specific domain over the past 90 days
gsc top-queries -d example.com --days 90 --limit 50 --json
```
**Interpretation Advice**:
- Sort queries by impressions to find high-volume search terms.
- Look for queries with position 4–15 with high impressions — these are prime candidates for on-page content optimization to push them into the top 3.

### 2. Inspecting Page Index Status
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

# List all verified domain properties accessible by key
gsc domains --json

# Set or switch active domain globally
gsc use example.com --json
```

---

## Error Handling & Onboarding
- If `gsc` returns an error about missing credentials: Direct the user to run `gsc connect` in their terminal (which automatically scans `~/Downloads` for service account JSON keys or accepts a drag-and-drop), or run `gsc open` to reveal `~/.config/gsc/` in Finder.
- If `gsc` returns an error about permission restricted: Ensure the service account email is added as an **Owner** in Google Search Console Settings -> Users and permissions.
