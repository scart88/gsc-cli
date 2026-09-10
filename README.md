# 🚀 GSC CLI — The Zero-Dependency Google Search Console, Trends & Indexing Engine for High-Growth Operators

> **Zero Gem Dependencies.** Pure Ruby standard library (`Net::HTTP`, `OpenSSL`, `JSON`).  
> Sub-50ms CLI & AI Agent engine for real-time Google search rankings, instant Googlebot indexing, Google Trends velocity, Keywords Everywhere volume, and 360° SEO health audits.

[![Ruby](https://img.shields.io/badge/Ruby-3.0%2B-red.svg?logo=ruby&logoColor=white)](https://www.ruby-lang.org)
[![Dependencies](https://img.shields.io/badge/dependencies-0%20gems-brightgreen.svg)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![AI Agent Native](https://img.shields.io/badge/AI%20Agent-Native%20Skill-purple.svg)](#-ai-agent-native-integration-antigravity-claude-cursor)

---

<p align="center">
  <b>gsc-cli</b> is a free, open-source initiative built and maintained by 
  <a href="https://apolloswave.com"><b>AppollosWave LLC</b></a>.
</p>

<p align="center">
  <sub>Explore other software built by our team:</sub><br>
  ⚡ <a href="https://superspeedapp.com"><b>Superspeed</b></a> — Lightning-fast macOS disk cleaner & RAM booster for Apple Silicon<br>
  🛒 <a href="https://supercart.app"><b>Supercart</b></a> — High-converting slide cart drawer & 1-click upsells for Shopify stores<br>
  📦 <a href="https://packinglog.com"><b>PackingLog</b></a> — Smart QR-code box inventory & photo catalog for residential & office moves
</p>

---

## ⚡ The Brutal Truth About Modern SEO (And Why We Built GSC CLI)

Every software company, indie hacker, and e-commerce founder faces the exact same painful reality:

1. **You're Paying $300/Month for Guesswork**: Third-party SEO suites (Ahrefs, Semrush, Moz) scrape search results and guess your rankings using outdated third-party databases. Meanwhile, **Google already has the exact, ground-truth data** for your site sitting inside Search Console—for free.
2. **Official Google API Gems Are Bloated Monsters**: The official Google API Ruby gems (`google-apis-searchconsole_v1`, `google-apis-indexing_v3`, `googleauth`) drag in **40+ dependency gems**, take 3 to 5 seconds just to boot, trigger bundle conflicts, and introduce constant supply-chain security alerts.
3. **Google Search Console's Web UI is Painfully Slow**: Clicking through Google Search Console's web interface to inspect 50 URLs or spot keyword cannibalization takes hours of repetitive clicking, filtering, and tab-switching.
4. **AI Agents Need Clean, Fast, Machine-Readable Intelligence**: Modern AI coding agents (Google Antigravity, Claude Code, Cursor, Codex) cannot click web buttons. They need raw, fast, deterministic JSON over stdout.

### The Epiphany Bridge
At **[AppollosWave](https://apolloswave.com)**, we run multiple production software businesses—from macOS system utilities (**[Superspeed](https://superspeedapp.com)**) and Shopify e-commerce apps (**[Supercart](https://supercart.app)**) to physical moving inventory SaaS (**[PackingLog](https://packinglog.com)**).

We refused to bloat our repos with 40 gems or waste 10 hours a week clicking in Search Console. We needed a **single, standalone pure-Ruby CLI** that connects directly to Google APIs using native `OpenSSL` and `Net::HTTP` in **under 50 milliseconds**.

We built **`gsc-cli`** to run our own marketing. **We open-sourced it 100% free under the MIT License** so other builders and businesses can grow organic search traffic faster without the corporate SEO tax.

---

## 💎 Key Capabilities at a Glance

- 📈 **Real-Time Google Trends Engine**: 5-year and 1-year search trajectory, growth velocity percentage, Unicode sparklines (` ▂▃▄▅▆▇█`), and regional demand breakdowns with zero authentication.
- 🎯 **Zero-Auth Keyword Planner**: Instant seed expansion via Google Autocomplete with automated search intent classification (`Informational`, `Commercial`, `Transactional`).
- 💰 **Keywords Everywhere API Integration**: Fetch exact monthly search volume, CPC, competition index, and 12-month trends for up to 500 keywords in a single call.
- 📊 **Google Ads Planner Ingestion**: Ingest CSV exports from Google Ads Keyword Planner, calculate composite Opportunity Scores (0–100), and cross-correlate with live GSC rankings.
- 🚀 **Instant Googlebot Re-Indexing**: Ping Google's Indexing API with `URL_UPDATED` or `URL_DELETED` for priority crawl queueing within seconds.
- 🔍 **Live Google URL Inspection**: Direct Search Console API check for indexing verdict, assigned canonical URL, crawl timestamps, and robots.txt state.
- 💀 **90-Day Zombie Page Detection**: Automatically scan XML sitemaps to find zero-impression deadweight URLs draining your Google crawl budget.
- 🛡️ **Cannibalization & Decay Detection**: Spot internal URLs fighting for the same queries, and compare 28-day period-over-period traffic trends.
- 📊 **Google Analytics 4 (GA4) Behavioral Link**: Stream live active visitors (`gsc realtime --watch`) and correlate SERP rankings with landing page bounce rates.
- 📑 **Off-Page & On-Page SEO Merger (`gsc page`)**: Combines Detailed SEO Extension DOM inspection (title pixel width & SERP truncation, meta description, H1–H6 tree, missing alt attributes, canonicals, JSON-LD schema, OG/Twitter cards) with real Google Search Console 90-day search queries, clicks, and rankings.
- 🕷️ **Autonomous Site Audit & Broken Link Repair (`gsc site-audit`)**: Crawls all sitemap URLs, checks HTTP response codes for dead internal links (404/500/timeouts), audits missing image alts and heading defects, and exports an AI-actionable Markdown fix sprint.
- 🤖 **AI Agent Native**: Every single command supports `--json` for instantaneous programmatic consumption by AI agents.

---

## 📦 Quick Installation

### Option 1: One-Line Installer (Recommended for macOS & Linux)
```bash
curl -fsSL https://raw.githubusercontent.com/ApollosWave/gsc-cli/main/install.sh | bash
```

### Option 2: Clone & Install Standalone
`gsc-cli` is a standalone pure-Ruby executable with zero gem runtime dependencies:
```bash
git clone https://github.com/ApollosWave/gsc-cli.git
cd gsc-cli
./install.sh
```

### Option 3: RubyGem Installation
```bash
gem install gsc-cli
```

Ensure `~/.local/bin` is in your shell `PATH`:
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

Verify your installation:
```bash
gsc version
```

---

## ⚡ 2-Minute Google Setup

### Step 1: Create a Google Cloud Service Account Key
1. Open [Google Cloud Console](https://console.cloud.google.com/).
2. In **APIs & Services > Library**, enable:
   - **Web Search Indexing API**
   - **Google Search Console API**
   - *(Optional for GA4)*: **Google Analytics Data API**
3. In **IAM & Admin > Service Accounts**, click **Create Service Account** (e.g. `gsc-indexer`).
4. Click your new service account > **Keys** tab > **Add Key** > **Create new key** > **JSON**. Download the file.

### Step 2: Run 1-Click Interactive Connect
In your terminal, simply run:
```bash
gsc connect
```
`gsc` automatically searches your `~/Downloads` folder for recently created Google Cloud service account keys, lets you confirm with `Y`, and saves it securely to `~/.config/gsc/service-account.json`.

### Step 3: Add the Email to Google Search Console
1. Copy the service account email displayed in the terminal.
2. Go to [Google Search Console](https://search.google.com/search-console/) > Select your property > **Settings** > **Users and permissions**.
3. Click **Add User**, paste the email, and set permission to **Owner**.

Verify access immediately:
```bash
gsc domains
```

---

## 🧠 In-Depth Guides: Keyword Demand & Search Intelligence

### 0. Detailed Off-Page + On-Page SEO Merger (`gsc page` & `gsc site-audit`)

#### The Problem
On-page SEO browser extensions (like Detailed SEO Extension) inspect your DOM (titles, meta, headings, schemas), but they are blind to whether your page actually ranks on Google. Conversely, Google Search Console shows search impressions and positions, but tells you nothing about missing H1s, broken links, or images missing alt tags.

#### The Magic
`gsc page` merges both worlds into a single, cohesive 360° audit:
```bash
# Audit any URL combining DOM inspection with GSC 90-day search performance
gsc page https://packinglog.com/

# Deep internal link verification: tests HTTP status codes (200, 404, 500)
gsc page https://packinglog.com/ --check-links

# Local template auditing before deploying
gsc page src/routes/+page.svelte
```

And `gsc site-audit` crawls entire XML sitemaps to generate prioritized AI fix sprints:
```bash
gsc site-audit https://packinglog.com/sitemap.xml --report docs/seo/site_audit_issues.md
```

---

### 1. Keywords Everywhere API Integration (`gsc ke`)

#### The Problem
Knowing *what* people search is only half the battle. You need to know **exact monthly search volume**, **Cost Per Click (CPC)**, and **commercial competition**. Manually logging into keyword tools, copying keyword tables, and checking spreadsheets breaks your flow and blocks autonomous AI agents.

#### The Magic
`gsc-cli` integrates directly with the official Keywords Everywhere API. In a single command, it expands any topic, pulls exact search volumes and CPCs, calculates an **Opportunity Score (0–100)**, and checks whether your domain already ranks for that keyword in Search Console:

```bash
gsc ke "mac cleaner" --limit 25
```

Terminal Output:
```text
🔍 KEYWORDS EVERYWHERE SEARCH DEMAND (Seed: mac cleaner)
   Country: US · Provider: Google Keyword Planner via Keywords Everywhere API
   Correlated with GSC: superspeedapp.com

  KEYWORD                              VOL/MO      CPC    COMP   OPP SCORE  INTENT         GSC RANK STATUS
  ──────────────────────────────────────────────────────────────────────────────────────────────────────────
  best mac cleaner 2025                18,100    $4.80    0.42      82/100  Commercial     🎯 Striking Distance (Pos 8.4)
  free mac disk cleaner                12,400    $3.10    0.28      88/100  Transactional  🚀 Untargeted
  clean my mac alternative              6,600    $6.50    0.35      81/100  Commercial     🥇 Page 1 (Pos 4.2)
  how to clear system storage mac       9,900    $1.20    0.15      89/100  Informational  🚀 Untargeted
```

#### How to Connect Keywords Everywhere in 10 Seconds
1. Get an API key from [Keywords Everywhere](https://keywordseverywhere.com/) (credits start at just $1.25 for 100,000 keywords).
2. Connect it in `gsc`:
   ```bash
   gsc connect ke YOUR_API_KEY
   ```
   *Your key is securely saved to `~/.config/gsc/config.json` alongside your Google credentials.*
3. Check remaining account credits anytime:
   ```bash
   gsc ke-credits
   ```
4. Bulk inspect an entire keyword file:
   ```bash
   gsc ke keywords.txt --country us --limit 100 --json
   ```

---

### 2. Google Trends Real-Time Demand Engine (`gsc trends`)

#### The Problem
Standard search volume metrics are **12-month trailing averages**. When consumer behavior shifts, or a seasonal moving spike occurs, static tools keep showing last year's data while you miss the active breakout.

#### The Magic
`gsc trends` queries Google Trends explore and widget APIs directly in real time with **zero authentication and zero API keys**. It calculates:
- **Trajectory Velocity**: Compares recent interest vs historical baseline.
- **Velocity Badges**: `🚀 (Explosive Breakout)`, `🔥 (Strong Surging)`, `📈 (Growing Demand)`, `⚖️ (Stable Demand)`, `📉 (Cooling)`.
- **Unicode Sparklines**: Visualizes interest curves right in your terminal (` ▂▃▄▅▆▇█`).
- **Geographic Heatmap**: Identifies top states and regions driving demand.

```bash
gsc trends "moving boxes" --geo US --time 12m
```

```bash
gsc trends "local llm" --geo US --time 5y --json
```

---

### 3. Autocomplete Keyword Intent Expander (`gsc planner`)

#### The Problem
You need fresh keyword ideas based on what Google users are actively searching *right now*, without setting up paid APIs or logging into Google Ads.

#### The Magic
`gsc planner` queries Google's autocomplete infrastructure with zero keys, extracts 20–50 qualified search phrases, and uses regex linguistic heuristics to classify **Search Intent**:
- **Informational**: *"how to pack dishes for moving"*, *"why is mac running slow"*
- **Commercial**: *"best moving apps"*, *"superspeed vs cleanmymac"*
- **Transactional**: *"buy wardrobe moving boxes cheap"*, *"hire movers near me"*

It then checks your active domain's GSC rankings so you instantly see untargeted opportunities:
```bash
gsc planner "moving boxes" --limit 20
```

---

### 4. Universal Keyword Ingestion: Google Ads & Keywords Everywhere (`gsc import`)

#### The Problem
Exporting search volume and CPC data from keyword tools usually results in messy spreadsheets that sit forgotten in your downloads folder. Merging those keywords with your live Google Search Console rankings requires complex VLOOKUPs and manual position checking.

#### The Magic
`gsc import` accepts raw exports from **both Google Ads Keyword Planner and Keywords Everywhere** (in `.csv`, `.tsv`, or markdown table format):
```bash
# Import Keywords Everywhere export
gsc import path/to/KW.md --limit 30

# Import Google Ads Keyword Planner CSV/TSV
gsc import path/to/google-ads-keywords.csv --limit 30
```

`gsc` automatically:
- **Deduplicates** redundant keyword rows across multiple concatenated batches.
- **Normalizes** search volumes, CPC bids, and competition tiers.
- **Extracts 12-Month Historical Demand**: Automatically identifies monthly columns and renders a live **Unicode Sparkline** (` ▂▃▄▅▆▇█`) for each keyword in your terminal.
- **Calculates Opportunity Scores (0–100)**:
  $$\text{Opportunity} = \text{Search Volume (0–50)} + (1 - \text{Competition}) \times 50$$
- **Cross-References Live GSC Rankings**: Instantly flags whether your active domain is already ranking (`🏆 Top 3`, `🥇 Page 1`, `🎯 Striking Distance`) or represents an untapped gap (`🚀 Untargeted`).
- **Auto-Archives to Domain Storage**: Automatically persists the dataset to `~/.config/gsc/domains/<domain>/keywords/` for historical rank tracking.

Terminal Output:
```text
Opp Score | Volume/mo | CPC     | Comp | Tier   | Trend% [12m] | GSC Status                  | Intent        | Keyword
--------------------------------------------------------------------------------------------------------------------------------
       75 |     1,000 |  $11.04 | 0.10 | Low    |  -69% ▄▅▅█▅▁ | 🚀 Untargeted                | Navigational  | moving from san francisco to new york
       69 |        77 |   $0.00 | 0.00 | Low    |   +0% ▄▄▄▄▄▄ | 🚀 Untargeted                | Navigational  | moving from dallas to orlando
       68 |       390 |   $1.99 | 0.17 | Low    |  +25% ▁▄▄▄██ | 🚀 Untargeted                | Navigational  | storage unit size calculator
       68 |       110 |   $1.74 | 0.05 | Low    |  -65% ▂██▁▄▁ | 🚀 Untargeted                | Navigational  | moving checklist app
       64 |        30 |   $2.19 | 0.05 | Low    |  +83% ▃▁▁▆██ | 🚀 Untargeted                | Navigational  | moving volume calculator
```

---

### 5. Domain Keyword Archive & Rank Movement Tracker (`gsc saved`)

#### The Problem
Keyword research is only valuable if you track whether your content efforts actually move the needle over time. Without historical snapshots, you cannot tell if an unranked keyword from two months ago has entered striking distance.

#### The Magic
`gsc-cli` automatically stores all research and imported datasets in isolated domain directories under `~/.config/gsc/domains/<domain>/keywords/`.

```text
~/.config/gsc/
├── config.json
├── service-account.json
└── domains/
    ├── packinglog.com/
    │   └── keywords/
    │       ├── 2026-09-10-kw-md.json
    │       └── 2026-09-10-moving-boxes.json
    └── superspeedapp.com/
        └── keywords/
            └── 2026-09-10-mac-cleaner.json
```

#### List Saved Snapshots
```bash
gsc saved
```
```text
📁 SAVED KEYWORD RESEARCH ARCHIVES (packinglog.com)
   Location: ~/.config/gsc/domains/packinglog.com/keywords

  # | Date       | Source                | Keywords | Seed / File
  --------------------------------------------------------------------------------
 [1] | 2026-09-10 | Import                |      209 | KW.md
 [2] | 2026-09-10 | Google Autocomplete   |       50 | moving boxes
```

#### Re-Check Live Search Console Rankings & Track Wins
Run `gsc saved check <id>` to re-query Search Console API in real-time and measure your rank progress:
```bash
gsc saved check 1
```

```text
══════════════════════════════════════════════════════════════
📊 KEYWORD RANKING & OPPORTUNITY TRACKER (packinglog.com)
══════════════════════════════════════════════════════════════
  🏆 Top 3 Rankings:            2   (+2 new)
  🥇 Page 1 Rankings (4–10):    5   (+3 new)
  🎯 Striking Distance (11–20): 14  (+6 new)
  🚀 Untargeted / Unranked:     188
  📈 Total Tracked Keywords:    209
══════════════════════════════════════════════════════════════
```

---

## 🛠️ Complete CLI Command Reference

### 1. Setup, Configuration & Domain Switching
| Command | Description |
|---|---|
| `gsc connect` | 1-Click interactive setup wizard: auto-detects key in Downloads or drag & drop |
| `gsc connect ke [key]` | Connect Keywords Everywhere API key and save to `~/.config/gsc/config.json` |
| `gsc connect-ga4` | Interactive Google Analytics 4 linking wizard |
| `gsc domains` | List all verified Search Console properties and linked GA4 properties |
| `gsc use <domain or #>` | Switch active default domain (e.g. `gsc use 2` or `gsc use packinglog.com`) |
| `gsc open` | Open `~/.config/gsc` configuration directory in Finder |
| `gsc where` | Inspect CLI binary path, active credential file, and config path |
| `gsc update` | Self-update `gsc` to the latest version directly from GitHub |
| `gsc version` | Display CLI version and Ruby runtime environment |

### 2. Google Trends & Keyword Intelligence
| Command | Description |
|---|---|
| `gsc trends <query>` | Real-time Google Trends 5y/1y demand velocity, sparklines, and geo breakdown |
| `gsc planner <seed>` | Zero-auth Google Suggest intent expander with live GSC rank correlation |
| `gsc import <file>` | Ingest Google Ads or Keywords Everywhere export (.csv, .tsv, .md) with 12m sparklines |
| `gsc planner-import <file>` | Ingest Google Ads / Keywords Everywhere export (alias for `import`) |
| `gsc ke <seed or file>` | Keywords Everywhere: Exact monthly volume, CPC, competition & GSC correlation |
| `gsc ke-credits` | Check remaining Keywords Everywhere account API credits |
| `gsc saved` | List saved keyword research snapshots for the active domain |
| `gsc saved check [id]` | Re-check saved keyword snapshots against live GSC rankings to track wins |
| `gsc saved view [id]` | View stored keyword metrics and opportunity scores |
| `gsc saved delete [id]` | Delete a saved keyword research snapshot |

### 3. Search Performance & SEO Growth Intelligence
| Command | Description |
|---|---|
| `gsc top-queries` | Top search queries, impressions, CTR, and average position |
| `gsc top-pages` | Top indexed landing pages driving organic clicks & impressions |
| `gsc opportunities` | **Striking-distance queries (Pos 7–20)** to push to Page 1 and Top 3 |
| `gsc underperformers` | High-ranking queries (Top 10) with below-average CTR (title & meta tag wins) |
| `gsc cannibalization` | Detect multiple internal URLs competing for the same search queries |
| `gsc decay [--compare 28]` | Period-over-period decay detection (decaying vs surging queries) |
| `gsc devices` | Search traffic breakdown by device (Desktop, Mobile, Tablet) |
| `gsc countries` | Geographic search demand by country with flags and CTR |
| `gsc snippets` | Search appearance appearances (Reviews, Products, FAQs) |
| `gsc audit` | Comprehensive 4-step 360° SEO & Indexing Health Audit |

### 4. Detailed On-Page DOM & Autonomous Site Crawling
| Command | Description |
|---|---|
| `gsc page <url or file>` | 360° On-Page DOM audit (Title pixel width, meta, H1-H6, images, schema) + GSC rankings |
| `gsc page <url> --check-links` | Verify HTTP status codes (detects 404 broken links) across all page links |
| `gsc site-audit [sitemap]` | Crawl sitemap/site, test dead links, audit DOM flaws, and output summary |
| `gsc site-audit --report <file>` | Export comprehensive AI-actionable Markdown fix sprint (e.g. `site_issues.md`) |

### 4. Live Indexation & Googlebot Control
| Command | Description |
|---|---|
| `gsc inspect <url>` | Live Google Search Console URL inspection (coverage, canonical, crawl date) |
| `gsc index <url>` | Notify Googlebot to crawl/index a newly published URL immediately (`URL_UPDATED`) |
| `gsc remove <url>` | Notify Googlebot a URL has been permanently deleted (`URL_DELETED`) |
| `gsc status <url>` | Check Google Indexing API submission status and latest notification timestamp |
| `gsc inspect-sitemap <file/url>` | Bulk inspect indexation status for all URLs in an XML sitemap |
| `gsc index-sitemap <file/url>` | Batch submit all URLs in an XML sitemap to Google Indexing API |
| `gsc zombies <sitemap>` | Identify zero-impression deadweight URLs wasting crawl budget over 90 days |
| `gsc sitemaps-list` | List registered XML sitemaps in Search Console |
| `gsc sitemaps-submit <url>` | Submit or re-submit an XML sitemap to Search Console |

### 5. Google Analytics 4 (GA4) On-Site Behavior
| Command | Description |
|---|---|
| `gsc realtime [--watch]` | Stream active visitors, real-time page paths, and countries |
| `gsc ga4 [--organic]` | Landing page bounce rates, engagement rates, and average session duration |
| `gsc correlation` | Merge GSC keyword rankings with GA4 bounce rates per landing page |
| `gsc channels` | Traffic acquisition channels (Organic Search, Direct, Referral, Paid) |
| `gsc ads` | Google Ads campaign performance (Clicks, Cost, CPC, Conversions) |

---

## 🤖 AI Agent Native Integration (Antigravity, Claude, Cursor)

`gsc-cli` was built from the ground up for autonomous AI coding agents. Every single command supports the `--json` flag to return clean, deterministic, machine-readable JSON over stdout.

### Agent Workflow Examples

```bash
# 1. Ask your agent to inspect striking-distance keywords:
gsc opportunities --min-imp 20 --json

# 2. Ask your agent to audit indexation before shipping a release:
gsc audit --json

# 3. Ask your agent to discover keyword demand with volume and CPC:
gsc ke "moving boxes" --limit 50 --json

# 4. Ask your agent to notify Googlebot the second it publishes a new blog post:
gsc index https://example.com/blog/new-guide --json
```

Install the official AI Agent Skill:
```bash
gsc skills install
```

---

## 🏢 Proudly Backed by AppollosWave LLC

`gsc-cli` is free and open-source software under the [MIT License](LICENSE). It is actively developed and maintained by the engineering team at **[AppollosWave LLC](https://apolloswave.com)**.

We build tools for high-performance software, e-commerce, and everyday logistics. Check out our commercial products:

- ⚡ **[Superspeed](https://superspeedapp.com)** — The native, lightning-fast macOS performance & storage cleaner designed for Apple Silicon. Purge multi-gigabyte Xcode caches, app leftovers, and reclaim RAM in one tap.
- 🛒 **[Supercart](https://supercart.app)** — The modern slide cart drawer for Shopify. Boost Average Order Value (AOV) with automated in-cart upsells, free shipping progress bars, and instant 1-click checkout.
- 📦 **[PackingLog](https://packinglog.com)** — The personal and business moving box inventory management app. Batch-photograph box items with your phone, print scannable QR stickers, and locate any item in seconds.

---

## 🏗️ Architecture & Development

`gsc-cli` is engineered following a clean, modular Ruby architecture:

```text
gsc-cli/
├── bin/
│   └── gsc                      # Lean executable runner (< 15 lines)
├── lib/
│   ├── gsc.rb                   # Central loader & stdlib requirements
│   └── gsc/
│       ├── version.rb           # Semantic versioning (2.0.0)
│       ├── color.rb             # Zero-dependency ANSI formatting
│       ├── config.rb            # ~/.config/gsc/config.json persistence
│       ├── auth.rb              # Pure OpenSSL JWT generator
│       ├── client.rb            # Net::HTTP client with JSON serialization
│       ├── api.rb               # GSC, Indexing & GA4 API endpoints
│       ├── sitemap_loader.rb    # XML crawler & sitemap index parser
│       ├── google_trends.rb     # Real-time search demand engine
│       ├── keyword_planner.rb   # Autocomplete expander & intent classifier
│       ├── keywords_everywhere.rb # Keywords Everywhere API client
│       ├── command_registry.rb  # Command catalog (47 commands) & AI skills
│       └── cli.rb               # Option parser, command router & wizards
├── dist/
│   └── gsc                      # Standalone bundled binary (curl distribution)
├── gsc.gemspec                  # Standard RubyGem specification
├── Rakefile                     # Tasks for build, test, and install
└── install.sh                   # Universal 1-click shell installer
```

### Development Tasks
```bash
# Run syntax verification across all modular files
rake test

# Build the standalone single-file binary into dist/gsc
rake build:standalone

# Install local development build to ~/.local/bin/gsc
rake install:standalone

# Build gem package
rake gem:build
```

---

## 🙏 Acknowledgments & Credits

- **Ben Sheldon**: Inspired by Ben Sheldon's backend Ruby Google Ads API implementation and the Rails performance community's passion for lean, zero-dependency, server-side tools.
- **Corey Haines**: The companion SEO & marketing skills (`ai-seo`, `seo-audit`, `schema`, `programmatic-seo`, `copywriting`, `cro`) are adapted from the open-source [marketingskills](https://github.com/coreyhaines31/marketingskills) repository by [Corey Haines](https://github.com/coreyhaines31) (MIT License).
- **Basecamp & Kamal**: Modular CLI directory layout and standalone distribution patterns inspired by Basecamp's open-source tooling.

---

## 📄 License

This project is open-source software licensed under the **MIT License**. See [LICENSE](LICENSE) for details.
