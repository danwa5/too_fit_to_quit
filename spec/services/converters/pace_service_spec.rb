require 'rails_helper'

RSpec.describe Converters::PaceService do
  subject { described_class.new(seconds: nil, meters: nil) }

  it { is_expected.to be_kind_of(Services::BaseService) }

  describe 'MILES_PER_METER' do
    it { expect(described_class::MILES_PER_METER).to eq(0.000621371) }
  end

  describe '.call' do
    it 'calculates pace in minutes/mile' do
      res = described_class.call(seconds: 5645, meters: 21396.599)
      expect(res).to eq('7:05')
    end
  end
end
