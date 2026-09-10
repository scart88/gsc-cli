# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'
require 'openssl'
require 'base64'
require 'optparse'
require 'time'
require 'date'
require 'fileutils'

module GSC
end

require_relative 'gsc/version'
require_relative 'gsc/color'
require_relative 'gsc/config'
require_relative 'gsc/auth'
require_relative 'gsc/client'
require_relative 'gsc/api'
require_relative 'gsc/sitemap_loader'
require_relative 'gsc/google_trends'
require_relative 'gsc/keyword_planner'
require_relative 'gsc/keywords_everywhere'
require_relative 'gsc/prompts'
require_relative 'gsc/page_analyzer'
require_relative 'gsc/site_crawler'
require_relative 'gsc/command_registry'
require_relative 'gsc/cli'

# Top-level aliases for compatibility
GoogleTrends       = GSC::GoogleTrends unless defined?(GoogleTrends)
KeywordPlanner     = GSC::KeywordPlanner unless defined?(KeywordPlanner)
KeywordsEverywhere = GSC::KeywordsEverywhere unless defined?(KeywordsEverywhere)
Prompts            = GSC::Prompts unless defined?(Prompts)
PageAnalyzer       = GSC::PageAnalyzer unless defined?(PageAnalyzer)
SiteCrawler        = GSC::SiteCrawler unless defined?(SiteCrawler)
