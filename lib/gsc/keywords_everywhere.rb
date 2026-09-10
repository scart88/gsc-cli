# frozen_string_literal: true

module GSC
class KeywordsEverywhere
  API_HOST = "api.keywordseverywhere.com"

  def self.api_key
    Config.keywords_everywhere_api_key
  end

  def self.check_account(key = nil)
    k = (key && !key.to_s.strip.empty?) ? key.to_s.strip : api_key
    return { ok: false, error: "Keywords Everywhere API key not configured. Run: gsc connect ke" } if k.nil? || k.empty?

    uri = URI("https://#{API_HOST}/v1/account/credits")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 6
    http.read_timeout = 12

    req = Net::HTTP::Get.new(uri)
    req["Authorization"] = "Bearer #{k}"
    req["Accept"] = "application/json"
    req["User-Agent"] = "gsc-cli/#{GSC::VERSION}"

    res = http.request(req)
    parsed = begin
               JSON.parse(res.body)
             rescue StandardError
               res.body
             end

    if res.is_a?(Net::HTTPSuccess)
      # Keywords Everywhere /v1/account/credits returns an array with remaining credits as the only element: [ 95597755 ]
      # Some endpoints or proxies may return a Hash: {"credits": 95597755}
      credits = if parsed.is_a?(Array)
                  parsed.first.is_a?(Hash) ? (parsed.first["credits"] || parsed.first["data"] || 0) : parsed.first.to_i
                elsif parsed.is_a?(Hash)
                  parsed["credits"] || parsed["data"] || parsed["credits_left"] || 0
                else
                  parsed.to_i
                end
      credits = credits.first if credits.is_a?(Array)
      { ok: true, credits: credits.to_i }
    else
      err_msg = if parsed.is_a?(Hash)
                  parsed["message"] || parsed["error"] || parsed["description"] || "HTTP #{res.code}"
                elsif parsed.is_a?(Array)
                  parsed.map { |x| x.is_a?(Hash) ? (x["message"] || x["error"]) : x.to_s }.join(", ")
                else
                  "HTTP #{res.code}: #{parsed}"
                end
      { ok: false, error: err_msg }
    end
  rescue StandardError => e
    { ok: false, error: e.message }
  end

  def self.fetch_data(keywords, country: "us", currency: "usd", data_source: "gkp", key: nil)
    k = (key && !key.to_s.strip.empty?) ? key.to_s.strip : api_key
    return { ok: false, error: "Keywords Everywhere API key not configured. Run: gsc connect ke" } if k.nil? || k.empty?

    kw_list = Array(keywords).map(&:to_s).map(&:strip).reject(&:empty?).uniq
    return { ok: true, count: 0, data: [] } if kw_list.empty?

    results = []
    # Batch up to 100 keywords per request
    kw_list.each_slice(100) do |slice|
      uri = URI("https://#{API_HOST}/v1/get_keyword_data")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 10
      http.read_timeout = 30

      req = Net::HTTP::Post.new(uri)
      req["Authorization"] = "Bearer #{k}"
      req["Accept"] = "application/json"
      req["User-Agent"] = "gsc-cli/#{GSC::VERSION}"
      req["Content-Type"] = "application/x-www-form-urlencoded"

      form = {
        "country" => country.to_s.downcase,
        "currency" => currency.to_s.downcase,
        "dataSource" => data_source.to_s.downcase
      }
      base_encoded = URI.encode_www_form(form)
      kw_params = slice.map { |kw| "kw[]=#{URI.encode_www_form_component(kw)}" }.join("&")
      req.body = "#{base_encoded}&#{kw_params}"

      res = http.request(req)
      parsed = begin
                 JSON.parse(res.body)
               rescue StandardError
                 res.body
               end

      if res.is_a?(Net::HTTPSuccess)
        raw_items = if parsed.is_a?(Hash)
                      parsed["data"] || []
                    elsif parsed.is_a?(Array)
                      parsed
                    else
                      []
                    end

        raw_items.each do |item|
          next unless item.is_a?(Hash)
          vol = item["vol"].to_i
          cpc_val = (item["cpc"].is_a?(Hash) ? item.dig("cpc", "value") : item["cpc"]).to_f
          currency_sym = (item["cpc"].is_a?(Hash) ? item.dig("cpc", "currency") : "$") || "$"
          comp = item["competition"].to_f
          trend = item["trend"] || []
          opp_score = KeywordPlanner.calculate_opportunity(vol, comp)
          intent = KeywordPlanner.classify_intent(item["keyword"])

          results << {
            keyword: item["keyword"],
            volume: vol,
            cpc: cpc_val,
            currency: currency_sym,
            competition: comp,
            opportunity_score: opp_score,
            intent: intent,
            trend: trend
          }
        end
      else
        err = if parsed.is_a?(Hash)
                parsed["message"] || parsed["error"] || "HTTP #{res.code}"
              elsif parsed.is_a?(Array)
                parsed.map { |x| x.is_a?(Hash) ? (x["message"] || x["error"]) : x.to_s }.join(", ")
              else
                "HTTP #{res.code}"
              end
        return { ok: false, error: "Keywords Everywhere API error: #{err}" }
      end
    end

    { ok: true, count: results.size, data: results }
  rescue StandardError => e
    { ok: false, error: e.message }
  end
end
end
