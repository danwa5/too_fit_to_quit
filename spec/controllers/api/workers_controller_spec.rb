require 'rails_helper'

RSpec.describe Api::WorkersController do
  describe 'POST create' do
    it 'must respond with success and enqueue a Sidekiq worker' do
      expect(Fitbit::ImportRunWorker).to receive(:perform_async).with('1234', '{}')
      post :create, worker: 'Fitbit::ImportRunWorker', args: '1234 {}'
      expect(response.status).to eq(200)
      expect(JSON.parse(response.body)['queued']).to eq('success')
    end

    it 'must respond with a queued failure message' do
      post :create, worker: 'FoobarWorker'
      expect(response.status).to eq(200)
      expect(JSON.parse(response.body)['queued']).to eq('failed - uninitialized constant FoobarWorker')
    end
  end
end
