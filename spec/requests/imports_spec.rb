require 'rails_helper'

RSpec.describe 'Imports', type: :request do
  let(:user) { create(:user) }

  before do
    sign_in(user)
  end

  describe 'POST /imports' do
    context 'when user is authenticated' do
      context 'and import_date parameter is not given' do
        it 'must not enqueue Fitbit::FindActivityWorker' do
          expect {
            post imports_url
          }.not_to change(Fitbit::FindActivityWorker.jobs, :count)
        end
        it 'must not enqueue Strava::FindActivityWorker' do
          expect {
            post imports_url
          }.not_to change(Strava::FindActivityWorker.jobs, :count)
        end
      end

      context 'and import_date parameter is not correctly formatted' do
        it 'must not enqueue Fitbit::FindActivityWorker' do
          expect {
            post imports_url, params: { import_date: '123' }
          }.not_to change(Fitbit::FindActivityWorker.jobs, :count)
        end
        it 'must not enqueue Strava::FindActivityWorker' do
          expect {
            post imports_url, params: { import_date: '123' }
          }.not_to change(Strava::FindActivityWorker.jobs, :count)
        end
      end

      context 'and import_date parameter is correctly formatted' do
        subject { post imports_url, params: { import_date: Date.today.strftime('%Y-%m-%d') } }

        it 'must enqueue Fitbit::FindActivityWorker' do
          expect { subject }.to change(Fitbit::FindActivityWorker.jobs, :count).by(1)
        end
        it 'must enqueue Strava::FindActivityWorker' do
          expect { subject }.to change(Strava::FindActivityWorker.jobs, :count).by(1)
        end
        it 'must redirect to /runs with success message' do
          expect(subject).to redirect_to(runs_path)
          expect(flash[:notice]).to be_present
        end
      end
    end

    context 'when user authentication is expired' do
      before do
        identity = user.identities.first
        identity.expires_at = Date.yesterday.end_of_day.to_i
        identity.save
      end
      it 'must redirect user with flash message' do
        expect(post imports_url).to redirect_to(runs_path)
        expect(flash[:alert]).to eq('Please re-authenticate with Fitbit before attempting to import data.')
      end
    end
  end
end
