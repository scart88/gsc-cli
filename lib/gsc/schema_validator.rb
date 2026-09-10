# encoding: utf-8
# frozen_string_literal: true

require 'json'

module GSC
  class SchemaValidator
    attr_reader :url, :schemas, :validation_results

    def initialize(url)
      @url = url.to_s.strip
    end

    def audit
      pa = GSC::PageAnalyzer.new(@url)
      data = pa.fetch_and_analyze
      @schemas = data.dig(:structured_data, :schemas) || []

      results = []
      @schemas.each_with_index do |schema, idx|
        results << validate_single_schema(schema, idx)
      end

      {
        url: @url,
        total_schemas: @schemas.length,
        schemas: results
      }
    end

    def validate_single_schema(schema, idx)
      type = schema['@type'] || 'Unknown'
      errors = []
      warnings = []

      case type
      when 'SoftwareApplication', 'WebApplication'
        errors << 'Missing "name"' unless schema['name']
        warnings << 'Missing "operatingSystem"' unless schema['operatingSystem']
        warnings << 'Missing "applicationCategory"' unless schema['applicationCategory']
        warnings << 'Missing "offers"' unless schema['offers']
        warnings << 'Missing "aggregateRating"' unless schema['aggregateRating']

      when 'FAQPage'
        main_entity = schema['mainEntity']
        if !main_entity || !main_entity.is_a?(Array) || main_entity.empty?
          errors << 'FAQPage must contain a non-empty "mainEntity" array'
        else
          main_entity.each_with_index do |q, q_idx|
            errors << "Question ##{q_idx + 1} missing name" unless q['name']
            errors << "Question ##{q_idx + 1} missing acceptedAnswer" unless q['acceptedAnswer']
          end
        end

      when 'Product'
        errors << 'Missing "name"' unless schema['name']
        warnings << 'Missing "image"' unless schema['image']
        warnings << 'Missing "offers"' unless schema['offers']

      when 'Article', 'BlogPosting'
        errors << 'Missing "headline"' unless schema['headline']
        errors << 'Missing "author"' unless schema['author']
        warnings << 'Missing "datePublished"' unless schema['datePublished']
        warnings << 'Missing "image"' unless schema['image']

      when 'Organization', 'LocalBusiness'
        errors << 'Missing "name"' unless schema['name']
        errors << 'Missing "url"' unless schema['url']
        warnings << 'Missing "logo"' unless schema['logo']
      end

      {
        index: idx,
        type: type,
        valid: errors.empty?,
        errors: errors,
        warnings: warnings,
        raw: schema
      }
    end

    def self.generate_template(type, params = {})
      case type.to_s.downcase
      when 'faq'
        {
          '@context' => 'https://schema.org',
          '@type' => 'FAQPage',
          'mainEntity' => [
            {
              '@type' => 'Question',
              'name' => params[:question] || 'What is PackingLog?',
              'acceptedAnswer' => {
                '@type' => 'Answer',
                'text' => params[:answer] || 'PackingLog is a free moving box and inventory management system.'
              }
            }
          ]
        }
      when 'software', 'app'
        {
          '@context' => 'https://schema.org',
          '@type' => 'SoftwareApplication',
          'name' => params[:name] || 'PackingLog',
          'applicationCategory' => params[:category] || 'UtilitiesApplication',
          'operatingSystem' => 'Web, iOS, Android',
          'offers' => {
            '@type' => 'Offer',
            'price' => '0',
            'priceCurrency' => 'USD'
          }
        }
      else
        {
          '@context' => 'https://schema.org',
          '@type' => 'Organization',
          'name' => params[:name] || 'PackingLog',
          'url' => params[:url] || 'https://packinglog.com'
        }
      end
    end
  end
end
