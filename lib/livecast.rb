class Livecast
  attr_reader :clinton_odds, :clinton_ev, :trump_odds, :trump_ev

  def self.from_website
    data = JSON.parse(HTTParty.get("http://projects.fivethirtyeight.com/election-night-forecast-2016/events.json").body)
    livecast_updates = data["president"]
    latest_update_data = livecast_updates.sort { |u| Time.parse(u["time"]).to_i }.last
    new(latest_update_data["states"]["US"]["D"].to_f.round(1), latest_update_data["evs"]["D"]["avg"].to_f.round(1), latest_update_data["states"]["US"]["R"].to_f.round(1), latest_update_data["evs"]["R"]["avg"].to_f.round(1))
  end

  def self.from_tweet(tweet_text)
    c_odds = tweet_text.scan(/Clinton (.+)% \(/)[0][0].to_f
    c_ev = tweet_text.scan(/Clinton (.+), (.+) EV/)[0][1].to_f
    t_odds = tweet_text.scan(/Trump (.+)% \(/)[0][0].to_f
    t_ev = tweet_text.scan(/Trump (.+), (.+) EV/)[0][1].to_f
    new(c_odds, c_ev, t_odds, t_ev)
  end

  def initialize(c_odds, c_ev, t_odds, t_ev)
    @clinton_odds = c_odds
    @clinton_ev = c_ev
    @trump_odds = t_odds
    @trump_ev = t_ev
  end
end
