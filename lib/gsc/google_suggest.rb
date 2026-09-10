# encoding: utf-8
# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

module GSC
  class GoogleSuggest
    SUGGEST_URL = 'https://suggestqueries.google.com/complete/search'

    attr_reader :query, :options

    def initialize(query, options = {})
      @query = query.to_s.strip
      @options = options
    end

    def fetch(alphabet: false, questions: false)
      if questions
        fetch_questions
      elsif alphabet
        fetch_alphabet_soup
      else
        fetch_single(@query)
      end
    end

    def fetch_single(search_term)
      uri = URI("#{SUGGEST_URL}?client=chrome&q=#{URI.encode_www_form_component(search_term)}")
      req = Net::HTTP::Get.new(uri)
      req['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36'
      req['Accept'] = 'application/json, text/javascript, */*; q=0.01'

      res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, open_timeout: 5, read_timeout: 10) do |http|
        http.request(req)
      end

      return [] unless res.code == '200'

      parsed = JSON.parse(res.body.force_encoding('UTF-8'))
      terms = parsed[1] || []
      types = parsed[4] ? parsed[4]['google:suggesttype'] || [] : []

      terms.map.with_index do |term, idx|
        {
          term: term,
          type: types[idx] || 'QUERY',
          root: search_term
        }
      end
    rescue StandardError => e
      []
    end

    def fetch_alphabet_soup
      results = {}
      base = @query.strip

      # Root query first
      results['root'] = fetch_single(base)

      # A-Z permutations
      ('a'..'z').each do |letter|
        term = "#{base} #{letter}"
        items = fetch_single(term)
        results[letter] = items unless items.empty?
        sleep(0.05) # Polite throttle
      end

      # 0-9 permutations if requested
      if @options[:numbers]
        ('0'..'9').each do |num|
          term = "#{base} #{num}"
          items = fetch_single(term)
          results[num] = items unless items.empty?
          sleep(0.05)
        end
      end

      results
    end

    def fetch_questions
      prefixes = [
        'how to',
        'how do',
        'why do',
        'why does',
        'what is',
        'what are',
        'can you',
        'best',
        'where to',
        'which'
      ]

      results = {}
      prefixes.each do |pfx|
        term = "#{pfx} #{@query}"
        items = fetch_single(term)
        results[pfx] = items unless items.empty?
        sleep(0.05)
      end

      results
    end
  end
end
