require 'rails_helper'

RSpec.describe RunsController, type: :request do
  let(:user) { create(:user) }
  let!(:run) { create(:activity_fitbit_run, :with_gps_data, user: user, user_activity: create(:user_activity, :fitbit, user: user)) }
  let!(:run_s) { create(:activity_strava_run, user: user, user_activity: create(:user_activity, :strava, user: user)) }

  before do
    sign_in(user)
  end

  describe 'GET /runs' do
    context 'without after_date search parameter' do
      it 'has a 200 status code' do
        get runs_url
        expect(response.status).to eq(200)
      end
    end
    context 'with after_date search parameter' do
      it 'has a 200 status code' do
        get runs_url, params: { after_date: Date.today.strftime('%Y-%m-%d') }
        expect(response.status).to eq(200)
      end
    end
  end

  describe 'GET /runs/:id' do
    context 'when parameter is valid' do
      context 'and format is html' do
        it 'returns a 200 status code' do
          get run_url(run.user_activity.id), params: { format: :html }
          expect(response.status).to eq(200)
        end
      end
      context 'and format is json' do
        it 'returns a json with the correct keys' do
          get run_url(run.user_activity.id), params: { format: :json }
          parsed_response = JSON.parse(response.body)
          expect(parsed_response.keys).to eq(%w(route points bounds))
        end
      end
    end
    context 'when parameter is invalid' do
      it 'redirects to runs index path' do
        get run_url(run.user_activity.id + 1), params: { format: :json }
        expect(response.status).to redirect_to(runs_path)
      end
    end
  end
end
