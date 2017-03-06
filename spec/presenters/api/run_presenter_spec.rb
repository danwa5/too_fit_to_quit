require 'rails_helper'

RSpec.describe Api::RunPresenter, type: :model do
  subject { described_class.new(run) }

  describe '#as_json' do
    let(:user_activity) { create(:user_activity, :fitbit, distance: 1.0, duration: 2, start_time: '2017-03-05 00:11:22') }
    let(:run) { create(:activity_fitbit_run, user_activity: user_activity, city: 'SF', state_province: 'CA', country: 'USA') }

    it 'returns a json representation of run' do
      expect(JSON.parse(subject.to_json)).to eq({
        'distance' => 1.0,
        'duration' => 2,
        'start_time' => '2017-03-05T00:11:22.000Z',
        'location' => {
          'city' => 'SF',
          'state_province' => 'CA',
          'country' => 'USA'
        }
      })
    end
  end
end
