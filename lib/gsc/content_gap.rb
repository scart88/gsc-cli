# encoding: utf-8
# frozen_string_literal: true

require 'set'

module GSC
  class ContentGap
    STOP_WORDS = Set.new(%w[
      a about above after again against all am an and any are aren't as at be because been before being below
      between both but by can't cannot could couldn't did didn't do does doesn't doing don't down during each
      few for from further had hadn't has hasn't have haven't having he he'd he'll he's her here here's hers
      herself him himself his how how's i i'd i'll i'm i've if in into is isn't it it's its itself let's me
      more most mustn't my myself no nor not of off on once only or other ought our ours ourselves out over own
      same shan't she she'd she'll she's should shouldn't so some such than that that's the their theirs them
      themselves then there there's these they they'd they'll they're they've this those through to too under until
      up very was wasn't we we'd we'll we're we've were weren't what what's when when's where where's which while
      who who's whom why why's with won't would wouldn't you you'd you'll you're you've your yours yourself yourselves
    ])

    attr_reader :url1, :url2

    def initialize(url1, url2)
      @url1 = url1
      @url2 = url2
    end

    def analyze
      pa1 = GSC::PageAnalyzer.new(@url1)
      pa2 = GSC::PageAnalyzer.new(@url2)

      data1 = pa1.fetch_and_analyze
      data2 = pa2.fetch_and_analyze

      text1 = extract_clean_text(pa1.html || '')
      text2 = extract_clean_text(pa2.html || '')

      tokens1 = tokenize(text1)
      tokens2 = tokenize(text2)

      unigrams1 = ngrams(tokens1, 1)
      unigrams2 = ngrams(tokens2, 1)

      bigrams1 = ngrams(tokens1, 2)
      bigrams2 = ngrams(tokens2, 2)

      trigrams1 = ngrams(tokens1, 3)
      trigrams2 = ngrams(tokens2, 3)

      # Competitor terms that occur at least 2 times, but occur 0 times in page1
      missing_unigrams = term_gap(unigrams1, unigrams2, min_count: 2)
      missing_bigrams  = term_gap(bigrams1, bigrams2, min_count: 2)
      missing_trigrams = term_gap(trigrams1, trigrams2, min_count: 2)

      # Heading gaps (H2/H3 in page2 that have no match in page1)
      h1 = (data1.dig(:headings, :h2) || []) + (data1.dig(:headings, :h3) || [])
      h2 = (data2.dig(:headings, :h2) || []) + (data2.dig(:headings, :h3) || [])

      missing_headings = h2.reject do |heading|
        h1.any? { |my_h| my_h.downcase.include?(heading.downcase[0..15]) }
      end

      {
        page1: { url: @url1, word_count: tokens1.length },
        page2: { url: @url2, word_count: tokens2.length },
        missing_unigrams: missing_unigrams.first(15),
        missing_bigrams: missing_bigrams.first(15),
        missing_trigrams: missing_trigrams.first(10),
        missing_headings: missing_headings.first(10)
      }
    end

    private

    def extract_clean_text(html)
      text = html.dup
      text.gsub!(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/i, ' ')
      text.gsub!(/<style\b[^<]*(?:(?!<\/style>)<[^<]*)*<\/style>/i, ' ')
      text.gsub!(/<nav\b[^<]*(?:(?!<\/nav>)<[^<]*)*<\/nav>/i, ' ')
      text.gsub!(/<footer\b[^<]*(?:(?!<\/footer>)<[^<]*)*<\/footer>/i, ' ')
      text.gsub!(/<[^>]+>/, ' ')
      text.gsub!(/&[a-z]+;/i, ' ')
      text.gsub!(/\s+/, ' ')
      text.strip
    end

    def tokenize(text)
      text.downcase.scan(/[a-z0-9]+/).reject { |w| w.length < 3 || STOP_WORDS.include?(w) }
    end

    def ngrams(tokens, n)
      counts = Hash.new(0)
      return counts if tokens.length < n

      (0..(tokens.length - n)).each do |i|
        gram = tokens[i, n].join(' ')
        counts[gram] += 1
      end
      counts
    end

    def term_gap(counts1, counts2, min_count: 2)
      gap = []
      counts2.each do |term, count2|
        count1 = counts1[term] || 0
        if count2 >= min_count && count1 == 0
          gap << { term: term, competitor_count: count2, your_count: count1 }
        end
      end
      gap.sort_by { |item| -item[:competitor_count] }
    end
  end
end
