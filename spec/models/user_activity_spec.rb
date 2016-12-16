require 'rails_helper'

RSpec.describe UserActivity, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:activity) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to validate_presence_of(:uid) }
  end

  describe '.monthly_breakdown' do
    let(:user) { create(:user) }
    before do
      create(:user_activity, :fitbit, user: user, start_time: Faker::Date.between('2009-01-01', '2009-12-31'))
      create(:user_activity, :fitbit, user: user, start_time: "#{Date.today.year}-06-01")
      create(:user_activity, :fitbit, user: user, start_time: "#{Date.today.year}-08-01")
      create(:user_activity, :fitbit, user: user, start_time: "#{Date.today.year}-08-08")
    end
    it 'returns a monthly breakdown of run count for the current year' do
      res = described_class.monthly_breakdown
      aggregate_failures 'json data' do
        expect(res.count).to eq(12)
        expect(res[0]['month']).to eq(1)
        expect(res[0]['total']).to be_nil
        expect(res[1]['month']).to eq(2)
        expect(res[1]['total']).to be_nil
        expect(res[2]['month']).to eq(3)
        expect(res[2]['total']).to be_nil
        expect(res[3]['month']).to eq(4)
        expect(res[3]['total']).to be_nil
        expect(res[4]['month']).to eq(5)
        expect(res[4]['total']).to be_nil
        expect(res[5]['month']).to eq(6)
        expect(res[5]['total']).to eq(1)
        expect(res[6]['month']).to eq(7)
        expect(res[6]['total']).to be_nil
        expect(res[7]['month']).to eq(8)
        expect(res[7]['total']).to eq(2)
        expect(res[8]['month']).to eq(9)
        expect(res[8]['total']).to be_nil
        expect(res[9]['month']).to eq(10)
        expect(res[9]['total']).to be_nil
        expect(res[10]['month']).to eq(11)
        expect(res[10]['total']).to be_nil
        expect(res[11]['month']).to eq(12)
        expect(res[11]['total']).to be_nil
      end
    end
  end
end
