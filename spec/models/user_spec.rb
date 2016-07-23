require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { FactoryGirl.create(:user) }

  subject { user }
  
  describe 'associations' do
    it { is_expected.to have_many(:identities) }
  end

  describe '#fitbit_identity' do
    context 'user does not have a fitbit identity' do
      it 'returns nil' do
        expect(subject.fitbit_identity).to be_nil
      end
    end
    context 'user has a fitbit identity' do
      let!(:identity) { FactoryGirl.create(:identity, :fitbit, user: user) }
      it { expect(subject.fitbit_identity).to eq(identity) }
    end
  end

  describe '#strava_identity' do
    context 'user does not have a strava identity' do
      it 'returns nil' do
        expect(subject.strava_identity).to be_nil
      end
    end
    context 'user has a strava identity' do
      let!(:identity) { FactoryGirl.create(:identity, :strava, user: user) }
      it { expect(subject.strava_identity).to eq(identity) }
    end
  end
end