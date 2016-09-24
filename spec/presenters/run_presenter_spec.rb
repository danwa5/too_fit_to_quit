require 'rails_helper'

RSpec.describe RunPresenter do
  let(:user) { create(:user) }
  let(:user_activity) { create(:user_activity, :fitbit, user: user, distance: 12345.6, start_time: '2016-07-31 14:00:00 UTC') }

  subject { described_class.new(user_activity) }

  it { expect(subject).to be_kind_of(SimpleDelegator) }

  describe 'MILES_PER_METER' do
    it { expect(described_class::MILES_PER_METER).to eq(0.00062137) }
  end

  describe '#formatted_distance' do
    it 'converts meters to miles' do
      expect(subject.formatted_distance).to eq(7.67)
    end
  end

  describe '#formatted_short_start_time' do
    it 'converts and formats datetime from UTC to PST' do
      expect(subject.formatted_short_start_time).to eq('Sun, 7/31/2016 7:00am')
    end
  end

  describe '#formatted_long_start_time' do
    it 'converts and formats datetime from UTC to PST' do
      expect(subject.formatted_long_start_time).to eq('Sunday, 7/31/2016 at 7:00am')
    end
  end

  describe '#final_split_distance' do
    context 'run distance is a whole number' do
      let(:user_activity) { create(:user_activity, :fitbit, user: user, distance: 1609.34) }
      it 'returns the last mile' do
        expect(subject.final_split_distance).to eq(1)
      end
    end
    context 'run distance is fractional' do
      it 'returns the last fractional mile' do
        expect(subject.final_split_distance).to eq(0.67)
      end
    end
  end
end
