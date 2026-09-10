# encoding: utf-8
# frozen_string_literal: true

module GSC
  class PageComparator
    attr_reader :url1, :url2, :data1, :data2

    def initialize(url1, url2)
      @url1 = url1
      @url2 = url2
    end

    def compare
      pa1 = GSC::PageAnalyzer.new(@url1)
      pa2 = GSC::PageAnalyzer.new(@url2)

      @data1 = pa1.fetch_and_analyze
      @data2 = pa2.fetch_and_analyze

      diffs = {
        meta: compare_meta,
        headings: compare_headings,
        images: compare_images,
        links: compare_links,
        performance: compare_perf,
        structured_data: compare_schema
      }

      {
        page1: { url: @url1, status: @data1[:http_status] },
        page2: { url: @url2, status: @data2[:http_status] },
        comparison: diffs
      }
    end

    private

    def compare_meta
      t1 = @data1.dig(:title, :text) || ''
      t2 = @data2.dig(:title, :text) || ''
      m1 = @data1.dig(:meta_description, :text) || ''
      m2 = @data2.dig(:meta_description, :text) || ''

      {
        title: {
          page1: { text: t1, length: t1.length, optimal: t1.length.between?(30, 60) },
          page2: { text: t2, length: t2.length, optimal: t2.length.between?(30, 60) }
        },
        meta_description: {
          page1: { text: m1, length: m1.length, optimal: m1.length.between?(70, 155) },
          page2: { text: m2, length: m2.length, optimal: m2.length.between?(70, 155) }
        }
      }
    end

    def compare_headings
      h1_1 = @data1.dig(:headings, :h1) || []
      h1_2 = @data2.dig(:headings, :h1) || []
      h2_1 = @data1.dig(:headings, :h2) || []
      h2_2 = @data2.dig(:headings, :h2) || []

      {
        h1_count: { page1: h1_1.length, page2: h1_2.length },
        h1_text: { page1: h1_1.first, page2: h1_2.first },
        h2_count: { page1: h2_1.length, page2: h2_2.length }
      }
    end

    def compare_images
      img1 = @data1[:images] || {}
      img2 = @data2[:images] || {}

      {
        total_images: { page1: img1[:total] || 0, page2: img2[:total] || 0 },
        missing_alt: { page1: img1[:missing_alt] || 0, page2: img2[:missing_alt] || 0 }
      }
    end

    def compare_links
      l1 = @data1[:links] || {}
      l2 = @data2[:links] || {}

      {
        internal: { page1: l1[:internal_count] || 0, page2: l2[:internal_count] || 0 },
        external: { page1: l1[:external_count] || 0, page2: l2[:external_count] || 0 }
      }
    end

    def compare_perf
      {
        response_time_ms: { page1: @data1[:response_time_ms], page2: @data2[:response_time_ms] }
      }
    end

    def compare_schema
      s1 = @data1.dig(:structured_data, :schemas) || []
      s2 = @data2.dig(:structured_data, :schemas) || []

      types1 = s1.map { |s| s['@type'] }.compact
      types2 = s2.map { |s| s['@type'] }.compact

      {
        schema_count: { page1: s1.length, page2: s2.length },
        schema_types: { page1: types1, page2: types2 }
      }
    end
  end
end
