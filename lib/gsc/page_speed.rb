# encoding: utf-8
# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

module GSC
  class PageSpeed
    API_URL = 'https://www.googleapis.com/pagespeedonline/v5/runPagespeed'

    attr_reader :url, :strategy, :api_key

    def initialize(url, strategy: 'mobile', api_key: nil)
      @url = url.to_s.strip
      @strategy = strategy.to_s.downcase == 'desktop' ? 'desktop' : 'mobile'
      @api_key = api_key || ENV['PAGESPEED_API_KEY'] || GSC::Config.get('pagespeed_api_key')
    end

    def run
      query_params = [
        "url=#{URI.encode_www_form_component(@url)}",
        "strategy=#{@strategy}",
        "category=performance",
        "category=seo"
      ]
      query_params << "key=#{URI.encode_www_form_component(@api_key)}" if @api_key && !@api_key.empty?

      uri = URI("#{API_URL}?#{query_params.join('&')}")
      req = Net::HTTP::Get.new(uri)
      req['User-Agent'] = 'gsc-cli/2.1'

      res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, open_timeout: 10, read_timeout: 30) do |http|
        http.request(req)
      end

      if res.code == '200'
        parse_response(JSON.parse(res.body))
      else
        {
          error: true,
          status_code: res.code.to_i,
          message: res.body
        }
      end
    rescue StandardError => e
      { error: true, message: e.message }
    end

    private

    def parse_response(data)
      lhr = data['lighthouseResult'] || {}
      categories = lhr['categories'] || {}
      perf_score = ((categories.dig('performance', 'score') || 0) * 100).round
      seo_score = ((categories.dig('seo', 'score') || 0) * 100).round

      audits = lhr['audits'] || {}

      # Core Web Vitals
      fcp = audits.dig('first-contentful-paint', 'displayValue')
      lcp = audits.dig('largest-contentful-paint', 'displayValue')
      cls = audits.dig('cumulative-layout-shift', 'displayValue')
      tbt = audits.dig('total-blocking-time', 'displayValue')
      si  = audits.dig('speed-index', 'displayValue')

      # CrUX Field Data (if available)
      crux_metrics = {}
      crux = data.dig('loadingExperience', 'metrics') || {}
      crux.each do |k, v|
        crux_metrics[k] = {
          percentile: v['percentile'],
          category: v['category']
        }
      end

      # Opportunities
      opportunities = []
      audits.each do |k, v|
        next unless v['details'] && v['details']['type'] == 'opportunity'
        next unless v['numericValue'] && v['numericValue'] > 100

        opportunities << {
          id: k,
          title: v['title'],
          savings_ms: v['numericValue'] ? v['numericValue'].round : 0,
          display: v['displayValue']
        }
      end
      opportunities.sort_by! { |o| -o[:savings_ms] }

      {
        url: @url,
        strategy: @strategy,
        fetch_time: lhr['fetchTime'],
        performance_score: perf_score,
        seo_score: seo_score,
        metrics: {
          fcp: fcp,
          lcp: lcp,
          cls: cls,
          tbt: tbt,
          speed_index: si
        },
        field_data: crux_metrics,
        opportunities: opportunities.first(5)
      }
    end
  end
end
