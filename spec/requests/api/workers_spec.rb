require 'rails_helper'

RSpec.describe Api::WorkersController, type: :request do
  describe 'post /api/workers' do
    it 'must respond with success and enqueue a Sidekiq worker' do
      expect(Fitbit::ImportRunWorker).to receive(:perform_async).with('1234', '{}')
      post api_workers_url, params: { worker: 'Fitbit::ImportRunWorker', args: '1234 {}' }
      expect(response.status).to eq(200)
      expect(JSON.parse(response.body)['queued']).to eq('success')
    end

    it 'must respond with a queued failure message' do
      post api_workers_url, params: { worker: 'FoobarWorker' }
      expect(response.status).to eq(200)
      expect(JSON.parse(response.body)['queued']).to eq('failed - uninitialized constant FoobarWorker')
    end
  end
end
