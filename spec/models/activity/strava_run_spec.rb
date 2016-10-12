require 'rails_helper'

RSpec.describe Activity::StravaRun, type: :model do
  let(:user) { create(:user) }
  let(:user_activity) { create(:user_activity, :strava, user: user) }
  let(:run) { create(:activity_strava_run, user: user, user_activity: user_activity, start_latitude: -10, start_longitude: 20, city: 'SF', state_province: 'CA') }

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_one(:user_activity) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to validate_presence_of(:user_activity) }
  end

  describe '#start_coordinate' do
    context 'when both start_latitude and start_longitude are present' do
      it { expect(run.start_coordinate).to eq([20,-10]) }
    end
    context 'when start_latitude and/or start_longitude is nil' do
      let(:run) { create(:activity_strava_run, user: user, user_activity: user_activity, start_latitude: nil, start_longitude: nil) }
      it { expect(run.start_coordinate).to be_nil }
    end
  end

  describe '#location' do
    context 'when city and state/province are present' do
      it { expect(run.location).to eq('in SF, CA') }
    end
    context 'when city and state/province are nil' do
      let(:run) { create(:activity_strava_run, user: user, user_activity: user_activity, city: nil, state_province: nil) }
      it { expect(run.location).to eq('') }
    end
  end
end
