require 'rails_helper'

RSpec.describe Fitbit::CreateRunService do
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

  subject { described_class.new(user: user, activity_hash: activity_hash) }

  it { is_expected.to be_kind_of(Services::BaseService) }

  def service_call
    described_class.call(user: user, activity_hash: activity_hash)
  end

  describe '.call' do
    context 'when activity hash is imported for the first time' do
      it 'creates a new UserActivity record' do
        expect {
          service_call
        }.to change(UserActivity, :count).by(1)
      end

      it 'creates a new Activity::FitbitRun record' do
        expect {
          service_call
        }.to change(Activity::FitbitRun, :count).by(1)
      end

      it 'creates a new UserActivity record with the correct attributes' do
        service_call
        user_activity = UserActivity.last
        aggregate_failures 'user activity attributes' do
          expect(user_activity.activity_type).to eq('Activity::FitbitRun')
          expect(user_activity.uid).to eq('1234567890')
          expect(user_activity.user_id).to eq(user.id)
          expect(user_activity.distance).to eq(14677.219)
          expect(user_activity.duration).to eq(4113)
          expect(user_activity.start_time).to eq('2016-07-17 22:28:43')
          expect(user_activity.start_time_rounded_epoch).to eq(DateTime.parse(activity_hash['startTime']).to_i / 240)
          expect(user_activity.activity_data).to be_present
        end
      end

      it 'creates a new Activity::FitbitRun record with the correct attributes' do
        service_call
        fitbit_run = Activity::FitbitRun.last
        aggregate_failures 'run attributes' do
          expect(fitbit_run.user_id).to eq(user.id)
          expect(fitbit_run.activity_type_id).to eq(90009)
          expect(fitbit_run.steps).to eq(12000)
        end
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
          service_call
        }.not_to change(UserActivity, :count)
      end

      it 'does not create a new Activity::FitbitRun record' do
        expect {
          service_call
        }.not_to change(Activity::FitbitRun, :count)
      end

      it 'updates UserActivity with the correct attributes' do
        service_call
        user_activity.reload
        aggregate_failures 'user activity attributes' do
          expect(user_activity.activity_type).to eq('Activity::FitbitRun')
          expect(user_activity.uid).to eq('1234567890')
          expect(user_activity.distance).to eq(14677.219)
          expect(user_activity.duration).to eq(4113)
          expect(user_activity.start_time).to eq('2016-07-17 22:28:43')
          expect(user_activity.activity_data).to be_present
        end
      end

      it 'updates Activity::FitbitRun with the correct attributes' do
        service_call
        fitbit_run.reload
        aggregate_failures 'run attributes' do
          expect(fitbit_run.user_id).to eq(user.id)
          expect(fitbit_run.activity_type_id).to eq(90009)
          expect(fitbit_run.steps).to eq(12000)
        end
      end
    end
  end
end
