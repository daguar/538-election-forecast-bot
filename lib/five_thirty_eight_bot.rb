require 'httparty'
require 'twitter'
require 'nokogiri'
require 'json'

class FiveThirtyEightBot
  attr_reader :twitter_client

  def initialize
    @twitter_client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV["CONSUMER_KEY"]
      config.consumer_secret     = ENV["CONSUMER_SECRET"]
      config.access_token        = ENV["ACCESS_TOKEN"]
      config.access_token_secret = ENV["ACCESS_TOKEN_SECRET"]
    end
  end

  def tweet_if_new_forecast
    if current_forecast != last_tweet
      twitter_client.update(current_forecast)
    end
  end

  private

  def last_tweet
    twitter_client.home_timeline.first.text
  end

  def current_forecast
    <<END
Forecast Model Update
(Hillary vs. Donald)
#{polls_plus_string}
#{polls_only_string}
#{now_cast_string}
END
  end

  def page_source
    @ps ||= HTTParty.get('https://projects.fivethirtyeight.com/2016-election-forecast/')
  end

  def data_hash
    extracted_json = page_source.body.match(/race\.stateData = (.+)\;/).captures.first
    parsed_json = JSON.parse(extracted_json)
    @dh ||= parsed_json["forecasts"]["latest"]
  end

  def polls_plus_string
    hillary = data_hash["D"]["models"]["plus"]["winprob"].round(1)
    the_donald = data_hash["R"]["models"]["plus"]["winprob"].round(1)

    "Polls-plus: #{hillary}% to #{the_donald}%"
  end

  def polls_only_string
    hillary = data_hash["D"]["models"]["polls"]["winprob"].round(1)
    the_donald = data_hash["R"]["models"]["polls"]["winprob"].round(1)

    "Polls-only: #{hillary}% to #{the_donald}%"
  end

  def now_cast_string
    hillary = data_hash["D"]["models"]["now"]["winprob"].round(1)
    the_donald = data_hash["R"]["models"]["now"]["winprob"].round(1)

    "Now-cast: #{hillary}% to #{the_donald}%"
  end
end
