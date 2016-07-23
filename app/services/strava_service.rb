class StravaService
  include HTTParty

  base_uri Figaro.env.strava_api_url

  format :json

  class << self
    def get_profile(client_identity)
      new(client_identity).get_profile
    end

    def get_activities_list(client_identity)
      new(client_identity).get_activities_list
    end
  end

  def initialize(client_identity, options={})
    @client_token = client_identity.access_token
    @options      = options
  end

  # GET https://www.strava.com/api/v3/athlete
  def get_profile
    self.class.get(Figaro.env.strava_api_url + "/v3/athlete", headers: headers)
  end

  # GET https://www.strava.com/api/v3/athlete/activities
  def get_activities_list
    self.class.get(Figaro.env.strava_api_url + "/v3/athlete/activities", headers: headers)
  end

  private

  def headers
    {
      'Authorization' => "Bearer #{@client_token}",
      'Content-Type' => 'application/x-www-form-urlencoded'
    }
  end

end