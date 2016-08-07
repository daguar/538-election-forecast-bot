class Forecast
  attr_reader :hillary_polls_plus, :hillary_polls_only, :hillary_polls_now,
    :donald_polls_plus, :donald_polls_only, :donald_polls_now

  def self.from_tweet(tweet_text)
    matches = tweet_text.scan(extraction_regex)
    new(matches[0][0].to_f, matches[1][0].to_f, matches[2][0].to_f, matches[0][1].to_f, matches[1][1].to_f, matches[2][1].to_f)
  end

  def initialize(hillary_polls_plus, hillary_polls_only, hillary_polls_now, donald_polls_plus, donald_polls_only, donald_polls_now)
    @hillary_polls_plus = hillary_polls_plus
    @hillary_polls_only = hillary_polls_only
    @hillary_polls_now = hillary_polls_now
    @donald_polls_plus = donald_polls_plus
    @donald_polls_only = donald_polls_only
    @donald_polls_now = donald_polls_now
  end

  private

  def self.extraction_regex
    /([\d|.]+)%-(.+)%/
  end
end
