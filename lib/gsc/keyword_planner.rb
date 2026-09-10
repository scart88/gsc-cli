# frozen_string_literal: true

module GSC
class KeywordPlanner
  SUGGEST_HOST = 'suggestqueries.google.com'

  def self.calculate_opportunity(volume, competition)
    vol = [volume.to_i, 0].max
    comp = [[competition.to_f, 0.0].max, 1.0].min
    return 0 if vol.zero?

    log_vol = Math.log10(vol + 10)
    vol_score = [log_vol * 10.0, 50.0].min
    comp_score = (1.0 - comp) * 50.0
    (vol_score + comp_score).round
  end

  def self.classify_intent(query)
    q = query.to_s.downcase
    if q =~ /\b(how|what|why|guide|tips|symptoms|remedies|causes|when|is it|can i)\b/
      'Informational'
    elsif q =~ /\b(best|review|reviews|top|vs|compare|alternative|alternatives|cost|pricing)\b/
      'Commercial'
    elsif q =~ /\b(buy|order|hire|cheap|service|services|near me|discount|coupon|deal|store|shop)\b/
      'Transactional'
    else
      'Navigational'
    end
  end

  def self.fetch_suggest(seed, country: 'us')
    encoded = URI.encode_www_form_component(seed)
    uri = URI("https://#{SUGGEST_HOST}/complete/search?client=chrome&hl=en&gl=#{country}&q=#{encoded}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 5
    http.read_timeout = 10
    req = Net::HTTP::Get.new(uri)
    req['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
    res = http.request(req)
    return [] unless res.is_a?(Net::HTTPSuccess)
    data = JSON.parse(res.body) rescue nil
    (data && data[1].is_a?(Array)) ? data[1] : []
  rescue StandardError
    []
  end

  def self.expand(seed, country: 'us', limit: 50)
    queries = []
    queries.concat(fetch_suggest(seed, country: country))

    modifiers = [
      "how to #{seed}",
      "best #{seed}",
      "#{seed} reviews",
      "#{seed} vs",
      "#{seed} alternatives",
      "cheap #{seed}",
      "#{seed} near me"
    ]
    modifiers.each do |mod|
      queries.concat(fetch_suggest(mod, country: country))
    end

    %w[a b c d f h m p s t w].each do |char|
      queries.concat(fetch_suggest("#{seed} #{char}", country: country))
    end

    clean_list = queries.map(&:strip).reject(&:empty?).uniq.first(limit)
    clean_list.map do |q|
      {
        keyword: q,
        intent: classify_intent(q)
      }
    end
  end

def self.render_sparkline(values, max_points: 12)
  return "" if values.nil? || values.empty?
  sparks = ["\u2581", "\u2582", "\u2583", "\u2584", "\u2585", "\u2586", "\u2587", "\u2588"]
  vals = values.last(max_points)
  min_val = vals.min.to_f
  max_val = vals.max.to_f
  range = max_val - min_val
  if range <= 0
    return sparks[3] * vals.length
  end
  vals.map do |v|
    idx = [((v - min_val) / range * (sparks.length - 1)).round, sparks.length - 1].min
    sparks[idx]
  end.join
end

def self.read_clipboard
  if RUBY_PLATFORM =~ /darwin/i
    `pbpaste 2>/dev/null`
  elsif system('which xclip > /dev/null 2>&1')
    `xclip -selection clipboard -o 2>/dev/null`
  elsif system('which wl-paste > /dev/null 2>&1')
    `wl-paste 2>/dev/null`
  else
    nil
  end
end

def self.import_file(source)
  src_str = source.to_s.strip
  raw_text = if ['clipboard', 'clip', 'paste', 'pbpaste'].include?(src_str.downcase)
               txt = read_clipboard
               raise "Clipboard is empty or could not be read. Copy a table from Keywords Everywhere and run: gsc import clip" if txt.nil? || txt.strip.empty?
               txt
             elsif src_str == '-'
               $stdin.read
             else
               raise "File does not exist: #{src_str}" unless File.exist?(src_str)
               File.read(src_str, encoding: 'UTF-8')
             end

  raw_lines = raw_text.lines.map(&:strip).reject(&:empty?)
  raise "Import content is empty." if raw_lines.empty?


  sample = raw_lines.find { |l| l =~ /keyword/i } || raw_lines.first
  delim = if sample.count("\t") > 2
            "\t"
          elsif sample.count(',') > 2
            ','
          elsif sample.include?('|')
            '|'
          else
            "\t"
          end

  header_idx = raw_lines.find_index { |l| l =~ /keyword|query/i } || 0
  header_line = raw_lines[header_idx]
  headers = header_line.split(delim).map { |h| h.strip.gsub(/[`*"]/, '') }

  kw_col   = headers.find_index { |h| h =~ /^(keyword|query|search query)$/i } || 0
  vol_col  = headers.find_index { |h| h =~ /(search volume|avg.*monthly searches|volume)/i }
  cpc_col  = headers.find_index { |h| h =~ /(cpc|top of page bid)/i }
  comp_col = headers.find_index { |h| h =~ /^(competition|competition \(indexed value\))$/i }
  tier_col = headers.find_index { |h| h =~ /(tier|competition level)/i }
  trend_col = headers.find_index { |h| h =~ /(trend.*%|three month change|yoy)/i }

  # Detect any month columns (e.g. from Keywords Everywhere 12-month export)
  month_cols = {}
  headers.each_with_index do |h, idx|
    if h =~ /^(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)\s+\d{4}$/i || h =~ /^\d{4}[-\/]\d{2}$/
      month_cols[h] = idx
    end
  end

  data_rows = raw_lines[(header_idx + 1)..]
  results = []
  seen = {}

  data_rows.each do |line|
    next if line =~ /^\|?[- :|]+\|?$/

    parts = line.split(delim).map { |p| p.strip.gsub(/[`*"]/, '') }
    kw = parts[kw_col]
    next if kw.nil? || kw.empty? || kw =~ /^(keyword|query|---|===)$/i
    next if kw.downcase == 'keyword'

    vol = vol_col ? parts[vol_col].to_s.gsub(/[,+ ]/, '').to_i : 0
    cpc_raw = cpc_col ? parts[cpc_col].to_s.strip : '$0.00'
    comp = comp_col ? parts[comp_col].to_s.to_f : 0.0
    comp_tier = tier_col ? parts[tier_col].to_s.strip : nil
    if comp_tier.nil? || comp_tier.empty?
      comp_tier = if comp < 0.30 then 'Low'
                  elsif comp < 0.70 then 'Medium'
                  else 'High'
                  end
    end
    trend = trend_col ? parts[trend_col].to_s.sub(/%/, '').to_i : 0
    opp_score = calculate_opportunity(vol, comp)
    intent = classify_intent(kw)

    history = {}
    month_cols.each do |m_name, c_idx|
      m_val = parts[c_idx].to_s.gsub(/[,+ ]/, '')
      history[m_name] = m_val.to_i unless m_val.empty?
    end

    kw_key = kw.downcase.strip
    if seen[kw_key]
      existing = seen[kw_key]
      if vol > existing[:volume]
        existing[:volume] = vol
        existing[:cpc] = cpc_raw if cpc_raw != '$0.00'
        existing[:competition] = comp
        existing[:competition_tier] = comp_tier
        existing[:trend_pct] = trend
        existing[:opportunity_score] = opp_score
      end
      existing[:monthly_history] = history.merge(existing[:monthly_history] || {}) unless history.empty?
    else
      entry = {
        keyword: kw,
        volume: vol,
        cpc: cpc_raw,
        competition: comp,
        competition_tier: comp_tier,
        trend_pct: trend,
        opportunity_score: opp_score,
        intent: intent
      }
if !history.empty?
  entry[:monthly_history] = history
  entry[:sparkline] = render_sparkline(history.values)
end
      seen[kw_key] = entry
      results << entry
    end
  end

  results.sort_by { |r| [-r[:opportunity_score], -r[:volume]] }
end

  def self.correlate_with_gsc(keywords, api, site_url, days: 30)
    return keywords if api.nil? || site_url.nil?

    res = api.query_analytics(site_url, days: days, dimensions: ['query'], row_limit: 5000)
    return keywords unless res[:ok]

    gsc_map = {}
    (res.dig(:data, 'rows') || []).each do |r|
      q = r['keys'].first.to_s.downcase.strip
      gsc_map[q] = {
        clicks: r['clicks'],
        impressions: r['impressions'],
        ctr: (r['ctr'] * 100).round(1),
        position: r['position'].round(1)
      }
    end

    keywords.map do |kw_item|
      item = kw_item.dup
      q = item[:keyword].to_s.downcase.strip
      if gsc_map[q]
        g = gsc_map[q]
        pos = g[:position]
        status = if pos <= 3.0 then "🏆 Top 3 (Pos #{pos})"
                 elsif pos <= 10.0 then "🥇 Page 1 (Pos #{pos})"
                 elsif pos <= 20.0 then "🎯 Striking Distance (Pos #{pos})"
                 else "🔍 Deep SERP (Pos #{pos})"
                 end
        item[:gsc] = g.merge(status: status)
      else
        item[:gsc] = { clicks: 0, impressions: 0, ctr: 0.0, position: 0.0, status: '🚀 Untargeted' }
      end
      item
    end
  end
end
end
