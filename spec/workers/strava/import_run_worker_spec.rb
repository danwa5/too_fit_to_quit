require 'rails_helper'

RSpec.describe Strava::ImportRunWorker, type: :model do
  let(:user) { create(:user) }
  let(:activity_hash) do
    {
      'id' => 101,
      'type' => 'Run',
      'distance' => 14620.6,
      'moving_time' => 4111,
      'start_date' => '2016-07-17T22:28:43',
      'total_elevation_gain' => 65.0,
      'elev_high' => 31.0,
      'elev_low' => 8.4
    }
  end

  it { is_expected.to be_kind_of(Sidekiq::Worker) }

  describe '#perform' do
    context 'when user is nil' do
      it 'returns false' do
        expect(subject.perform(nil, nil)).to be_falsey
      end
    end

    context 'when activity hash does not contain all required keys' do
      let(:activity_hash) { { 'type' => 'Run' } }
      it 'returns false' do
        expect(subject.perform(user.id, activity_hash)).to be_falsey
      end
    end

    context 'when activity hash is imported for the first time' do
      it 'creates a new UserActivity record' do
        expect {
          subject.perform(user.id, activity_hash)
        }.to change(UserActivity, :count).by(1)
      end

      it 'creates a new Activity::StravaRun record' do
        expect {
          subject.perform(user.id, activity_hash)
        }.to change(Activity::StravaRun, :count).by(1)
      end

      it 'creates a new UserActivity record with the correct attributes' do
        subject.perform(user.id, activity_hash)
        user_activity = UserActivity.last
        expect(user_activity.activity_type).to eq('Activity::StravaRun')
        expect(user_activity.uid).to eq('101')
        expect(user_activity.user_id).to eq(user.id)
        expect(user_activity.distance).to eq(14620.6)
        expect(user_activity.duration).to eq(4111)
        expect(user_activity.start_time).to eq('2016-07-17T22:28:43')
        expect(user_activity.activity_data).to be_present
      end

      it 'creates a new Activity::StravaRun record with the correct attributes' do
        subject.perform(user.id, activity_hash)
        strava_run = Activity::StravaRun.last
        expect(strava_run.user_id).to eq(user.id)
        expect(strava_run.total_elevation_gain).to eq(65.0)
        expect(strava_run.elevation_high).to eq(31.0)
        expect(strava_run.elevation_low).to eq(8.4)
      end

      it 'returns true' do
        expect(subject.perform(user.id, activity_hash)).to be_truthy
      end
    end

    context 'when activity hash is imported after the first time' do
      let(:user_activity) do
        create(:user_activity, :strava,
          user: user,
          uid: '101',
          distance: 0,
          duration: 0,
          start_time: '2016-07-10 00:00:00',
          activity_data: nil
        )
      end

      let!(:strava_run) do
        create(:activity_strava_run,
          user_activity: user_activity,
          user: user,
          total_elevation_gain: 0,
          elevation_high: 0,
          elevation_low: 0
        )
      end

      it 'does not create a new UserActivity record' do
        expect {
          subject.perform(user.id, activity_hash)
        }.not_to change(UserActivity, :count)
      end

      it 'does not create a new Activity::StravaRun record' do
        expect {
          subject.perform(user.id, activity_hash)
        }.not_to change(Activity::StravaRun, :count)
      end

      it 'updates UserActivity with the correct attributes' do
        subject.perform(user.id, activity_hash)
        user_activity.reload
        expect(user_activity.activity_type).to eq('Activity::StravaRun')
        expect(user_activity.uid).to eq('101')
        expect(user_activity.distance).to eq(14620.6)
        expect(user_activity.duration).to eq(4111)
        expect(user_activity.start_time).to eq('2016-07-17T22:28:43')
        expect(user_activity.activity_data).to be_present
      end

      it 'updates Activity::StravaRun with the correct attributes' do
        subject.perform(user.id, activity_hash)
        strava_run.reload
        expect(strava_run.user_id).to eq(user.id)
        expect(strava_run.total_elevation_gain).to eq(65.0)
        expect(strava_run.elevation_high).to eq(31.0)
        expect(strava_run.elevation_low).to eq(8.4)
      end
    end
  end
end
