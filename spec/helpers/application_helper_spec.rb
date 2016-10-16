require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe 'MILES_PER_METER' do
    it { expect(described_class::MILES_PER_METER).to eq(0.000621371) }
  end

  describe '#format_date' do
    context 'when argument is nil' do
      it 'returns N/A' do
        expect(helper.format_date(nil)).to eq('N/A')
      end
    end
    context 'when argument is a valid date (2016-07-01)' do
      it 'returns the date in correct format: Friday, July 1, 2016' do
        expect(helper.format_date('2016-07-01')).to eq('Friday, July 1, 2016')
      end
    end
  end

  describe '#format_run_time' do
    it 'converts and formats datetime from UTC to PST' do
      expect(helper.format_run_time('2016-07-31 14:00:00 UTC')).to eq('Sun, 7/31/2016  2:00pm')
    end
  end

  describe '#fitbit_periods' do
    it 'contains the correct labels' do
      expect(helper.fitbit_periods.map { |arr| arr[0] }).to eq(['1 day','1 week','1 month','3 month','6 month','1 year'])
    end
    it 'contains the correct values' do
      expect(helper.fitbit_periods.map { |arr| arr[1] }).to eq(['1d','1w','1m','3m','6m','1y'])
    end
  end

  describe '#format_distance' do
    context 'when the argument is nil' do
      it { expect(helper.format_distance(nil)).to be_nil }
    end
    context 'when the argument is in meters' do
      it 'converts meters to miles with 2 decimal places' do
        expect(helper.format_distance(10000, 'meter')).to eq(6.21)
      end
    end
    context 'when the argument is in miles' do
      it 'converts miles to meters with 2 decimal places' do
        expect(helper.format_distance(1, 'mile')).to eq(1609.34)
      end
    end
  end

  describe '#format_duration' do
    context 'when duration is 30 min, 10 sec' do
      it 'coverts seconds to 0:30:10' do
        expect(helper.format_duration(1810)).to eq('30:10')
      end
    end
    context 'when duration is 1 hr, 30 min, 40 sec' do
      it 'coverts seconds to 1:30:40' do
        expect(helper.format_duration(5440)).to eq('1:30:40')
      end
    end
  end

  describe '#convert_to_seconds' do
    context 'when minutes is blank' do
      it { expect(helper.convert_to_seconds('')).to be_nil }
    end
    context 'when minutes is given' do
      it { expect(helper.convert_to_seconds('1')).to eq(60) }
    end
  end

  describe '#format_pace' do
    it 'calculates pace in minutes/mile' do
      expect(helper.format_pace(5645, 21396.599)).to eq('7:05')
    end
  end
end
