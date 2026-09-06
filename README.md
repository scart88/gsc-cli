# 🚀 GSC CLI — Google Search Console & Indexing API in Pure Ruby

> **Zero Gem Dependencies.** Pure Ruby standard library (`Net::HTTP`, `OpenSSL`, `JSON`).  
> Trigger instant Googlebot re-crawls, bulk-index XML sitemaps, inspect live URL indexation, and monitor real search rankings from your terminal or AI agent.

[![Ruby](https://img.shields.io/badge/Ruby-3.0%2B-red.svg?logo=ruby&logoColor=white)](https://www.ruby-lang.org)
[![Dependencies](https://img.shields.io/badge/dependencies-0%20gems-brightgreen.svg)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![AI Agent Native](https://img.shields.io/badge/AI%20Agent-Native%20Skill-purple.svg)](#ai-agent-integration)

---

## Why GSC CLI?

Official Google API gems (`google-apis-searchconsole_v1`, `google-apis-indexing_v3`, `googleauth`) pull in **40+ dependency gems**, take seconds to boot, and add heavy bloat to your project.

**GSC CLI** is a **single, standalone Ruby script** that does direct OAuth2 Service Account JWT assertions using standard library `OpenSSL::PKey::RSA` and `Net::HTTP`. 

- ⚡ **Instant startup time** (< 50ms)
- 🔒 **Zero gem vulnerabilities or bundle conflicts**
- 🤖 **Native AI Agent Skill** (machine-readable `--json` for Claude Code, Antigravity, Cursor)
- 🌍 **Global multi-domain workflow** (`gsc use <domain>`, `gsc domains`, `gsc connect`)
- 🔄 **Self-updating** (`gsc update`, `gsc version`)

---

## Quick Installation

### Option 1: One-Line Installer (Recommended)
```bash
curl -fsSL https://raw.githubusercontent.com/scart88/gsc-cli/main/install.sh | bash
```

### Option 2: Clone or Download Directly
```bash
git clone https://github.com/scart88/gsc-cli.git
cd gsc
cp bin/gsc ~/.local/bin/gsc
chmod +x ~/.local/bin/gsc
```

Make sure `~/.local/bin` is in your `PATH`:
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

---

## ⚡ 2-Minute Google Setup

### Step 1: Create a Service Account Key
1. Open [Google Cloud Console](https://console.cloud.google.com/).
2. In **APIs & Services > Library**, enable:
   - **Web Search Indexing API**
   - **Google Search Console API**
3. In **IAM & Admin > Service Accounts**, click **Create Service Account** (e.g. `gsc-indexer`).
4. Click your new service account > **Keys** tab > **Add Key** > **Create new key** > **JSON**. Download the file.

### Step 2: Run 1-Click Interactive Connect
Run in your terminal:
```bash
gsc connect
```
It automatically finds the JSON key in your `~/Downloads` folder (or lets you drag & drop it into the terminal) and configures `~/.config/gsc/service-account.json`.

### Step 3: Add to Google Search Console
1. Copy the service account email (shown by `gsc connect` or `gsc where`).
2. Go to [Google Search Console](https://search.google.com/search-console/).
3. Select your property > **Settings** > **Users and permissions**.
4. Click **Add User**, paste the service account email, and set permission to **Owner**.

Verify your access:
```bash
gsc domains
```

---

## 🛠️ CLI Usage & Commands

### Domain Management & Configuration
```bash
gsc use example.com         # Set default domain (saved to ~/.config/gsc/config.json)
gsc domains                 # List verified domains (highlights currently active domain)
gsc where                   # Show installation path, active key, and config paths
gsc open                    # Reveal config directory in macOS Finder
gsc version                 # Show version, Ruby runtime, and environment
gsc update                  # Self-update to the latest version from GitHub
```

### Search Analytics & SERP Rankings
Once you run `gsc use <domain>`, you don't need to pass `-d` on every call:
```bash
# Top 50 search queries with impressions, clicks, CTR, and average SERP position
gsc top-queries

# Top queries over the last 90 days, limit to top 20
gsc top-queries --days 90 --limit 20

# Top indexed pages driving search traffic
gsc top-pages --days 30

# 30-day aggregated performance summary (Total Clicks, Imp, CTR, Avg Pos)
gsc performance

# Export ranking report directly to CSV
gsc top-queries --csv rankings.csv
```

### Instant Googlebot Crawl Notifications
Notify Googlebot immediately when you publish or update content:
```bash
# Ping Googlebot to crawl a new or updated URL (URL_UPDATED)
gsc index https://example.com/blog/new-launch-guide

# Notify Googlebot that a URL was deleted (URL_DELETED)
gsc remove https://example.com/old-page

# Check Indexing API notification metadata
gsc status https://example.com/blog/new-launch-guide
```

### URL Inspection & Bulk Sitemap Auditing
```bash
# Live Search Console inspection (coverage verdict, canonical, crawl date, robots.txt)
gsc inspect https://example.com/pricing

# Bulk inspect every URL in a sitemap and generate an indexation health report
gsc inspect-sitemap https://example.com/sitemap.xml

# Bulk submit all URLs in an XML sitemap for priority indexing
gsc index-sitemap https://example.com/sitemap.xml

# Full automated 4-step SEO & Indexing audit
gsc audit
```

---

## 🤖 AI Agent Integration (Claude Code, Antigravity, Cursor)

`gsc` is built from the ground up for AI coding assistants and autonomous agents.

### 1. Install the Agent Skill
```bash
gsc skills install
```
This automatically detects your AI agent environment and installs the skill:
- **Google Antigravity / Gemini**: `~/.gemini/config/skills/gsc/SKILL.md`
- **Claude Code**: `~/.claude/skills/gsc/SKILL.md`
- **Universal Workspace**: `.agents/skills/gsc/SKILL.md`

### 2. Machine-Readable `--json` Mode
Every single command supports `-j` / `--json`, returning clean structured JSON for LLM tool consumption:
```bash
gsc top-queries --json
gsc inspect https://example.com/features --json
gsc performance --json
```

Example output:
```json
[
  {
    "query": "how to pack a kitchen for moving",
    "clicks": 4,
    "impressions": 58,
    "ctr": 6.9,
    "position": 7.2
  }
]
```

### 3. Bundled Companion Growth & SEO Skills
This repository includes a curated suite of battle-tested AI agent skills (under MIT License) designed to work alongside `gsc`:

| Skill | Path | Focus |
|---|---|---|
| **`gsc`** | `skills/gsc/` | Direct Google Search Console & Indexing API execution |
| **`ai-seo`** | `skills/ai-seo/` | Getting cited in ChatGPT, Perplexity & Google AI Overviews |
| **`seo-audit`** | `skills/seo-audit/` | Technical crawl diagnostics, on-page factors & architecture |
| **`schema`** | `skills/schema/` | JSON-LD structured data for rich snippets & entity understanding |
| **`programmatic-seo`** | `skills/programmatic-seo/` | Template page strategy & directory generation at scale |
| **`copywriting`** | `skills/copywriting/` | High-converting headline formulas & value propositions |
| **`cro`** | `skills/cro/` | Conversion rate optimization & sign-up friction reduction |

---

## 📁 Repository Structure

```text
gsc/
├── bin/
│   └── gsc                        # Standalone pure-Ruby executable (Zero gems)
├── skills/
│   ├── gsc/                       # GSC CLI Agent Skill
│   ├── ai-seo/                    # GEO & LLM citation optimization
│   ├── seo-audit/                 # Technical site & crawl audit
│   ├── schema/                    # JSON-LD structured data
│   ├── programmatic-seo/          # Scalable directory & template pages
│   ├── copywriting/               # Conversion copy frameworks
│   └── cro/                       # Funnel & conversion rate optimization
├── install.sh                     # 1-line curl & setup script
├── README.md                      # Documentation
├── LICENSE                        # MIT License
└── .gitignore                     # Protects credentials and exports
```

---

## 🤝 Contributing

Contributions, bug reports, and PRs are welcome!

```bash
git clone https://github.com/scart88/gsc-cli.git
cd gsc
chmod +x bin/gsc
./bin/gsc version
```

---

## 🙏 Acknowledgments & Credits

- **Companion Growth Skills**: The companion SEO & marketing skills (`ai-seo`, `seo-audit`, `schema`, `programmatic-seo`, `copywriting`, `cro`) are adapted from the open-source [marketingskills](https://github.com/coreyhaines31/marketingskills) repository by [Corey Haines](https://github.com/coreyhaines31) (MIT License). If you're looking for the full 50-skill marketing suite (covering paid ads, outbound, email sequences, and more), be sure to check out his repository!
- **Ruby Community**: Inspired by [Ben Sheldon](https://github.com/bensheldon) and the Rails performance community's passion for lean, zero-dependency, server-side tools.

---

## 📄 License

Released under the [MIT License](LICENSE).
