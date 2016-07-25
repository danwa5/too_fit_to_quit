require 'rails_helper'

RSpec.describe FindFitbitActivityWorker, type: :model do
  let(:user) { create(:user) }
  let!(:identity) { create(:identity, :fitbit, user: user) }
  let(:date) { Date.today.strftime('%Y-%m-%d') }
  let(:response) do
    {
      'activities' => {}
    }
  end

  it { is_expected.to be_kind_of(Sidekiq::Worker) }

  def make_request(response)
    stub_request(:get, /https:\/\/api.fitbit.com\/1\/user\/\d+\/activities\/list.json/).
      to_return(status: 200, body: response.to_json)
  end

  describe '#perform' do
    context 'when user is nil' do
      it 'returns false' do
        expect(subject.perform('')).to be_falsey
      end
    end

    context 'when service request returns an unsuccessful response' do
      let(:response) { { 'success' => false } }
      it 'returns false' do
        make_request(response)
        expect(subject.perform(user.id)).to be_falsey
      end
    end

    context 'when service request returns a successful response' do
      let(:response) { { 'success' => true, 'activities' => [] } }
      it 'returns true' do
        make_request(response)
        expect(subject.perform(user.id)).to be_truthy
      end
    end

    context 'when service request returns a successful response with activities' do
      let(:response) do
        {
          'success' => true,
          'activities' => [
            { 'activityName' => 'Run' },
            { 'activityName' => 'Bike' },
            { 'activityName' => 'Run' }
          ]
        }
      end

      it 'enqueues ImportFitbitRunWorker for every run activity' do
        make_request(response)
        expect {
          subject.perform(user.id)
        }.to change(ImportFitbitRunWorker.jobs, :count).by(2)
      end

      it 'returns true' do
        make_request(response)
        expect(subject.perform(user.id)).to be_truthy
      end
    end
  end
end
