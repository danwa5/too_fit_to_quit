require "rails_helper"

RSpec.describe StepsController, type: :request do
  let(:user) { create(:user) }

  before do
    sign_in(user)
  end

  def make_request(date, period, res)
    stub_request(:get, %r{https://api.fitbit.com/1/user/\d+/activities/steps/date/#{date}/#{period}.json}).
      to_return(status: 200, body: res.to_json)
  end

  describe 'GET /steps' do
    context 'when period or date search parameter is not given' do
      it 'has a 200 status code' do
        get steps_url
        expect(response.status).to eq(200)
      end
    end

    context 'when period and date search parameters are given' do
      let(:date) { Date.today.strftime('%Y-%m-%d') }
      let(:period) { %w(1d 1w 1m 1y).sample }

      context 'resulting in unsuccessful response' do
        res = { 'success' => false }
        it 'has a 200 status code' do
          make_request(date, period, res)
          get steps_url, params: { steps: period, after_date: date }
          expect(response.status).to eq(200)
        end
      end

      context 'resulting in successful response' do
        let(:res) do
          {
            'activities-steps' => [
              { 'dateTime' => date, 'value' => '123' }
            ]
          }
        end
        it 'has a 200 status code' do
          make_request(date, period, res)
          get steps_url, params: { steps: period, after_date: date }
          expect(response.status).to eq(200)
        end
      end
    end
  end
end
