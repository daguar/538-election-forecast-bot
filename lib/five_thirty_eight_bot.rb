require 'httparty'
require 'twitter'
require 'nokogiri'
require 'json'
require File.expand_path('../forecast', __FILE__)

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
    twitter_client.update(forecast_update) unless last_forecast_tweet_is_current?
  end

  def is_forecast?(text)
    text.include?("Polls-plus") and
      text.include?("Polls-only") and
      text.include?("Now-cast")
  end

  private

  def last_forecast_tweet_is_current?
    last_tweet_with_a_forecast.include?(hillary_polls_only.to_s) and last_tweet_with_a_forecast.include?(donald_polls_only.to_s) and last_tweet_with_a_forecast.include?(hillary_polls_plus.to_s) and last_tweet_with_a_forecast.include?(donald_polls_plus.to_s) and last_tweet_with_a_forecast.include?(hillary_polls_now.to_s) and last_tweet_with_a_forecast.include?(donald_polls_now.to_s)
  end

  def last_tweet_with_a_forecast
    tweets = twitter_client.user_timeline
    tweets.each do |tweet|
      return tweet.text if is_forecast?(tweet.text)
    end
  end

  def forecast_update
    previous_forecast = Forecast.from_tweet(last_tweet_with_a_forecast)

    plus_delta = (hillary_polls_plus - previous_forecast.hillary_polls_plus).round(1)
    only_delta = (hillary_polls_only - previous_forecast.hillary_polls_only).round(1)
    now_delta = (hillary_polls_now - previous_forecast.hillary_polls_now).round(1)

    <<END
Update! Clinton v Trump
Polls-plus #{format_delta(plus_delta)}% (#{hillary_polls_plus}%-#{donald_polls_plus}%)
Polls-only #{format_delta(only_delta)}% (#{hillary_polls_only}%-#{donald_polls_only}%)
Now-cast #{format_delta(now_delta)}% (#{hillary_polls_now}%-#{donald_polls_now}%)
https://projects.fivethirtyeight.com/2016-election-forecast/
END
  end

  def format_delta(delta_number)
    if delta_number > 0
      "↑ #{delta_number}"
    elsif delta_number < 0
      "↓ #{delta_number * -1}"
    else
      "#{delta_number}"
    end
  end

  def hillary_polls_only
    forecast_for("polls", "D")
  end

  def donald_polls_only
    forecast_for("polls", "R")
  end

  def polls_only_string
    "Polls-only: #{hillary_polls_only}%-#{donald_polls_only}%"
  end

  def hillary_polls_plus
    forecast_for("plus", "D")
  end

  def donald_polls_plus
    forecast_for("plus", "R")
  end

  def polls_plus_string
    "Polls-plus: #{hillary_polls_plus}%-#{donald_polls_plus}%"
  end

  def hillary_polls_now
    forecast_for("now", "D")
  end

  def donald_polls_now
    forecast_for("now", "R")
  end

  def now_cast_string
    "Now-cast: #{hillary_polls_now}%-#{donald_polls_now}%"
  end

  def forecast_for(model, party)
    data_hash[party]["models"][model]["winprob"].round(1)
  end

  def page_source
    @ps ||= HTTParty.get('https://projects.fivethirtyeight.com/2016-election-forecast/')
  end

  def data_hash
    extracted_json = page_source.body.match(/race\.stateData = ([^;]+);/).captures.first
    parsed_json = JSON.parse(extracted_json)
    @dh ||= parsed_json["forecasts"]["latest"]
  end
end
