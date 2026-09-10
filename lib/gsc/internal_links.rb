# encoding: utf-8
# frozen_string_literal: true

require 'uri'
require 'set'

module GSC
  class InternalLinks
    attr_reader :base_url, :pages, :graph, :orphans, :depths

    def initialize(base_url, limit: 50)
      @base_url = base_url.to_s.strip
      @base_url = "https://#{@base_url}" unless @base_url =~ %r{^https?://}
      @base_uri = URI.parse(@base_url)
      @limit = limit
      @graph = Hash.new { |h, k| h[k] = Set.new } # target_url => Set of source_urls
      @out_links = Hash.new { |h, k| h[k] = Set.new } # source_url => Set of target_urls
      @all_discovered = Set.new
    end

    def audit(sitemap_urls = nil)
      urls_to_crawl = if sitemap_urls && !sitemap_urls.empty?
                        sitemap_urls.first(@limit)
                      else
                        discover_urls
                      end

      urls_to_crawl.each do |url|
        @all_discovered << normalize_url(url)
      end

      # Crawl each URL and extract internal links
      urls_to_crawl.each do |url|
        pa = GSC::PageAnalyzer.new(url)
        pa.load_content! rescue next
        dom = pa.analyze_dom rescue next

        norm_source = normalize_url(url)
        links = dom.dig(:links, :all) || []

        links.each do |link_obj|
          href = link_obj[:href]
          target_url = resolve_internal_url(href)
          next unless target_url

          norm_target = normalize_url(target_url)
          next if norm_target == norm_source

          @graph[norm_target] << norm_source
          @out_links[norm_source] << norm_target
        end
      end

      # Calculate Orphans (pages in sitemap/discovered with 0 incoming internal links)
      orphans = []
      weak_pages = [] # only 1 internal link

      @all_discovered.each do |url|
        in_degree = @graph[url].size
        if in_degree == 0 && url != normalize_url(@base_url)
          orphans << url
        elsif in_degree == 1
          weak_pages << { url: url, source: @graph[url].first }
        end
      end

      # Calculate click depths via BFS from root
      depths = calculate_depths(normalize_url(@base_url))

      {
        base_url: @base_url,
        total_pages: @all_discovered.size,
        orphans: orphans,
        weak_pages: weak_pages,
        top_linked: top_linked_pages(10),
        depths: depths
      }
    end

    private

    def discover_urls
      loader = GSC::SitemapLoader.new(@base_url)
      urls = loader.load
      urls.empty? ? [@base_url] : urls.first(@limit)
    rescue StandardError
      [@base_url]
    end

    def resolve_internal_url(href)
      return nil if href.nil? || href.strip.empty?
      return nil if href =~ /^(mailto|tel|javascript|#):/i

      uri = URI.join(@base_url, href) rescue nil
      return nil unless uri && uri.scheme =~ /^https?$/i
      return nil unless uri.host.downcase == @base_uri.host.downcase

      uri.fragment = nil
      uri.to_s
    end

    def normalize_url(url)
      u = url.to_s.strip.sub(%r{/$}, '')
      u
    end

    def calculate_depths(root_url)
      depths = { root_url => 0 }
      queue = [root_url]

      until queue.empty?
        curr = queue.shift
        curr_depth = depths[curr]

        (@out_links[curr] || []).each do |neighbor|
          next if depths.key?(neighbor)

          depths[neighbor] = curr_depth + 1
          queue << neighbor
        end
      end

      depths
    end

    def top_linked_pages(limit)
      @graph.map do |url, sources|
        { url: url, incoming_count: sources.size }
      end.sort_by { |item| -item[:incoming_count] }.first(limit)
    end
  end
end
