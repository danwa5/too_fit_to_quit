require 'rails_helper'

RSpec.describe Fitbit::ImportRunTcxWorker, type: :model do
  let(:user) { create(:user) }
  let!(:identity) { create(:identity, :fitbit, user: user) }
  let(:user_activity) { create(:user_activity, :fitbit, user: user, uid: '1234') }
  let!(:activity_fitbit_run) { create(:activity_fitbit_run, user: user, user_activity: user_activity) }

  def make_request(response)
    stub_request(:get, /https:\/\/api.fitbit.com\/1\/user\/\d+\/activities\/#{user_activity.uid}.tcx/).
      to_return(status: 200, body: response.to_json)
  end

  it { is_expected.to be_kind_of(Sidekiq::Worker) }

  describe '#perform' do
    context 'when user is nil' do
      it 'returns false' do
        expect(subject.perform((user.id + 1), 'blah')).to be_falsey
      end
    end

    context 'when user_activity is nil' do
      it 'returns false' do
        expect(subject.perform(user.id, 'blah')).to be_falsey
      end
    end

    context 'when no data is returned' do
      it 'returns false' do
        make_request(nil)
        expect(subject.perform(user.id, '1234')).to be_falsey
      end
    end

    context 'when data is returned' do
      let(:response) do
        {
          'TrainingCenterDatabase' => {
            'Activities' => {
              'Activity' => {
                'Lap' => [
                  {
                    'Track' => {
                      'Trackpoint' => [{
                        'Position' => {
                          'LatitudeDegrees' => 12.34,
                          'LongitudeDegrees' => -98.76
                        }
                      }]
                    }
                  }
                ]
              }
            }
          }
        }
      end

      before do
        make_request(response)
        allow(FitbitService).to receive_message_chain(:get_activity_tcx, :parsed_response).and_return(response)
      end

      it 'saves tcx data' do
        expect(user_activity.activity.tcx_data).to be_nil
        subject.perform(user.id, '1234')
        user_activity.activity.reload
        expect(user_activity.activity.tcx_data).to be_present
      end

      it 'saves gps data' do
        expect(user_activity.activity.gps_data).to be_nil
        subject.perform(user.id, '1234')
        user_activity.activity.reload
        expect(user_activity.activity.gps_data).to eq({'coordinates' => [[-98.76,12.34]]})
      end

      it 'returns true' do
        expect(subject.perform(user.id, '1234')).to be_truthy
      end
    end
  end
end
