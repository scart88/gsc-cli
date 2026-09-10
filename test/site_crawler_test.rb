# encoding: utf-8
# frozen_string_literal: true

require_relative 'test_helper'

class SiteCrawlerTest < Minitest::Test
  def test_crawler_initialization
    crawler = GSC::SiteCrawler.new("https://example.com/sitemap.xml", limit: 5)
    assert_equal "https://example.com/sitemap.xml", crawler.target
    assert_equal 5, crawler.options[:limit]
  end

  def test_aggregate_summary_structure
    crawler = GSC::SiteCrawler.new("https://example.com/sitemap.xml")
    summary = crawler.aggregate_summary
    assert_equal 0, summary[:total_pages]
    assert_equal 0, summary[:broken_links_count]
    assert_equal 0, summary[:missing_alts_count]
  end
end
