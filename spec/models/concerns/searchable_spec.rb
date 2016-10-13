require 'rails_helper'

RSpec.describe Searchable do
  let(:model) { Activity::FitbitRun }
  let!(:run_1) { create(:activity_fitbit_run, steps: 1000) }
  let!(:run_2) { create(:activity_fitbit_run, steps: 2000) }
  let!(:run_3) { create(:activity_fitbit_run, steps: 3000) }

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
end
