require 'rails_helper'

RSpec.describe StravaService, type: :model do
  let(:identity) { create(:identity, :strava) }

  describe '.base_uri' do
    it { expect(described_class.base_uri).to eq(Figaro.env.strava_api_url) }
  end

  describe '.format' do
    it { expect(described_class.format).to eq(:json) }
  end

  describe '.get_profile' do
    it 'makes a request to strava api' do
      expected = {
        'firstname' => 'FIRST',
        'lastname' => 'LAST',
        'city' => 'CITY',
        'email' => 'EMAIL'
      }
      stub_req = stub_request(:get, Figaro.env.strava_api_url + '/v3/athlete').to_return(status: 200, body: expected.to_json)

      response = described_class.get_profile(identity)
      expect(stub_req).to have_been_made
      expect(response.class).to eq(HTTParty::Response)
    end
  end

  describe '.get_activities_list' do
    it 'makes a request to strava api and returns an array of activities' do
      expected = [
        {
          'id' => 101,
          'type' => 'Run',
          'distance' => '1000'
        }
      ]
      stub_req = stub_request(:get, %r{#{Figaro.env.strava_api_url}/v3/athlete/activities\?after=\d+}).to_return(status: 200, body: expected.to_json)

      response = described_class.get_activities_list(identity)
      expect(stub_req).to have_been_made
      expect(response.class).to eq(HTTParty::Response)
    end
  end

  describe '.get_activity' do
    it 'makes a request to strava api and returns an activity' do
      expected = {
        'id' => 101,
        'type' => 'Run',
        'distance' => '1000'
      }
      stub_req = stub_request(:get, %r{#{Figaro.env.strava_api_url}/v3/activities/101}).to_return(status: 200, body: expected.to_json)

      response = described_class.get_activity(identity, {uid: 101})
      expect(stub_req).to have_been_made
      expect(response.class).to eq(HTTParty::Response)
    end
  end
end
