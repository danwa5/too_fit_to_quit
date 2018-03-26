require 'rails_helper'

RSpec.describe 'Api::V1::Runs', type: :request do
  let(:user) { create(:user) }
  let!(:run) { create(:activity_fitbit_run, user: user) }

  before do
    sign_in(user)
  end

  describe 'GET /api/v1/runs' do
    it 'returns a 200 status code' do
      get api_v1_runs_url, params: { format: :json }
      expect(response.status).to eq(200)
    end

    context 'when start_date parameter is given but is invalid' do
      it 'does not raise ArgumentError' do
        expect {
          get api_v1_runs_url, params: { start_date: 'abc', format: :json }
        }.not_to raise_exception(ArgumentError)
        expect(response.status).to eq(200)
      end
    end

    context 'when end_date parameter is given but is invalid' do
      it 'does not raise ArgumentError' do
        expect {
          get api_v1_runs_url, params: { end_date: 'abc', format: :json }
        }.not_to raise_exception(ArgumentError)
        expect(response.status).to eq(200)
      end
    end
  end

  describe 'GET /api/v1/runs/:id' do
    context 'when run is present' do
      it 'returns a 200 status code' do
        get api_v1_run_url(run), params: { format: :json }
        expect(response.status).to eq(200)
      end
    end

    context 'when run is not found' do
      it 'returns a 404 status code and empty json' do
        get api_v1_run_url(run.id + 1), params: { format: :json }
        expect(response.status).to eq(404)
        expect(response.body).to eq('{}')
      end
    end
  end
end
