require 'rails_helper'

RSpec.describe 'Runs API', type: :request do
  let(:user) { create(:user) }
  let!(:identity) { create(:identity, :fitbit, user: user) }

  before do
    sign_in user
  end

  describe 'GET /api/v2/runs' do
    before do
      create(:activity_fitbit_run, user: user, steps: 99)
      create(:activity_fitbit_run, user: user, steps: 100)
      create(:activity_fitbit_run, user: user, steps: 105)
      create(:activity_fitbit_run, steps: 102)
    end

    it 'returns all data for the authenticated user' do
      get '/api/v2/runs', headers: { 'Accept': 'application/vnd.api+json' }
      json = JSON.parse(response.body)
      expect(json).not_to be_empty
      expect(json['activity/fitbit_runs'].size).to eq(3)
    end

    context 'when query parameters are given' do
      context 'single query parameter' do
        it 'returns the correct filtered data' do
          get '/api/v2/runs?steps_min=100', headers: { 'Accept': 'application/vnd.api+json' }
          json = JSON.parse(response.body)

          aggregate_failures 'returned json' do
            expect(json).not_to be_empty
            expect(json['activity/fitbit_runs'].size).to eq(2)
            expect(json['activity/fitbit_runs'][0]['steps']).to eq(100)
            expect(json['activity/fitbit_runs'][1]['steps']).to eq(105)
          end
        end
      end

      context 'multiple query parameters' do
        it 'returns the correct filtered data' do
          get '/api/v2/runs?steps_min=100&steps_max=101', headers: { 'Accept': 'application/vnd.api+json' }
          json = JSON.parse(response.body)

          aggregate_failures 'returned json' do
            expect(json).not_to be_empty
            expect(json['activity/fitbit_runs'].size).to eq(1)
            expect(json['activity/fitbit_runs'][0]['steps']).to eq(100)
          end
        end
      end
    end
  end
end
