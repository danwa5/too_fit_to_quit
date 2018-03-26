require 'rails_helper'

RSpec.describe Fitbit::ImportRunTcxWorker, type: :model do
  let(:user) { create(:user) }
  let(:user_activity) { create(:user_activity, :fitbit, user: user, uid: '1234', state: 'processing') }
  let!(:activity_fitbit_run) { create(:activity_fitbit_run, user: user, user_activity: user_activity) }
  let(:tcx_data) do
    {
      'TrainingCenterDatabase' => {
        'Activities' => {
          'Activity' => {
            'Lap' => []
          }
        }
      }
    }
  end

  def make_request(response)
    stub_request(:get, %r{https://api.fitbit.com/1/user/\d+/activities/#{user_activity.uid}.tcx}).
      to_return(status: 200, body: response.to_json)
  end

  def run_worker
    subject.perform(user.id, '1234')
  end

  it { is_expected.to be_kind_of(Sidekiq::Worker) }

  describe '#perform' do
    context 'when user is not found' do
      it 'raises ActiveRecord::RecordNotFound' do
        expect {
          subject.perform((user.id + 1), 'blah')
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when user_activity is not found' do
      it 'raises ActiveRecord::RecordNotFound' do
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
      before do
        make_request(tcx_data)
        allow(FitbitService).to receive_message_chain(:get_activity_tcx, :parsed_response).and_return(tcx_data)
      end

      context 'and Fitbit::CreateRunTcxService returns failure' do
        before do
          failure = double('Failure', failure?: true)
          allow(Fitbit::CreateRunTcxService).to receive(:call).and_return(failure)
        end
        it 'raises Exception' do
          expect { run_worker }.to raise_error(Exception)
        end
      end

      context 'and Fitbit::CreateRunTcxService returns success' do
        before do
          success = double('Success', failure?: false)
          allow(Fitbit::CreateRunTcxService).to receive(:call).and_return(success)
        end
        it 'sets state to "processed" and returns true' do
          expect(run_worker).to eq(true)
          user_activity.reload
          expect(user_activity.state).to eq('processed')
        end
      end
    end
  end
end
