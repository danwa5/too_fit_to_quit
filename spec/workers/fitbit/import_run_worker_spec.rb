require 'rails_helper'

RSpec.describe Fitbit::ImportRunWorker, type: :model do
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
      'steps' => 12000
    }
  end

  it { is_expected.to be_kind_of(Sidekiq::Worker) }

  describe '#perform' do
    context 'when user is not found' do
      it 'raises ActiveRecord::RecordNotFound' do
        expect {
          subject.perform(nil, nil)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when activity hash does not contain all required keys' do
      let(:activity_hash) { { 'activityName' => 'Run' } }
      it 'raises RuntimeError' do
        expect {
          subject.perform(user.id, activity_hash)
        }.to raise_error(RuntimeError)
      end
    end

    context 'when Fitbit::CreateRunService returns failure' do
      it 'raises an exception' do
        # allow(Fitbit::CreateRunService).to receive(:call).and_return(Dry::Monads::Try::Failure)
        expect {
          subject.perform(user.id, nil)
        }.to raise_error(StandardError)
      end
    end

    context 'when Fitbit::CreateRunService returns success' do
      it 'enqueues a Fitbit::ImportRunTcxWorker' do
        # allow(Fitbit::CreateRunService).to receive(:call).and_return(Dry::Monads::Try::Success)
        expect {
          subject.perform(user.id, activity_hash)
        }.to change(Fitbit::ImportRunTcxWorker.jobs, :count).by(1)
      end
    end
  end
end
