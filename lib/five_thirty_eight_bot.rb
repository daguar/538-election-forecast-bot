require 'twitter'
require 'nokogiri'
require 'json'
require File.expand_path('../forecast', __FILE__)

class FiveThirtyEightBot
  attr_reader :twitter_client, :latest_forecast

  def initialize
    @twitter_client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV["CONSUMER_KEY"]
      config.consumer_secret     = ENV["CONSUMER_SECRET"]
      config.access_token        = ENV["ACCESS_TOKEN"]
      config.access_token_secret = ENV["ACCESS_TOKEN_SECRET"]
    end
  end

  def tweet_if_new_forecast
    @latest_forecast = Forecast.from_website

    twitter_client.update(forecast_update) unless last_forecast_tweet_is_current?
  end

  def is_forecast?(text)
    text.include?("Polls-plus") and
      text.include?("Polls-only") and
      text.include?("Now-cast")
  end

  private

  def last_forecast_tweet_is_current?
    last_tweet_with_a_forecast.include?(latest_forecast.hillary_polls_only.to_s) and last_tweet_with_a_forecast.include?(latest_forecast.donald_polls_only.to_s) and last_tweet_with_a_forecast.include?(latest_forecast.hillary_polls_plus.to_s) and last_tweet_with_a_forecast.include?(latest_forecast.donald_polls_plus.to_s) and last_tweet_with_a_forecast.include?(latest_forecast.hillary_polls_now.to_s) and last_tweet_with_a_forecast.include?(latest_forecast.donald_polls_now.to_s)
  end

  def last_tweet_with_a_forecast
    tweets = twitter_client.user_timeline
    tweets.each do |tweet|
      return tweet.text if is_forecast?(tweet.text)
    end
  end

  def forecast_update
    previous = Forecast.from_tweet(last_tweet_with_a_forecast)
    current = latest_forecast

    plus_delta = (current.hillary_polls_plus - previous.hillary_polls_plus).round(1)
    only_delta = (current.hillary_polls_only - previous.hillary_polls_only).round(1)
    now_delta = (current.hillary_polls_now - previous.hillary_polls_now).round(1)

    <<END
Update! Clinton-Trump
Polls-plus #{format_delta(plus_delta)}% (#{current.hillary_polls_plus}%-#{current.donald_polls_plus}%)
Polls-only #{format_delta(only_delta)}% (#{current.hillary_polls_only}%-#{current.donald_polls_only}%)
Now-cast #{format_delta(now_delta)}% (#{current.hillary_polls_now}%-#{current.donald_polls_now}%)
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
end
