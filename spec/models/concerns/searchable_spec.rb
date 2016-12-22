require 'rails_helper'

RSpec.describe Searchable do
  let(:model) { Activity::FitbitRun }
  let!(:run_1) { create(:activity_fitbit_run, steps: 1000, city: 'SF', created_at: '2016-09-01 01:00:00') }
  let!(:run_2) { create(:activity_fitbit_run, steps: 2000, city: 'NY', created_at: '2016-09-02 02:00:00') }
  let!(:run_3) { create(:activity_fitbit_run, steps: 3000, city: 'SF', created_at: '2016-09-03 03:00:00') }

  describe 'matching_contain' do
    context 'when attribute contains value' do
      it { expect(model.matching_contain(:city, 'SF')).to contain_exactly(run_1, run_3) }
    end
    context 'when attribute does not contain value' do
      it { expect(model.matching_contain(:city, 'LA')).to eq([]) }
    end
  end

  describe '.number_within_range' do
    context 'when both low and high values are provided' do
      it { expect(model.number_within_range(:steps, 1999, 2000)).to contain_exactly(run_2) }
    end
    context 'when only the low value is provided' do
      it { expect(model.number_within_range(:steps, 2000, nil)).to contain_exactly(run_2, run_3) }
    end
    context 'when only the high value is provided' do
      it { expect(model.number_within_range(:steps, nil, 2000)).to contain_exactly(run_1, run_2) }
    end
    context 'when neither low or high value is provided' do
      it 'returns all' do
        expect(model.number_within_range(:steps, nil, nil)).to eq([run_1, run_2, run_3])
      end
    end
  end

  describe '.date_within_range' do
    context 'when both start and end dates are provided' do
      it { expect(model.date_within_range(:created_at, '2016-09-02', '2016-09-02')).to contain_exactly(run_2) }
    end
    context 'when only start date is provided' do
      it { expect(model.date_within_range(:created_at, '2016-09-02', nil)).to contain_exactly(run_2, run_3) }
    end
    context 'when only end date is provided' do
      it { expect(model.date_within_range(:created_at, nil, '2016-09-02')).to contain_exactly(run_1, run_2) }
    end
    context 'when neither start or end date is provided' do
      it 'returns all' do
        expect(model.date_within_range(:created_at, nil, nil)).to eq([run_1, run_2, run_3])
      end
    end
  end
end
