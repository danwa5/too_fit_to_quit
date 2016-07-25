require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
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

  describe '#fitbit_periods' do
    it 'contains the correct labels' do
      expect(helper.fitbit_periods.map { |arr| arr[0] }).to eq(['1 day','1 week','1 month','3 month','6 month','1 year'])
    end
    it 'contains the correct values' do
      expect(helper.fitbit_periods.map { |arr| arr[1] }).to eq(['1d','1w','1m','3m','6m','1y'])
    end
  end

  describe '#format_distance' do
    it 'converts meters to miles with 2 decimal places' do
      expect(helper.format_distance(10000)).to eq(6.21)
    end
  end

  describe '#format_duration' do
    context 'when duration is 30 min, 10 sec' do
      it 'coverts milliseconds to 0:30:10' do
        expect(helper.format_duration(1810000)).to eq('0:30:10')
      end
    end
    context 'when duration is 1 hr, 30 min, 40 sec' do
      it 'coverts milliseconds to 1:30:40' do
        expect(helper.format_duration(5440000)).to eq('1:30:40')
      end
    end
  end
end
