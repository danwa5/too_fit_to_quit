require 'rails_helper'

RSpec.describe RunsController, :type => :controller do
  login_user

  it 'must have a current_user' do
    expect(subject.current_user).to_not eq(nil)
  end

  describe 'GET index' do
    context 'without after_date search parameter' do
      it 'has a 200 status code' do
        get :index
        expect(response.status).to eq(200)
      end
    end
    context 'with after_date search parameter' do
      it 'has a 200 status code' do
        get :index, after_date: Date.today.strftime('%Y-%m-%d')
        expect(response.status).to eq(200)
      end
    end
  end

  describe 'GET show' do
    context 'when parameter is valid' do
      let(:user) { subject.current_user }
      let(:user_activity) { create(:user_activity, :fitbit, user: user) }
      let!(:run) { create(:activity_fitbit_run, :with_gps_data, user: user, user_activity: user_activity) }

      it 'has a 200 status code' do
        get :show, id: user_activity.id
        expect(response.status).to eq(200)
      end
    end
    context 'when parameter is invalid' do
      it 'redirects to runs index path' do
        get :show, id: 'a'
        expect(response.status).to redirect_to(runs_path)
      end
    end
  end
end
