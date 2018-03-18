require 'rails_helper'

RSpec.describe Converters::DistanceService do
  subject { described_class.new(value: nil, unit: nil) }

  it { is_expected.to be_kind_of(Services::BaseService) }

  describe 'MILES_PER_METER' do
    it { expect(described_class::MILES_PER_METER).to eq(0.000621371) }
  end

  describe '.call' do
    context 'when converting meters to miles' do
      example do
        res = described_class.call(value: 1609.34, unit: 'meter')
        expect(res).to eq('1.00')
      end
    end

    context 'when converting miles to meters' do
      example do
        res = described_class.call(value: 1, unit: 'mile')
        expect(res).to eq('1609.34')
      end
    end
  end
end
