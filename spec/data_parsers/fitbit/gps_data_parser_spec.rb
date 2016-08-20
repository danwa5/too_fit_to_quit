require 'rails_helper'

RSpec.describe Fitbit::GpsDataParser, type: :model do
  let(:gps_data) do
    {
      'raw'=>[
        {
          'datetime'=>'2016-02-11T18:20:10.000-08:00',
          'coordinate'=>['-122.4', '37.8'],
          'distance'=>'0.0',
          'altitude'=>'87.8',
          'heart_rate'=>'70'
        },
        {
          'datetime'=>'2016-02-11T18:20:25.000-08:00',
          'coordinate'=>['-122.3', '37.7'],
          'distance'=>'23.31',
          'altitude'=>'55.5',
          'heart_rate'=>'74'
        }
      ],
      'derived'=>{
        'bounds'=>{
          'north'=>'37.79644065243857',
          'east'=>'-122.3995463848114',
          'south'=>'37.76755204796791',
          'west'=>'-122.38764279229301'
        }
      }
    }
  end

  describe '#parse' do
    context 'when only no attribute is selected' do
      subject { described_class.new(gps_data, []) }

      it 'returns an empty array' do
        expect(subject.parse).to eq([])
      end
    end

    context 'when only one attribute is selected' do
      subject { described_class.new(gps_data, ['coordinate']) }

      it 'returns an array of values' do
        expect(subject.parse).to eq([['-122.4','37.8'], ['-122.3','37.7']])
      end
    end

    context 'when all attributes are selected' do
      subject { described_class.new(gps_data, %w(altitude coordinate datetime distance heart_rate)) }

      it 'returns an array of hashes' do
        expect(subject.parse).to eq(
          [
            {
              'datetime'=>'2016-02-11T18:20:10.000-08:00',
              'coordinate'=>['-122.4', '37.8'],
              'distance'=>'0.0',
              'altitude'=>'87.8',
              'heart_rate'=>'70'
            },
            {
              'datetime'=>'2016-02-11T18:20:25.000-08:00',
              'coordinate'=>['-122.3', '37.7'],
              'distance'=>'23.31',
              'altitude'=>'55.5',
              'heart_rate'=>'74'
            }
          ]
        )
      end
    end
  end
end
