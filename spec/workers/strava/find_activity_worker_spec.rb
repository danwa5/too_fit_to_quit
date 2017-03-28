require 'rails_helper'

RSpec.describe Strava::FindActivityWorker, type: :model do
  let(:user) { create(:user) }
  let!(:identity) { create(:identity, :strava, user: user) }
  let(:response) { nil }

  it { is_expected.to be_kind_of(Sidekiq::Worker) }

  def make_request(response)
    stub_request(:get, %r{https://www.strava.com/api/v3/athlete/activities\?after=\d+}).
      to_return(status: 200, body: response.to_json)
  end

  def run_worker
    subject.perform(user.id)
  end

  describe '#perform' do
    before do
      make_request(response)
    end

    context 'when user is invalid' do
      it 'raises ActiveRecord::RecordNotFound' do
        expect {
          subject.perform('')
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when service request returns an unsuccessful response' do
      let(:response) do
        {
          'errors' => [
            { 'resource' => 'Athlete', 'field' => 'access_token', 'code' => 'invalid' }
          ]
        }
      end
      it 'returns false' do
        expect(run_worker).to eq(false)
      end
    end

    context 'when service request returns a successful response but no activities' do
      let(:response) { [] }
      it 'returns true' do
        expect(run_worker).to eq(true)
      end
    end

    context 'when service request returns a successful response with activities' do
      let(:response) do
        [
          { 'id' => 101, 'type' => 'Run', 'distance' => 100.0 },
          { 'id' => 102, 'type' => 'Bike', 'distance' => 200.0 },
          { 'id' => 103, 'type' => 'Run', 'distance' => 300.0 }
        ]
      end

      it 'enqueues Strava::ImportRunWorker for every run activity' do
        expect {
          run_worker
        }.to change(Strava::ImportRunWorker.jobs, :count).by(2)
      end

      it 'returns true' do
        expect(run_worker).to eq(true)
      end
    end
  end

  describe '#get_options' do
    context 'when date is nil' do
      it 'returns a hash containing todays date' do
        expect(subject.send(:get_options, nil)).to eq({ date: Date.today.strftime('%Y-%m-%d') })
      end
    end

    context 'when date is valid' do
      it 'returns a hash containing the date' do
        expect(subject.send(:get_options, '2017-02-02')).to eq({ date: '2017-02-02' })
      end
    end

    context 'when date is invalid' do
      it 'raises ArgumentError' do
        expect {
          subject.send(:get_options, 'abc')
        }.to raise_error(ArgumentError)
      end
    end
  end
end
