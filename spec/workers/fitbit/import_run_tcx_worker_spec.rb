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
                            'LatitudeDegrees' => 11.1111,
                            'LongitudeDegrees' => -22.2222
                          },
                          'DistanceMeters' => 0.0,
                          'AltitudeMeters' => 22.34,
                          'HeartRateBpm' => {
                            'Value' => 85
                          }
                        }
                      ]
                    }
                  },
                  {
                    'Track' => {
                      'Trackpoint' => [
                        {
                          'Time' => '2016-07-23T11:08:10.000-07:00',
                          'Position' => {
                            'LatitudeDegrees' => 33.3333,
                            'LongitudeDegrees' => -44.4444
                          },
                          'DistanceMeters' => 0.0,
                          'AltitudeMeters' => 26.62,
                          'HeartRateBpm' => {
                            'Value' => 88
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
      let(:geocode) { double(city: 'San Francisco', state: 'California', country: 'United States') }

      before do
        make_request(response)
        allow(FitbitService).to receive_message_chain(:get_activity_tcx, :parsed_response).and_return(response)
        allow(Geocoder).to receive_message_chain(:search, :first).and_return(geocode)
      end

      it 'saves tcx data' do
        expect(user_activity.activity.tcx_data).to be_nil
        subject.perform(user.id, '1234')
        user_activity.activity.reload
        expect(user_activity.activity.tcx_data).to be_present
      end

      it 'saves gps data - datetime, coordinates, distance, altitudes, heart rates, bounds, and markers' do
        expect(user_activity.activity.gps_data).to be_nil
        subject.perform(user.id, '1234')
        user_activity.activity.reload
        expect(user_activity.activity.gps_data).to eq(
          {
            'raw' => [
              { 'datetime' => '2016-07-23T11:08:00.000-07:00', 'coordinate' => [-22.2222, 11.1111], 'distance' => 0.0, 'altitude' => 22.34, 'heart_rate' => 85 },
              { 'datetime' => '2016-07-23T11:08:10.000-07:00', 'coordinate' => [-44.4444, 33.3333], 'distance' => 0.0, 'altitude' => 26.62, 'heart_rate' => 88 }
            ],
            'derived' => {
              'bounds' => {
                'north' => 33.3333,
                'east' => -22.2222,
                'south' => 11.1111,
                'west' => -44.4444
              },
              'markers' => [[-22.2222, 11.1111]]
            }
          }
        )
      end

      it 'geocodes and saves the city, state, and country' do
        subject.perform(user.id, '1234')
        user_activity.activity.reload
        aggregate_failures 'attributes' do
          expect(user_activity.activity.city).to eq('San Francisco')
          expect(user_activity.activity.state_province).to eq('California')
          expect(user_activity.activity.country).to eq('United States')
        end
      end

      it 'returns true' do
        expect(subject.perform(user.id, '1234')).to eq(true)
      end
    end
  end
end
