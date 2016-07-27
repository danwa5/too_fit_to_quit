require 'rails_helper'

RSpec.describe ImportFitbitRunTcxWorker, type: :model do
  let(:user) { create(:user) }
  let!(:identity) { create(:identity, :fitbit, user: user) }
  let(:user_activity) { create(:user_activity, :fitbit, user: user, uid: '1234') }
  let!(:activity_fitbit_run) { create(:activity_fitbit_run, user: user, user_activity: user_activity) }

  def make_request(response)
    stub_request(:get, /https:\/\/api.fitbit.com\/1\/user\/\d+\/activities\/#{user_activity.uid}.tcx/).
      to_return(status: 200, body: response)
  end

  it { is_expected.to be_kind_of(Sidekiq::Worker) }

  describe '#perform' do
    context 'when user is nil' do
      it 'returns false' do
        expect(subject.perform((user.id + 1), 'blah')).to be_falsey
      end
    end

    context 'when user_activity is nil' do
      it 'returns false' do
        expect(subject.perform(user.id, 'blah')).to be_falsey
      end
    end

    context 'when no xml data is returned' do
      it 'returns false' do
        make_request(nil)
        expect(subject.perform(user.id, '1234')).to be_falsey
      end
    end

    context 'when xml data is returned' do
      before { make_request('<Activities><Activity Sport="Running"></Activity></Activities>') }

      it 'saves xml data' do
        expect(user_activity.activity.tcx_data).to be_nil
        subject.perform(user.id, '1234')
        user_activity.activity.reload
        expect(user_activity.activity.tcx_data).to be_present
      end

      it 'returns true' do
        expect(subject.perform(user.id, '1234')).to be_truthy
      end
    end
  end
end
