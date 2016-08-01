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

  def polls_plus_string
    "Polls-plus: #{forecast_for("plus","D")}% to #{forecast_for("plus","R")}%"
  end

  def polls_only_string
    "Polls-only: #{forecast_for("polls", "D")}% to #{forecast_for("polls", "R")}%"
  end

  def now_cast_string
    "Now-cast: #{forecast_for("now", "D")}% to #{forecast_for("now", "R")}%"
  end

  def forecast_for(model, party)
    data_hash[party]["models"][model]["winprob"].round(1)
  end

  def page_source
    @ps ||= HTTParty.get('https://projects.fivethirtyeight.com/2016-election-forecast/')
  end

  def data_hash
    extracted_json = page_source.body.match(/race\.stateData = (.+)\;/).captures.first
    parsed_json = JSON.parse(extracted_json)
    @dh ||= parsed_json["forecasts"]["latest"]
  end
end
