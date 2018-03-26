require 'rails_helper'

RSpec.describe Strava::ImportRunMetricsWorker, type: :model do
  let(:user) { create(:user) }
  let(:user_activity) { create(:user_activity, :strava, user: user, uid: '1234', state: 'processing') }
  let!(:activity_strava_run) { create(:activity_strava_run, user: user, user_activity: user_activity) }

  def make_request(response)
    stub_request(:get, %r{https://www.strava.com/api/v3/activities/#{user_activity.uid}}).
      to_return(status: 200, body: response.to_json)
  end

  def run_worker
    subject.perform(user.id, '1234')
  end

  it { is_expected.to be_kind_of(Sidekiq::Worker) }

  describe '#perform' do
    context 'when user is not found' do
      it 'returns ActiveRecord::RecordNotFound' do
        expect {
          subject.perform((user.id + 1), 'blah')
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when user_activity is not found' do
      it 'returns ActiveRecord::RecordNotFound' do
        expect {
          subject.perform(user.id, 'fake_uid')
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when user_activity has a state besides "processing"' do
      let_override(:user_activity) { |ua| ua.state = %w(pending processed).sample }
      it 'returns false' do
        expect(run_worker).to eq(false)
      end
    end

    context 'when no data is returned' do
      it 'returns false' do
        make_request(nil)
        expect(run_worker).to eq(false)
      end
    end

    context 'when data is returned' do
      let(:response) do
        {
          'id' => 1234,
          'type' => 'Run',
          'distance' => 14620.6,
          'start_date' => '2016-07-17T22:28:43',
          'splits_metric' => [
            {
              'distance' => 1003.1,
              'elapsed_time' => 260,
              'elevation_difference' => -3.1,
              'moving_time' => 260,
              'split' => 1
            }
          ],
          'splits_standard' => [
            {
              'distance' => 1609.5,
              'elapsed_time' => 418,
              'elevation_difference' => -3.6,
              'moving_time' => 418,
              'split' => 1
            }
          ]
        }
      end

      before do
        make_request(response)
        allow(StravaService).to receive_message_chain(:get_activity, :parsed_response).and_return(response)
      end

      it 'saves splits data' do
        expect(user_activity.activity.splits['standard']).to be_empty
        run_worker
        user_activity.activity.reload
        expect(user_activity.activity.splits).to eq(
          {
            'metric' => [
              {
                'distance' => 1003.1,
                'elapsed_time' => 260,
                'elevation_difference' => -3.1,
                'moving_time' => 260,
                'split' => 1
              }
            ],
            'standard' => [
              {
                'distance' => 1609.5,
                'elapsed_time' => 418,
                'elevation_difference' => -3.6,
                'moving_time' => 418,
                'split' => 1
              }
            ]
          }
        )
      end

      it 'sets state to "processed" and returns true' do
        expect(run_worker).to eq(true)
        user_activity.reload
        expect(user_activity.state).to eq('processed')
      end
    end
  end
end
