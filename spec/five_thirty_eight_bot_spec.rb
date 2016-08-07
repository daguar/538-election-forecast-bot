require 'five_thirty_eight_bot'

RSpec.describe FiveThirtyEightBot do
  describe '#tweet_if_new_forecast' do
    let(:bot) { FiveThirtyEightBot.new }
    let(:fake_twitter) { double(Twitter::REST::Client, user_timeline: timeline, update: true) }

    before do
      allow(HTTParty).to receive(:get).and_call_original
      allow(Twitter::REST::Client).to receive(:new).and_return(fake_twitter)

      VCR.use_cassette('fivethirtyeight') do
        bot.tweet_if_new_forecast
      end
    end

    context 'when the latest tweet is an outdated forecast' do
      let(:timeline) do
        [
          double(Twitter::Tweet, text: <<END
Forecast Model Update
(Hillary vs. Donald)
Polls-plus: 75.4%-24.6%
Polls-only: 80.9%-19.1%
Now-cast: 92.5%-7.5%
https://projects.fivethirtyeight.com/2016-election-forecast/
END
                )
        ]
      end

      it 'downloads the 538 predictions page' do
        expect(HTTParty).to have_received(:get).with('https://projects.fivethirtyeight.com/2016-election-forecast/')
      end

      it 'tweets the update with a delta' do
        current_forecast_status = <<END
Update! Clinton v Trump
Polls-plus ↓ 1.0% (74.4%-25.6%)
Polls-only ↓ 1.0% (79.9%-20.1%)
Now-cast ↓ 1.0% (91.5%-8.5%)
https://projects.fivethirtyeight.com/2016-election-forecast/
END
        expect(fake_twitter).to have_received(:update).with(current_forecast_status)
      end
    end

    context 'when the latest tweet has the current forecast' do
      let(:timeline) do
        [
          double(Twitter::Tweet, text: <<END
<<END
Forecast Model Update
(Hillary vs. Donald)
Polls-plus: 74.4%-25.6%
Polls-only: 79.9%-20.1%
Now-cast: 91.5%-8.5%
END
                )
        ]
      end

      it 'does not tweet' do
        expect(fake_twitter).to_not have_received(:update)
      end
    end

    context 'when the latest tweet is not a forecast, but the one before that is an up to date forecast' do
      let(:timeline) do
        [
          double(Twitter::Tweet, text: 'random tweet text'),
          double(Twitter::Tweet, text: <<END
Forecast Model Update
(Hillary vs. Donald)
Polls-plus: 74.4%-25.6%
Polls-only: 79.9%-20.1%
Now-cast: 91.5%-8.5%
END
                )
        ]
      end

      it 'does not tweet' do
        expect(fake_twitter).to_not have_received(:update)
      end
    end

    context 'when the latest tweet has the current forecast but has somewhat different words' do
      let(:timeline) do
        [
          double(Twitter::Tweet, text: <<END
<<END
NEW WORDING HERE
(Hillary vs. Donald)
Polls-plus: 74.4%-25.6%
Polls-only: 79.9%-20.1%
Now-cast: 91.5%-8.5%
END
                )
        ]
      end

      it 'does not tweet' do
        expect(fake_twitter).to_not have_received(:update)
      end
    end

    context 'when the latest tweet has the current forecast NUMBERS but has it differently formated' do
      let(:timeline) do
        [
          double(Twitter::Tweet, text: <<END
<<END
Forecast Model Update
(Hillary vs. Donald)
Polls-plus: 74.4%-25.6%
Polls-only: 79.9%-20.1%
Now-cast: 91.5%-8.5%
https://projects.fivethirtyeight.com/2016-election-forecast/
END
                )
        ]
      end

      it 'does not tweet' do
        expect(fake_twitter).to_not have_received(:update)
      end
    end

    context 'when the latest tweet is an @-mention and the one before that is the most recent forecast' do
      let(:timeline) do
        [
          double(Twitter::Tweet, text: "@allafarce hey sup"),
          double(Twitter::Tweet, text: <<END
NEW WORDING HERE
(Hillary vs. Donald)
Polls-plus: 74.4%-25.6%
Polls-only: 79.9%-20.1%
Now-cast: 91.5%-8.5%
END
                )
        ]
      end

      it 'does not tweet' do
        expect(fake_twitter).to_not have_received(:update)
      end
    end
  end

  describe '#is_forecast?' do
    let(:bot) { FiveThirtyEightBot.new }

    context 'with the new delta-forecast format' do
      let(:forecast) do
        <<END
Update! Clinton v Trump
Polls-plus ↑ 2.3% (76.4%-24.6%)
Polls-only ↑ 2.3% (81.9%-19.1%)
Now-cast ↑ 2.3% (93.5%-6.5%)
https://projects.fivethirtyeight.com/2016-election-forecast/
END
      end

      it 'returns true' do
        expect(bot.is_forecast?(forecast)).to eq(true)
      end
    end
  end
end
