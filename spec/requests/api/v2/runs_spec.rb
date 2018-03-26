require 'rails_helper'

RSpec.describe Api::V2::RunsController, type: :request do
  let(:user) { create(:user) }

  before do
    sign_in(user)
  end

  describe 'GET /api/v2/runs' do
    before do
      create(:activity_fitbit_run, user: user, steps: 99)
      create(:activity_fitbit_run, user: user, steps: 100)
      create(:activity_fitbit_run, user: user, steps: 105)
      create(:activity_fitbit_run, steps: 102)
    end

    it 'returns all data for the authenticated user' do
      get api_v2_runs_url, headers: { 'Accept': 'application/vnd.api+json' }
      json = JSON.parse(response.body)
      expect(json).not_to be_empty
      expect(json['activity/fitbit_runs'].size).to eq(3)
    end

    context 'when steps_min parameter is given' do
      it 'returns the correct filtered data' do
        get api_v2_runs_url, params: { steps_min: 100 }, headers: { 'Accept': 'application/vnd.api+json' }
        json = JSON.parse(response.body)

        steps = []
        steps << json['activity/fitbit_runs'][0]['steps']
        steps << json['activity/fitbit_runs'][1]['steps']

        aggregate_failures 'returned json' do
          expect(json).not_to be_empty
          expect(json['activity/fitbit_runs'].size).to eq(2)
          expect(steps).to include(100, 105)
        end
      end
    end

    context 'when both steps_min and steps_max parameters are given' do
      it 'returns the correct filtered data' do
        get api_v2_runs_url, params: { steps_min: 100, steps_max: 101 }, headers: { 'Accept': 'application/vnd.api+json' }
        json = JSON.parse(response.body)

        aggregate_failures 'returned json' do
          expect(json).not_to be_empty
          expect(json['activity/fitbit_runs'].size).to eq(1)
          expect(json['activity/fitbit_runs'][0]['steps']).to eq(100)
        end
      end
    end

    context 'when start_date parameter is given but is invalid' do
      it 'does not raise ArgumentError' do
        expect {
          get api_v2_runs_url, params: { start_date: 'abc' }
        }.not_to raise_error(ArgumentError)
        expect(response.status).to eq(200)
      end
    end

    context 'when end_date parameter is given but is invalid' do
      it 'does not raise ArgumentError' do
        expect {
          get api_v2_runs_url, params: { end_date: 'abc' }
        }.not_to raise_error(ArgumentError)
        expect(response.status).to eq(200)
      end
    end
  end
end
