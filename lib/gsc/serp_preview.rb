# encoding: utf-8
# frozen_string_literal: true

module GSC
  class SerpPreview
    attr_reader :url, :data

    def initialize(url)
      @url = url.to_s.strip
    end

    def generate
      pa = GSC::PageAnalyzer.new(@url)
      @data = pa.fetch_and_analyze

      title = @data.dig(:title, :text) || 'Untitled Page'
      desc = @data.dig(:meta_description, :text) || 'No meta description found.'
      canonical = @data.dig(:canonical, :url) || @url

      # SERP pixel calculation approximation:
      # ~10px per character average for Arial 18px title
      title_chars = title.length
      is_truncated = title_chars > 60

      desktop_title = is_truncated ? "#{title[0..56]}..." : title
      desktop_snippet = desc.length > 155 ? "#{desc[0..152]}..." : desc

      og = @data[:open_graph] || {}
      twitter = @data[:twitter_card] || {}

      {
        url: @url,
        canonical: canonical,
        title: title,
        meta_description: desc,
        truncation_risk: is_truncated,
        desktop_serp: {
          title: desktop_title,
          snippet: desktop_snippet,
          breadcrumb: format_breadcrumb(canonical)
        },
        social: {
          og_title: og['og:title'] || title,
          og_description: og['og:description'] || desc,
          og_image: og['og:image'],
          twitter_card: twitter['twitter:card'] || 'summary_large_image'
        }
      }
    end

    private

    def format_breadcrumb(url_str)
      uri = URI.parse(url_str) rescue nil
      return url_str unless uri && uri.host

      domain = uri.host.sub(/^www\./, '')
      parts = uri.path.split('/').reject(&:empty?)
      if parts.empty?
        "https://#{domain}"
      else
        "https://#{domain} > #{parts.join(' > ')}"
      end
    end
  end
end
