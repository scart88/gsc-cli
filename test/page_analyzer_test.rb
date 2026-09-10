# encoding: utf-8
# frozen_string_literal: true

require_relative 'test_helper'

class PageAnalyzerTest < Minitest::Test
  SAMPLE_HTML = <<~HTML
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <title>Best Moving Boxes &amp; Packing Supplies | PackingLog</title>
      <meta name="description" content="Discover smart moving boxes with QR code inventory tracking. Print stickers and catalog boxes fast.">
      <link rel="canonical" href="https://packinglog.com/boxes">
      <meta name="robots" content="index, follow">
      <script type="application/ld+json">
      {
        "@context": "https://schema.org",
        "@type": "Product",
        "name": "Smart Moving Box Labels",
        "offers": {
          "@type": "Offer",
          "price": "0.00"
        }
      }
      </script>
    </head>
    <body>
      <h1>Smart Moving Boxes</h1>
      <h2>Why QR Labels Work</h2>
      <p>Moving made simple.</p>
      <h2>Box Sizes</h2>
      <h3>Small Box</h3>
      <img src="/images/box1.jpg" alt="Small moving box">
      <img src="/images/box2.jpg">
      <a href="/pricing">Pricing</a>
      <a href="https://google.com" rel="nofollow">External Link</a>
    </body>
    </html>
  HTML

  def test_page_analyzer_parses_dom
    analyzer = GSC::PageAnalyzer.new("https://packinglog.com/boxes", html: SAMPLE_HTML)
    data = analyzer.fetch_and_analyze

    # Title & Meta
    assert_equal "Best Moving Boxes & Packing Supplies | PackingLog", data[:title][:text]
    assert_equal 49, data[:title][:length]
    assert data[:title][:pixel_est] > 300
    assert data[:title][:ok]

    assert_includes data[:meta_description][:text], "Discover smart moving boxes"
    assert_equal 99, data[:meta_description][:length]
    assert data[:meta_description][:ok]

    # Canonical
    assert_equal "https://packinglog.com/boxes", data[:canonical][:url]
    assert data[:canonical][:self_referencing]

    # Indexability
    assert_equal "INDEXABLE", data[:indexability][:status]

    # Headings
    assert_equal 4, data[:headings][:count]
    assert_equal 1, data[:headings][:h1_count]
    assert_equal "Smart Moving Boxes", data[:headings][:list].first[:text]

    # Images
    assert_equal 2, data[:images][:total]
    assert_equal 1, data[:images][:missing_alt_count]
    assert_equal "/images/box2.jpg", data[:images][:missing_alt_images].first[:src]

    # Links
    assert_equal 2, data[:links][:total]
    assert_equal 1, data[:links][:internal_count]
    assert_equal 1, data[:links][:external_count]
    assert_equal 1, data[:links][:nofollow_count]

    # Schema
    assert_equal 1, data[:schema].size
    assert data[:schema].first[:valid]
    assert_includes data[:schema].first[:types], "Product"
    assert_includes data[:schema].first[:types], "Offer"
  end

  def test_flags_missing_h1_and_long_title
    bad_html = <<~HTML
      <html>
      <head>
        <title>This is a ridiculously long title that exceeds the recommended 60 character limit and will be truncated by Google in search results</title>
      </head>
      <body>
        <h2>No H1 here</h2>
      </body>
      </html>
    HTML

    analyzer = GSC::PageAnalyzer.new("https://example.com/bad", html: bad_html)
    data = analyzer.fetch_and_analyze

    assert_equal 0, data[:headings][:h1_count]
    refute data[:title][:ok]

    issues = data[:issues].map { |i| i[:message] }
    assert issues.any? { |m| m =~ /Missing <h1>/ }
    assert issues.any? { |m| m =~ /Title too long/ }
    assert issues.any? { |m| m =~ /Missing meta description/ }
  end
end
