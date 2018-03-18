require 'rails_helper'

RSpec.describe Converters::DurationService do
  subject { described_class.new(value: nil, unit: nil) }

  it { is_expected.to be_kind_of(Services::BaseService) }

  describe '.call' do
    context 'when value is blank' do
      it 'returns nil' do
        res = described_class.call(value: '', unit: 'second')
        expect(res).to be_nil
      end
    end

    context 'when unit is "second"' do
      it 'converts seconds to 0:30:10' do
        res = described_class.call(value: 1810, unit: 'second')
        expect(res).to eq('30:10')
      end

      it 'converts seconds to 1:30:40' do
        res = described_class.call(value: 5440, unit: 'second')
        expect(res).to eq('1:30:40')
      end
    end

    context 'when unit is "minute"' do
      context 'and value is blank' do
        it 'returns nil' do
          res = described_class.call(value: '', unit: 'minute')
          expect(res).to be_nil
        end
      end

      context 'and value is given' do
        it 'converts to seconds' do
          res = described_class.call(value: 1, unit: 'minute')
          expect(res).to eq(60)
        end
      end
    end
  end
end
