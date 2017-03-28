require "rails_helper"

RSpec.describe StepsController, :type => :controller do
  login_user

  def make_request(date, period, res)
    stub_request(:get, %r{https://api.fitbit.com/1/user/\d+/activities/steps/date/#{date}/#{period}.json}).
      to_return(status: 200, body: res.to_json)
  end

  it 'must have a current_user' do
    expect(subject.current_user).to_not eq(nil)
  end

  describe 'GET index' do
    context 'without period or date search parameter' do
      it 'has a 200 status code' do
        get :index
        expect(response.status).to eq(200)
      end
    end

    context 'with period and date search parameter' do
      let(:user) { subject.current_user }
      let!(:identity) { create(:identity, :fitbit, user: user) }
      let(:date) { Date.today.strftime('%Y-%m-%d') }
      let(:period) { %w(1d 1w 1m 1y).sample }

      context 'resulting in unsuccessful response' do
        res = { 'success' => false }
        it 'has a 200 status code' do
          make_request(date, period, res)
          get :index, steps: period, after_date: date
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
          get :index, steps: period, after_date: date
          expect(response.status).to eq(200)
        end
      end
    end
  end
end
