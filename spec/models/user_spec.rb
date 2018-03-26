require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { create(:user) }

  subject { user }

  describe 'associations' do
    it { is_expected.to have_many(:identities) }
    it { is_expected.to have_many(:user_activities) }
  end

  describe '#fitbit_identity' do
    example do
      expect(subject.fitbit_identity).to be_present
      expect(subject.fitbit_identity.provider).to eq('fitbit_oauth2')
    end
  end

  describe '#strava_identity' do
    example do
      expect(subject.strava_identity).to be_present
      expect(subject.strava_identity.provider).to eq('strava')
    end
  end
end
