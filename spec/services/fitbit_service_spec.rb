require 'rails_helper'

RSpec.describe FitbitService, type: :model do
  let(:identity) { FactoryGirl.create(:identity, :fitbit) }

  describe '.base_uri' do
    it { expect(described_class.base_uri).to eq(Figaro.env.fitbit_api_url) }
  end

  describe '.format' do
    it { expect(described_class.format).to eq(:json) }
  end

  describe '.get_profile' do
    it 'makes a request to the fitbit api' do
      expected = {
        'user' => {
          'age' => 30,
          'city' => 'CITY',
          'country' => 'COUNTRY',
          'dateOfBirth' => '1993-01-02',
          'displayName' => 'DISPLAY_NAME'
        }
      }
      stub_req = stub_request(:get, Figaro.env.fitbit_api_url + "/1/user/#{identity.uid}/profile.json").to_return(status: 200, body: expected.to_json)

      response = described_class.get_profile(identity)
      expect(stub_req).to have_been_made
      expect(response.class).to eq(HTTParty::Response)
    end
  end

  describe '.get_steps' do
    let(:today) { Date.today.strftime('%Y-%m-%d') }

    it 'makes a request to the fitbit api' do
      expected = {
        'activities-steps' => [
          {
            'dateTime' => today,
            'value' => '12345'
          }
        ]
      }
      stub_req = stub_request(:get, Figaro.env.fitbit_api_url + "/1/user/#{identity.uid}/activities/steps/date/#{today}/1d.json").to_return(status: 200, body: expected.to_json)

      response = described_class.get_steps(identity)
      expect(stub_req).to have_been_made
      expect(response.class).to eq(HTTParty::Response)
    end
  end

  describe '.get_activities_list' do
    let(:today) { Date.today.strftime('%Y-%m-%d') }

    it 'makes a request to fitbit api for a list of user activities' do
      expected = {
        'activities' => [
          {
            'activityName' => 'Run',
            'activityTypeId' => 90009
          }
        ]
      }
      stub_req = stub_request(:get, Figaro.env.fitbit_api_url + "/1/user/#{identity.uid}/activities/list.json?afterDate=#{today}&sort=asc&limit=20&offset=0").to_return(status: 200, body: expected.to_json)

      response = described_class.get_activities_list(identity)
      expect(stub_req).to have_been_made
      expect(response.class).to eq(HTTParty::Response)
    end
  end

  describe '.get_activity_tcx' do
    it 'makes a request to fitbit api for detailed GPS and heart rate data for a specific activity' do
      stub_req = stub_request(:get, Figaro.env.fitbit_api_url + "/1/user/#{identity.uid}/activities/.tcx").to_return(status: 200)
      response = described_class.get_activity_tcx(identity)
      expect(stub_req).to have_been_made
      expect(response.class).to eq(HTTParty::Response)
    end
  end
end
