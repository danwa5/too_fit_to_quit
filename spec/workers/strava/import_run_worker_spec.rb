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
      'elev_low' => 8.4,
      'start_latitude' => 10.01,
      'start_longitude' => 20.02,
      'location_city' => 'San Francisco',
      'location_state' => 'CA',
      'location_country' => 'United States'
    }
  end

  def run_worker
    subject.perform(user.id, activity_hash)
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
      let(:activity_hash) { { 'type' => 'Run' } }
      it 'raises RuntimeError' do
        expect {
          run_worker
        }.to raise_error(RuntimeError)
      end
    end

    context 'when Strava::CreateRunService returns failure' do
      before do
        allow(Strava::CreateRunService).to receive(:call).and_raise
      end
      it 'raises Exception' do
        expect {
          run_worker
        }.to raise_error(Exception)
      end
    end

    context 'when Strava::CreateRunService returns success' do
      it 'enqueues a Strava::ImportRunMetricsWorker' do
        expect {
          run_worker
        }.to change(Strava::ImportRunMetricsWorker.jobs, :count).by(1)
      end
    end
  end
end
