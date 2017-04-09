require 'rails_helper'

RSpec.describe Api::RunsController, type: :controller do
  let(:user_activity) { create(:user_activity, :fitbit) }
  let!(:run) { create(:activity_fitbit_run, user_activity: user_activity) }

  login_user

  describe 'GET index' do
    it 'returns a 200 status code' do
      get :index, format: :json
      expect(response.status).to eq(200)
    end
  end

  describe 'GET show' do
    context 'when run is present' do
      it 'returns a 200 status code' do
        get :show, id: run.id, format: :json
        expect(response.status).to eq(200)
      end
    end

    context 'when run is not found' do
      it 'returns a 404 status code and empty json' do
        get :show, id: run.id + 1, format: :json
        expect(response.status).to eq(404)
        expect(response.body).to eq('{}')
      end
    end
  end

end
