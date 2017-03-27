require 'rails_helper'

RSpec.describe Fitbit::CreateRunTcxService do
  let(:user) { create(:user) }
  let(:user_activity) { create(:user_activity, :fitbit, user: user, uid: '1234') }
  let!(:activity_fitbit_run) { create(:activity_fitbit_run, user: user, user_activity: user_activity) }
  let(:tcx_data) do
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

  subject { described_class.new(user_activity: user_activity, tcx_data: tcx_data) }

  it { is_expected.to be_kind_of(Services::BaseService) }

  def service_call
    described_class.call(user_activity: user_activity, tcx_data: tcx_data)
  end

  describe '.call' do
    before do
      geocode = double(city: 'San Francisco', state: 'California', country: 'United States')
      allow(Geocoder).to receive_message_chain(:search, :first).and_return(geocode)
    end

    it 'saves tcx data' do
      expect(user_activity.activity.tcx_data).to be_nil
      service_call
      user_activity.activity.reload
      expect(user_activity.activity.tcx_data).to be_present
    end

    it 'saves gps data - datetime, coordinates, distance, altitudes, heart rates, bounds, and markers' do
      expect(user_activity.activity.gps_data).to be_nil
      service_call
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
      service_call
      user_activity.activity.reload
      aggregate_failures 'geocode attributes' do
        expect(user_activity.activity.city).to eq('San Francisco')
        expect(user_activity.activity.state_province).to eq('California')
        expect(user_activity.activity.country).to eq('United States')
      end
    end

    it 'returns Try::Success' do
      res = service_call
      expect(res.success?).to eq(true)
      expect(res.value).to eq(true)
    end
  end
end
