require 'rails_helper'

RSpec.describe Api::RunPresenter, type: :model do
  subject { described_class.new(run) }

  describe '#as_json' do
    let(:user_activity) { create(:user_activity, :fitbit) }
    let(:run) { create(:activity_fitbit_run, user_activity: user_activity, city: 'SF', state_province: 'CA', country: 'USA', steps: 6000) }

    it 'returns a json representation of run' do
      res = JSON.parse(subject.to_json)
      aggregate_failures 'json attributes' do
        expect(res['id']).to eq(user_activity.id)
        expect(res['distance']).to be_present
        expect(res['duration']).to be_present
        expect(res['location']).to eq('SF, USA')
        expect(res['start_time']).to be_present
        expect(res['steps']).to eq(6000)
      end
    end
  end
end
