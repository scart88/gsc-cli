# encoding: utf-8
# frozen_string_literal: true

require 'uri'

module GSC
  class LlmsGenerator
    attr_reader :base_url, :pages

    def initialize(base_url)
      @base_url = base_url.to_s.strip
      @base_url = "https://#{@base_url}" unless @base_url =~ %r{^https?://}
    end

    def generate_llms_txt(title: nil, summary: nil)
      loader = GSC::SitemapLoader.new(@base_url)
      urls = loader.load rescue [@base_url]
      urls = [@base_url] if urls.empty?

      site_title = title || URI.parse(@base_url).host.sub(/^www\./, '').capitalize
      site_summary = summary || "Official documentation and product guides for #{site_title}."

      out = []
      out << "# #{site_title}"
      out << ""
      out << "> #{site_summary}"
      out << ""
      out << "## Core Documentation"
      out << ""

      # Sample first 15 key URLs and fetch metadata
      urls.first(15).each do |url|
        pa = GSC::PageAnalyzer.new(url)
        pa.load_content! rescue next
        dom = pa.analyze_dom rescue next

        page_title = dom.dig(:title, :text) || url
        page_desc = dom.dig(:meta_description, :text) || "Documentation page."

        out << "- [#{page_title}](#{url}): #{page_desc}"
      end

      out << ""
      out << "## Optional"
      out << ""
      out << "- [Full Documentation](#{@base_url}/llms-full.txt): Complete consolidated knowledge base for LLM context ingestion."
      out << ""

      out.join("\n")
    end

    def audit_ai_readability(url)
      pa = GSC::PageAnalyzer.new(url)
      data = pa.fetch_and_analyze

      # Check criteria:
      # 1. Clear H1 presence
      # 2. Table presence (LLMs love tables)
      # 3. Schema presence (structured data)
      # 4. Definition / Bullet presence
      html = pa.html || ''
      has_tables = html.include?('<table')
      has_lists = html.include?('<ul') || html.include?('<ol')
      schemas = data.dig(:structured_data, :schemas) || []
      h1_count = (data.dig(:headings, :h1) || []).length

      score = 100
      issues = []

      if h1_count != 1
        score -= 20
        issues << "H1 count is #{h1_count} (Must be exactly 1 for clean LLM hierarchy)"
      end

      unless has_tables
        score -= 15
        issues << "No <table> found (tables increase LLM citation and fact extraction by 3x)"
      end

      unless has_lists
        score -= 15
        issues << "No bullet lists (<ul> or <ol>) found for quick entity consumption"
      end

      if schemas.empty?
        score -= 20
        issues << "No JSON-LD schemas detected (structured data accelerates AI knowledge graph inclusion)"
      end

      {
        url: url,
        ai_readability_score: [score, 0].max,
        grade: score >= 80 ? 'A (Excellent)' : (score >= 60 ? 'B (Acceptable)' : 'C (Needs Work)'),
        issues: issues,
        features: {
          has_tables: has_tables,
          has_lists: has_lists,
          schemas_found: schemas.length,
          h1_count: h1_count
        }
      }
    end
  end
end
