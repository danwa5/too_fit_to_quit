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
      let!(:identity) { FactoryGirl.create(:identity, user: user, provider: 'fitbit_oauth2') }
      it { expect(subject.fitbit_identity).to eq(identity) }
    end
  end
end