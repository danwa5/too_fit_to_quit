require 'rails_helper'

RSpec.describe Activity::FitbitRun, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_one(:user_activity) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to validate_presence_of(:user_activity) }
  end

  describe 'scopes' do
    describe '.locations' do
      before do
        create(:activity_fitbit_run, city: 'SF', country: 'USA')
        create(:activity_fitbit_run, city: 'Toronto', country: 'Canada')
        create(:activity_fitbit_run, city: 'SF', country: 'USA')
      end
      it 'returns distinct locations' do
        expect(described_class.locations).to eq([['SF', 'USA'], ['Toronto', 'Canada']])
      end
    end
  end

  describe '#location' do
    context 'when city and country are nil' do
      let(:run) { build(:activity_fitbit_run, city: nil, country: nil) }
      it 'returns empty string' do
        expect(run.location).to eq('')
      end
    end
    context 'when city and country are present' do
      let(:run) { build(:activity_fitbit_run, city: 'CITY', country: 'COUNTRY') }
      it 'returns city and country' do
        expect(run.location).to eq('CITY, COUNTRY')
      end
    end

  end
end
