# encoding: utf-8
# frozen_string_literal: true

require 'net/http'
require 'uri'

module GSC
  class RobotsChecker
    attr_reader :base_url, :robots_content

    def initialize(target_url)
      @target_url = target_url.to_s.strip
      @target_url = "https://#{@target_url}" unless @target_url =~ %r{^https?://}
      @uri = URI.parse(@target_url)
      @robots_url = "#{@uri.scheme}://#{@uri.host}:#{@uri.port}/robots.txt"
    end

    def fetch_robots_txt
      res = Net::HTTP.get_response(URI.parse(@robots_url))
      return '' unless res.code == '200'

      res.body.force_encoding('UTF-8')
    rescue StandardError
      ''
    end

    def check(path_to_test = nil, user_agent = 'googlebot')
      @robots_content ||= fetch_robots_txt
      path = path_to_test || @uri.path
      path = '/' if path.empty?

      ua = user_agent.to_s.downcase
      rules = parse_rules(ua)

      allowed = true
      matched_rule = nil

      rules.each do |rule|
        pattern = rule[:path]
        regex = Regexp.new('^' + Regexp.escape(pattern).gsub('\*', '.*'))
        if path =~ regex
          allowed = (rule[:type] == :allow)
          matched_rule = rule
        end
      end

      {
        robots_url: @robots_url,
        user_agent: user_agent,
        tested_path: path,
        allowed: allowed,
        matched_rule: matched_rule,
        has_robots_txt: !@robots_content.empty?
      }
    end

    private

    def parse_rules(target_ua)
      rules = []
      current_ua = nil
      applies = false

      @robots_content.each_line do |line|
        line = line.strip.sub(/#.*$/, '')
        next if line.empty?

        if line =~ /^User-agent:\s*(.+)$/i
          current_ua = $1.strip.downcase
          applies = (current_ua == '*' || current_ua == target_ua)
        elsif applies && line =~ /^Disallow:\s*(.*)$/i
          val = $1.strip
          rules << { type: :disallow, path: val } unless val.empty?
        elsif applies && line =~ /^Allow:\s*(.*)$/i
          val = $1.strip
          rules << { type: :allow, path: val } unless val.empty?
        end
      end

      rules
    end
  end
end
