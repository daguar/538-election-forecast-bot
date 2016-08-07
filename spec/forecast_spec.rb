require 'forecast'

RSpec.describe Forecast do
  describe '::from_tweet' do
    context 'given a new delta tweet' do
      let(:tweet_text) do
        <<END
Update! Clinton v Trump
Polls-plus ↑ 2.3% (76.4%-24.6%)
Polls-only ↑ 2.3% (81.9%-19.1%)
Now-cast ↑ 2.3% (93.5%-6.5%)
https://projects.fivethirtyeight.com/2016-election-forecast/
END
      end
      let(:forecast) { Forecast.from_tweet(tweet_text) }

      it 'gets the hillary_polls_plus' do
        expect(forecast.hillary_polls_plus).to eq(76.4)
      end

      it 'gets the hillary_polls_only' do
        expect(forecast.hillary_polls_only).to eq(81.9)
      end

      it 'gets the hillary_polls_now' do
        expect(forecast.hillary_polls_now).to eq(93.5)
      end

      it 'gets the donald_polls_plus' do
        expect(forecast.donald_polls_plus).to eq(24.6)
      end

      it 'gets the donald_polls_only' do
        expect(forecast.donald_polls_only).to eq(19.1)
      end

      it 'gets the donald_polls_now' do
        expect(forecast.donald_polls_now).to eq(6.5)
      end
    end

    context 'given the old tweet style' do
      let(:tweet_text) do
        <<END
Forecast Model Update
(Hillary vs. Donald)
Polls-plus: 76.4%-24.6%
Polls-only: 81.9%-19.1%
Now-cast: 93.5%-6.5%
https://projects.fivethirtyeight.com/2016-election-forecast/
END
      end
      let(:forecast) { Forecast.from_tweet(tweet_text) }

      it 'gets the hillary_polls_plus' do
        expect(forecast.hillary_polls_plus).to eq(76.4)
      end

      it 'gets the hillary_polls_only' do
        expect(forecast.hillary_polls_only).to eq(81.9)
      end

      it 'gets the hillary_polls_now' do
        expect(forecast.hillary_polls_now).to eq(93.5)
      end

      it 'gets the donald_polls_plus' do
        expect(forecast.donald_polls_plus).to eq(24.6)
      end

      it 'gets the donald_polls_only' do
        expect(forecast.donald_polls_only).to eq(19.1)
      end

      it 'gets the donald_polls_now' do
        expect(forecast.donald_polls_now).to eq(6.5)
      end
    end
  end
end
