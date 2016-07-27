require 'rails_helper'

RSpec.describe ImportFitbitRunWorker, type: :model do
  let(:user) { create(:user) }
  let(:activity_hash) do
    {
      'activeDuration' => 4113000,
      'activityName' => 'Run',
      'activityTypeId' => 90009,
      'distance' => 14.677219,
      'distanceUnit' => 'Kilometer',
      'logId' => 1234567890,
      'startTime' => '2016-07-17T15:28:43.000-07:00',
      'steps' => 12000,
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
      let(:activity_hash) { { 'activityName' => 'Run' } }
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

      it 'creates a new Activity::FitbitRun record' do
        expect {
          subject.perform(user.id, activity_hash)
        }.to change(Activity::FitbitRun, :count).by(1)
      end

      it 'creates a new UserActivity record with the correct attributes' do
        subject.perform(user.id, activity_hash)
        user_activity = UserActivity.last
        expect(user_activity.activity_type).to eq('Activity::FitbitRun')
        expect(user_activity.uid).to eq('1234567890')
        expect(user_activity.user_id).to eq(user.id)
        expect(user_activity.distance).to eq(14677.219)
        expect(user_activity.duration).to eq(4113)
        expect(user_activity.start_time).to eq('2016-07-17 22:28:43')
        expect(user_activity.activity_data).to be_present
      end

      it 'creates a new UserActivity record with the correct attributes' do
        subject.perform(user.id, activity_hash)
        fitbit_run = Activity::FitbitRun.last
        expect(fitbit_run.user_id).to eq(user.id)
        expect(fitbit_run.activity_type_id).to eq(90009)
        expect(fitbit_run.steps).to eq(12000)
      end

      it 'enqueues a ImportFitbitRunTcxWorker' do
        expect {
          subject.perform(user.id, activity_hash)
        }.to change(ImportFitbitRunTcxWorker.jobs, :count).by(1)
      end

      it 'returns true' do
        expect(subject.perform(user.id, activity_hash)).to be_truthy
      end
    end

    context 'when activity hash is imported after the first time' do
      let(:user_activity) do
        create(:user_activity, :fitbit,
          user: user,
          uid: '1234567890',
          distance: 0,
          duration: 0,
          start_time: '2016-07-10 00:00:00',
          activity_data: nil
        )
      end

      let!(:fitbit_run) do
        create(:activity_fitbit_run,
          user_activity: user_activity,
          user: user,
          activity_type_id: 0,
          steps: 0
        )
      end

      it 'does not create a new UserActivity record' do
        expect {
          subject.perform(user.id, activity_hash)
        }.not_to change(UserActivity, :count)
      end

      it 'does not create a new Activity::FitbitRun record' do
        expect {
          subject.perform(user.id, activity_hash)
        }.not_to change(Activity::FitbitRun, :count)
      end

      it 'updates UserActivity with the correct attributes' do
        subject.perform(user.id, activity_hash)
        user_activity.reload
        expect(user_activity.activity_type).to eq('Activity::FitbitRun')
        expect(user_activity.uid).to eq('1234567890')
        expect(user_activity.distance).to eq(14677.219)
        expect(user_activity.duration).to eq(4113)
        expect(user_activity.start_time).to eq('2016-07-17 22:28:43')
        expect(user_activity.activity_data).to be_present
      end

      it 'updates Activity::FitbitRun with the correct attributes' do
        subject.perform(user.id, activity_hash)
        fitbit_run.reload
        expect(fitbit_run.user_id).to eq(user.id)
        expect(fitbit_run.activity_type_id).to eq(90009)
        expect(fitbit_run.steps).to eq(12000)
      end
    end
  end
end
