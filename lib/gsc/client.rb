# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'
require 'zlib'
require 'stringio'

module GSC
  class Client
    def initialize(token:)
      @token = token
    end

    def get(url)
      uri = URI(url)
      req = Net::HTTP::Get.new(uri)
      prepare_headers(req)
      execute(uri, req)
    end

    def post(url, body)
      uri = URI(url)
      req = Net::HTTP::Post.new(uri)
      prepare_headers(req)
      req['Content-Type'] = 'application/json'
      req.body = JSON.generate(body)
      execute(uri, req)
    end

    def put(url)
      uri = URI(url)
      req = Net::HTTP::Put.new(uri)
      prepare_headers(req)
      execute(uri, req)
    end

    private

    def prepare_headers(req)
      req['Authorization'] = "Bearer #{@token}"
      req['Accept-Encoding'] = 'gzip'
      ver = defined?(GSC::VERSION) ? GSC::VERSION : '1.0.0'
      req['User-Agent'] = "gsc-cli/#{ver} (gzip)"
    end

    def execute(uri, req)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == 'https')
      http.open_timeout = 10
      http.read_timeout = 30

      response = http.request(req)

      # Transparent gzip decompression
      raw_body = response.body
      body_str = if response['content-encoding'] =~ /gzip/i && raw_body && !raw_body.empty?
                   Zlib::GzipReader.new(StringIO.new(raw_body)).read
                 else
                   raw_body
                 end

      body = body_str ? (JSON.parse(body_str) rescue body_str) : nil

      {
        ok: response.is_a?(Net::HTTPSuccess),
        status: response.code.to_i,
        data: body,
        compressed: (response['content-encoding'] =~ /gzip/i ? true : false)
      }
    rescue StandardError => e
      {
        ok: false,
        status: 0,
        data: { 'error' => { 'message' => e.message } }
      }
    end
  end
end
