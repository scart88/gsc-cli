# encoding: utf-8
# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

module GSC
  class OpenPageRank
    API_URL = 'https://openpagerank.com/api/v1.0/getPageRank'

    attr_reader :api_key

    def initialize(api_key = nil)
      @api_key = api_key || ENV['OPENPAGERANK_API_KEY'] || GSC::Config.get('opr_api_key')
    end

    def configured?
      !@api_key.nil? && !@api_key.strip.empty?
    end

    def check_domains(domains)
      domains = Array(domains).map { |d| clean_domain(d) }.reject(&:empty?).uniq
      return { error: 'No valid domains provided' } if domains.empty?
      return { error: 'OpenPageRank API key not configured. Set via `gsc config set opr_api_key <key>` or OPENPAGERANK_API_KEY env (Get free 300k calls/mo at openpagerank.com)' } unless configured?

      # Construct query params: domains[0]=a.com&domains[1]=b.com
      params = domains.map.with_index { |d, idx| "domains%5B#{idx}%5D=#{URI.encode_www_form_component(d)}" }.join('&')
      uri = URI("#{API_URL}?#{params}")

      req = Net::HTTP::Get.new(uri)
      req['API-OPR'] = @api_key
      req['User-Agent'] = 'gsc-cli/2.1'

      res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, open_timeout: 5, read_timeout: 15) do |http|
        http.request(req)
      end

      if res.code == '200'
        data = JSON.parse(res.body)
        records = (data['response'] || []).map do |r|
          {
            domain: r['domain'],
            page_rank_decimal: r['page_rank_decimal'] || 0.0,
            page_rank_integer: r['page_rank_integer'] || 0,
            rank: r['rank'],
            status_code: r['status_code']
          }
        end
        {
          status: 'success',
          status_code: data['status_code'],
          records: records
        }
      else
        {
          status: 'error',
          code: res.code.to_i,
          message: res.body
        }
      end
    rescue StandardError => e
      { status: 'error', message: e.message }
    end

    def clean_domain(input)
      d = input.to_s.strip.downcase
      d = d.sub(%r{^https?://}, '').sub(%r{/.*$}, '').sub(/^www\./, '')
      d
    end
  end
end
