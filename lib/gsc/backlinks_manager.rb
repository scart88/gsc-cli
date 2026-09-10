# encoding: utf-8
# frozen_string_literal: true

require 'csv'
require 'fileutils'
require 'json'

module GSC
  class BacklinksManager
    attr_reader :domain, :storage_file

    def initialize(domain)
      @domain = clean_domain(domain)
      @domain_dir = File.join(Dir.home, '.config', 'gsc', 'domains', @domain)
      FileUtils.mkdir_p(@domain_dir)
      @storage_file = File.join(@domain_dir, 'backlinks.json')
    end

    def load_data
      return { 'sources' => [], 'targets' => [], 'updated_at' => nil } unless File.exist?(@storage_file)

      JSON.parse(File.read(@storage_file, encoding: 'UTF-8'))
    rescue StandardError
      { 'sources' => [], 'targets' => [], 'updated_at' => nil }
    end

    def save_data(data)
      data['updated_at'] = Time.now.utc.iso8601
      File.write(@storage_file, JSON.pretty_generate(data))
    end

    def import_csv(content)
      data = load_data
      lines = content.to_s.strip.lines

      return { error: 'Empty content' } if lines.empty?

      # Detect header
      header = lines.first.downcase
      if header.include?('top linking sites') || header.include?('root domain')
        # Sources CSV
        sources = []
        CSV.parse(content, headers: true, skip_blanks: true) do |row|
          domain_name = row['Top linking sites'] || row['Site'] || row[0]
          links_count = (row['Target pages'] || row['Links'] || row[1] || '1').to_s.gsub(',', '').to_i
          sources << { 'domain' => domain_name.to_s.strip, 'links_count' => links_count } if domain_name
        end
        data['sources'] = sources
      else
        # Target pages CSV
        targets = []
        CSV.parse(content, headers: true, skip_blanks: true) do |row|
          target_url = row['Target page'] || row['Page'] || row[0]
          incoming = (row['Incoming links'] || row['Links'] || row[1] || '1').to_s.gsub(',', '').to_i
          targets << { 'target_url' => target_url.to_s.strip, 'incoming_count' => incoming } if target_url
        end
        data['targets'] = targets
      end

      save_data(data)
      {
        status: 'success',
        sources_count: data['sources'].length,
        targets_count: data['targets'].length,
        updated_at: data['updated_at']
      }
    rescue StandardError => e
      { error: "Failed to parse CSV: #{e.message}" }
    end

    def summary(target_page: nil)
      data = load_data
      sources = data['sources'] || []
      targets = data['targets'] || []

      filtered_targets = target_page ? targets.select { |t| t['target_url'].include?(target_page) } : targets

      {
        domain: @domain,
        total_referring_domains: sources.length,
        total_external_links: sources.sum { |s| s['links_count'] || 0 },
        top_referring_domains: sources.sort_by { |s| -(s['links_count'] || 0) }.first(15),
        top_target_pages: filtered_targets.sort_by { |t| -(t['incoming_count'] || 0) }.first(15),
        updated_at: data['updated_at']
      }
    end

    private

    def clean_domain(input)
      d = input.to_s.strip.downcase
      d = d.sub(%r{^https?://}, '').sub(%r{/.*$}, '').sub(/^www\./, '')
      d
    end
  end
end
