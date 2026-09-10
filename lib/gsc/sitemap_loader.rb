# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'zlib'
require 'stringio'

module GSC
  class SitemapLoader
    def self.fetch_content(path_or_url)
      if path_or_url.start_with?('http://', 'https://')
        uri = URI(path_or_url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = (uri.scheme == 'https')
        http.open_timeout = 10
        http.read_timeout = 20
        req = Net::HTTP::Get.new(uri.request_uri)
        req['User-Agent'] = 'Mozilla/5.0 (compatible; GSC-SEO-Auditor/1.0)'
        req['Accept-Encoding'] = 'gzip'

        res = http.request(req)
        raise "HTTP #{res.code} fetching sitemap: #{path_or_url}" unless res.is_a?(Net::HTTPSuccess)

        raw = res.body || ''
        decompressed = if res['content-encoding'] =~ /gzip/i && !raw.empty?
                         Zlib::GzipReader.new(StringIO.new(raw)).read
                       else
                         raw
                       end
        decompressed.to_s.dup.force_encoding('UTF-8').scrub
      else
        raise "Local file not found: #{path_or_url}" unless File.exist?(path_or_url)
        File.read(path_or_url, encoding: 'UTF-8').scrub
      end
    end

    def self.load_urls(input, default_origin = nil)
      resolve_urls(input, default_origin, quiet: true)
    end

    def self.resolve_urls(input, default_origin = nil, quiet: false)
      target_input = input
      if target_input.nil? || target_input.empty?
        candidates = [
          'public/sitemap.xml',
          'public/sitemap-0.xml',
          'public/sitemap-index.xml',
          'dist/sitemap.xml',
          'dist/sitemap-index.xml'
        ]
        found = candidates.find { |f| File.exist?(f) }
        if found
          target_input = found
          puts Color.c("📄 Auto-detected local sitemap: #{found}", Color::GRAY) unless quiet
        elsif default_origin
          target_input = "#{default_origin.chomp('/')}/sitemap.xml"
          puts Color.c("🌐 Using remote sitemap URL: #{target_input}", Color::GRAY) unless quiet
        else
          raise 'No sitemap file or URL provided, and no local sitemap found.'
        end
      end

      xml = fetch_content(target_input)
      urls = []

      # Parse child sitemaps if this is a sitemap index
      sitemap_locs = xml.scan(/<sitemap>\s*<loc>([^<]+)<\/loc>/m).flatten
      if sitemap_locs.any?
        puts "📑 Found #{sitemap_locs.size} nested sitemaps in index..." unless quiet
        sitemap_locs.each do |child_url|
          child_url = child_url.strip
          unless child_url.start_with?('http://', 'https://')
            puts Color.c("   ⚠️ Skipping non-HTTP child sitemap location: #{child_url}", Color::YELLOW) unless quiet
            next
          end
          puts "   ↳ Loading child sitemap: #{child_url}" unless quiet
          begin
            child_xml = fetch_content(child_url)
            urls.concat(child_xml.scan(/<url>\s*<loc>([^<]+)<\/loc>/m).flatten.map(&:strip))
          rescue StandardError => e
            puts Color.c("   ⚠️ Warning: Could not load child sitemap #{child_url}: #{e.message}", Color::YELLOW) unless quiet
          end
        end
      else
        urls.concat(xml.scan(/<loc>([^<]+)<\/loc>/m).flatten.map(&:strip))
      end

      urls.uniq
    end
  end
end
