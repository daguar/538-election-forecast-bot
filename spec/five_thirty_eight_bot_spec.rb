require 'five_thirty_eight_bot'

RSpec.describe FiveThirtyEightBot do
  describe '#tweet_if_new_forecast' do
    let(:bot) { FiveThirtyEightBot.new }
    let(:fake_twitter) { double(Twitter::REST::Client, home_timeline: fake_timeline, update: true) }
    let(:fake_timeline) { [double(Twitter::Tweet, text: last_tweet)] }

    before do
      allow(HTTParty).to receive(:get).and_call_original
      allow(Twitter::REST::Client).to receive(:new).and_return(fake_twitter)

      VCR.use_cassette('fivethirtyeight') do
        bot.tweet_if_new_forecast
      end
    end

    context 'when the latest tweet does not have the latest forecast' do
      let(:last_tweet) { 'Hello World' }

      it 'downloads the 538 predictions page' do
        expect(HTTParty).to have_received(:get).with('https://projects.fivethirtyeight.com/2016-election-forecast/')
      end

      it 'tweets the update' do
        status = <<END
Forecast Model Update
(Hillary vs. Donald)
Polls-plus: 60.9% to 39.1%
Polls-only: 51.0% to 49.0%
Now-cast: 56.8% to 43.2%
END
        expect(fake_twitter).to have_received(:update).with(status)
      end
    end

    context 'when the latest tweet has the current forecast' do
      let(:last_tweet) do
<<END
Forecast Model Update
(Hillary vs. Donald)
Polls-plus: 60.9% to 39.1%
Polls-only: 51.0% to 49.0%
Now-cast: 56.8% to 43.2%
END
      end

      it 'does not tweet' do
        expect(fake_twitter).to_not have_received(:update)
      end
    end

    context 'when the latest tweet has the current forecast but has somewhat different words' do
      let(:last_tweet) do
<<END
NEW WORDING HERE
(Hillary vs. Donald)
Polls-plus: 60.9% to 39.1%
Polls-only: 51.0% to 49.0%
Now-cast: 56.8% to 43.2%
END
      end

      it 'does not tweet' do
        expect(fake_twitter).to_not have_received(:update)
      end
    end

    context 'when the latest tweet is an @-mention and the one before that is the most recent forecast' do
      let(:fake_timeline) do
        [
          double(Twitter::Tweet, text: "@allafarce hey sup"),
          double(Twitter::Tweet, text: <<END
NEW WORDING HERE
(Hillary vs. Donald)
Polls-plus: 60.9% to 39.1%
Polls-only: 51.0% to 49.0%
Now-cast: 56.8% to 43.2%
END
                )
        ]
      end

      it 'does not tweet' do
        expect(fake_twitter).to_not have_received(:update)
      end
    end
  end
end
