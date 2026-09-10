# encoding: utf-8
# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'
require 'fileutils'

module GSC
  class SiteCrawler
    attr_reader :target, :options, :results, :broken_links, :missing_alts, :heading_issues, :title_issues, :canonical_issues

    def initialize(target, options = {})
      @target = target.to_s.strip
      @options = options
      @results = []
      @broken_links = []
      @missing_alts = []
      @heading_issues = []
      @title_issues = []
      @canonical_issues = []
    end

    def run(&progress_block)
      urls = discover_urls(@target)
      urls = urls.first(@options[:limit]) if @options[:limit] && @options[:limit] > 0

      total = urls.size
      urls.each_with_index do |url, idx|
        progress_block.call(url, idx + 1, total) if block_given?

        analyzer = PageAnalyzer.new(url)
        page_data = analyzer.fetch_and_analyze(
          check_links: @options[:check_links] || false,
          gsc_api: @options[:gsc_api],
          active_domain: @options[:active_domain]
        )

        @results << page_data
        categorize_page_issues(page_data)
      end

      aggregate_summary
    end

    def generate_markdown_report(filepath)
      summary = aggregate_summary
      FileUtils.mkdir_p(File.dirname(File.expand_path(filepath)))

      md = []
      md << "# 🛠️ Autonomous SEO Site Audit & Broken Link Report"
      md << ""
      md << "> **Target**: `#{@target}`  "
      md << "> **Audit Date**: `#{Time.now.strftime('%Y-%m-%d %H:%M:%S UTC')}`  "
      md << "> **Pages Audited**: `#{summary[:total_pages]}` | **Total Issues Found**: `#{summary[:total_issues]}`  "
      md << "> **Broken Links (404/Error)**: `#{summary[:broken_links_count]}` | **Missing Alt Images**: `#{summary[:missing_alts_count]}`  "
      md << ""
      md << "---"
      md << ""
      md << "## 📊 1. Executive Health Scorecard"
      md << ""
      md << "| Metric | Count / Value | Health Status |"
      md << "| :--- | :---: | :--- |"
      md << "| **Total Pages Audited** | `#{summary[:total_pages]}` | ℹ️ Crawl Scope |"
      md << "| **Critical Errors** | `#{summary[:critical_errors_count]}` | #{summary[:critical_errors_count] == 0 ? '🟢 Clean' : '🔴 Action Required'} |"
      md << "| **Broken Links (404/500)** | `#{summary[:broken_links_count]}` | #{summary[:broken_links_count] == 0 ? '🟢 Zero Broken Links' : '🔴 Broken Links Detected'} |"
      md << "| **Images Missing Alt** | `#{summary[:missing_alts_count]}` | #{summary[:missing_alts_count] == 0 ? '🟢 100% Accessible' : '🟡 Needs Alt Text'} |"
      md << "| **Pages with 0 or >1 H1** | `#{summary[:heading_issues_count]}` | #{summary[:heading_issues_count] == 0 ? '🟢 Perfect Hierarchy' : '🟡 Review H1s'} |"
      md << "| **Title / Meta Flaws** | `#{summary[:title_meta_issues_count]}` | #{summary[:title_meta_issues_count] == 0 ? '🟢 Optimal' : '🟡 Review SERP Truncation'} |"
      md << ""
      md << "---"
      md << ""

      # 2. Broken Links
      md << "## 🚨 2. Broken Links & Dead Anchors (#{summary[:broken_links_count]} Found)"
      md << ""
      if @broken_links.empty?
        md << "✅ **No broken links detected across all audited pages!**"
      else
        md << "The following links returned HTTP errors (404 Not Found, 500 Server Error, or Timeout) and should be updated or removed:"
        md << ""
        md << "| Source Page URL | Target Broken URL | Anchor Text | HTTP Status |"
        md << "| :--- | :--- | :--- | :---: |"
        @broken_links.each do |b|
          md << "| `#{b[:source_page]}` | `#{b[:href]}` | #{b[:anchor].empty? ? '*(Empty)*' : b[:anchor]} | **#{b[:status]}** |"
        end
      end
      md << ""
      md << "---"
      md << ""

      # 3. Image Alt Tag Fixes
      md << "## 🖼️ 3. Images Missing Alt Attributes (#{summary[:missing_alts_count]} Found)"
      md << ""
      if @missing_alts.empty?
        md << "✅ **All images on audited pages have descriptive alt text!**"
      else
        md << "Search engines and screen readers rely on descriptive `alt` attributes to index visual content:"
        md << ""
        md << "| Page URL | Image Source URL | Recommended Fix |"
        md << "| :--- | :--- | :--- |"
        @missing_alts.each do |img|
          md << "| `#{img[:page_url]}` | `#{img[:src]}` | Add descriptive keywords to `alt=\"...\"` |"
        end
      end
      md << ""
      md << "---"
      md << ""

      # 4. Heading Hierarchy Flaws
      md << "## 📑 4. Heading Hierarchy & H1 Flaws (#{summary[:heading_issues_count]} Found)"
      md << ""
      if @heading_issues.empty?
        md << "✅ **All pages have exactly one <h1> and clean structure!**"
      else
        md << "| Page URL | Issue Details | Recommended Action |"
        md << "| :--- | :--- | :--- |"
        @heading_issues.each do |h|
          md << "| `#{h[:page_url]}` | #{h[:issue]} | Ensure exactly one <h1> matching primary search query |"
        end
      end
      md << ""
      md << "---"
      md << ""

      # 5. Title & Meta Description Flaws
      md << "## 🏷️ 5. Title & Meta Description Optimizations (#{summary[:title_meta_issues_count]} Found)"
      md << ""
      if @title_issues.empty?
        md << "✅ **All titles and meta descriptions meet 30–60 char and 70–155 char standards!**"
      else
        md << "| Page URL | Current Title (Chars) | Current Meta (Chars) | Flaw Detected |"
        md << "| :--- | :--- | :--- | :--- |"
        @title_issues.each do |t|
          md << "| `#{t[:page_url]}` | #{t[:title]} (#{t[:title_chars]}c) | #{t[:meta]} (#{t[:meta_chars]}c) | #{t[:flaw]} |"
        end
      end
      md << ""
      md << "---"
      md << ""

      # 6. Prioritized AI Action Sprint
      md << "## 🤖 6. AI Agent Automated Fix Sprint"
      md << ""
      md << "Use these instructions to locate template files and apply fixes:"
      md << ""
      md << "1. **P0: Fix Broken Links**: Locate `<a href=\"...\">` tags pointing to dead URLs identified in Section 2."
      md << "2. **P0: Single <h1> Enforcement**: Ensure all template layouts have exactly one `<h1>`."
      md << "3. **P1: Image Alt Tag Insertion**: Add descriptive `alt` attributes to all images in Section 3."
      md << "4. **P1: Title Truncation Fix**: Keep `<title>` under 60 characters and `<meta name=\"description\">` under 155 characters."
      md << "5. **P2: Googlebot Re-Index**: Ping Google's Indexing API for all updated URLs via `gsc index <url>`."
      md << ""
      md << "---\n*Report generated by `gsc site-audit` (On-Page & Off-Page SEO Engine)*"

      File.write(filepath, md.join("\n"), encoding: 'UTF-8')
      filepath
    end

    def aggregate_summary
      critical_errors = @broken_links.size + @results.count { |r| r[:indexability][:noindex] }
      total_issues = critical_errors + @missing_alts.size + @heading_issues.size + @title_issues.size + @canonical_issues.size

      {
        total_pages: @results.size,
        total_issues: total_issues,
        critical_errors_count: critical_errors,
        broken_links_count: @broken_links.size,
        missing_alts_count: @missing_alts.size,
        heading_issues_count: @heading_issues.size,
        title_meta_issues_count: @title_issues.size,
        canonical_issues_count: @canonical_issues.size
      }
    end

    private

    def discover_urls(target)
      if target.end_with?('.xml') || target.include?('sitemap')
        SitemapLoader.load_urls(target)
      elsif File.file?(target)
        [target]
      else
        normalized = target.start_with?('http') ? target : "https://#{target}"
        sitemap_url = "#{normalized.sub(%r{/+$}, '')}/sitemap.xml"
        urls = SitemapLoader.load_urls(sitemap_url)
        urls.empty? ? [normalized] : urls
      end
    rescue StandardError
      [target.start_with?('http') ? target : "https://#{target}"]
    end

    def categorize_page_issues(data)
      page_url = data[:url]

      # Broken links
      if data.dig(:links, :verification)
        data[:links][:verification].each do |link|
          if !link[:ok]
            @broken_links << {
              source_page: page_url,
              href: link[:href],
              anchor: link[:anchor],
              status: link[:status] || 'Error'
            }
          end
        end
      end

      # Missing alts
      if data.dig(:images, :missing_alt_images)
        data[:images][:missing_alt_images].each do |img|
          @missing_alts << {
            page_url: page_url,
            src: img[:src]
          }
        end
      end

      # Headings
      h1_count = data.dig(:headings, :h1_count) || 0
      if h1_count == 0
        @heading_issues << { page_url: page_url, issue: "Missing <h1> tag (0 found)" }
      elsif h1_count > 1
        @heading_issues << { page_url: page_url, issue: "Multiple <h1> tags (#{h1_count} found)" }
      end

      # Title & Meta
      title_chars = data.dig(:title, :length) || 0
      meta_chars = data.dig(:meta_description, :length) || 0
      title_text = data.dig(:title, :text) || ''
      meta_text = data.dig(:meta_description, :text) || ''

      flaws = []
      flaws << "Title > 60 chars" if title_chars > 60
      flaws << "Title < 30 chars" if title_chars > 0 && title_chars < 30
      flaws << "Missing Title" if title_chars == 0
      flaws << "Meta > 155 chars" if meta_chars > 155
      flaws << "Missing Meta" if meta_chars == 0

      if !flaws.empty?
        @title_issues << {
          page_url: page_url,
          title: title_text[0..40],
          title_chars: title_chars,
          meta: meta_text[0..40],
          meta_chars: meta_chars,
          flaw: flaws.join(', ')
        }
      end

      # Canonical
      if data.dig(:canonical, :url) && !data.dig(:canonical, :self_referencing)
        @canonical_issues << {
          page_url: page_url,
          canonical_url: data[:canonical][:url]
        }
      end
    end
  end
end
