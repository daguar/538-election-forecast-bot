class SiteScrape
  def new
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

  private

  def page_source
    @ps ||= HTTParty.get('https://projects.fivethirtyeight.com/2016-election-forecast/')
  end

  def data_hash
    extracted_json = page_source.body.match(/race\.stateData = ([^;]+);/).captures.first
    parsed_json = JSON.parse(extracted_json)
    @dh ||= parsed_json["forecasts"]["latest"]
  end
end
