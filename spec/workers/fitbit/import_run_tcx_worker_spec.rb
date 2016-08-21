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
        expect(subject.perform((user.id + 1), 'blah')).to eq(false)
      end
    end

    context 'when user_activity is nil' do
      it 'returns false' do
        expect(subject.perform(user.id, 'blah')).to eq(false)
      end
    end

    context 'when no data is returned' do
      it 'returns false' do
        make_request(nil)
        expect(subject.perform(user.id, '1234')).to eq(false)
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
                      'Trackpoint' => [
                        {
                          'Time' => '2016-07-23T11:08:00.000-07:00',
                          'Position' => {
                            'LatitudeDegrees' => 37.7749,
                            'LongitudeDegrees' => -122.4194
                          },
                          'DistanceMeters' => 0.0,
                          'AltitudeMeters' => 22.34,
                          'HeartRateBpm' => {
                            'Value' => 85
                          }
                        },
                        {
                          'Time' => '2016-07-23T11:08:10.000-07:00',
                          'Position' => {
                            'LatitudeDegrees' => 43.6532,
                            'LongitudeDegrees' => -79.3832
                          },
                          'DistanceMeters' => 1.0,
                          'AltitudeMeters' => 25.60,
                          'HeartRateBpm' => {
                            'Value' => 90
                          }
                        },
                        {
                          'Time' => '2016-07-23T11:08:20.000-07:00',
                          'Position' => {
                            'LatitudeDegrees' => 40.7128,
                            'LongitudeDegrees' => -74.0059
                          },
                          'DistanceMeters' => 2.0,
                          'AltitudeMeters' => 26.12,
                          'HeartRateBpm' => {
                            'Value' => 95
                          }
                        }
                      ]
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

      it 'saves gps data - datetime, coordinates, distance, altitudes, heart rates, and bounds' do
        expect(user_activity.activity.gps_data).to be_nil
        subject.perform(user.id, '1234')
        user_activity.activity.reload
        expect(user_activity.activity.gps_data).to eq(
          {
            'raw' => [
              { 'datetime' => '2016-07-23T11:08:00.000-07:00', 'coordinate' => [-122.4194,37.7749], 'distance' => 0.0, 'altitude' => 22.34, 'heart_rate' => 85 },
              { 'datetime' => '2016-07-23T11:08:20.000-07:00', 'coordinate' => [-74.0059,40.7128], 'distance' => 2.0, 'altitude' => 26.12, 'heart_rate' => 95 }
            ],
            'derived' => {
              'bounds' => {
                'north' => 43.6532,
                'east' => -74.0059,
                'south' => 37.7749,
                'west' => -122.4194
              }
            }
          }
        )
      end

      it 'returns true' do
        expect(subject.perform(user.id, '1234')).to eq(true)
      end
    end
  end
end
