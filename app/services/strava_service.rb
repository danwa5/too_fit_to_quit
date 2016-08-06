class StravaService
  include HTTParty

  base_uri Figaro.env.strava_api_url

  format :json

  class << self
    def get_profile(client_identity)
      new(client_identity).get_profile
    end

    def get_activities_list(client_identity, options={})
      if options[:date].present?
        options[:epoch] = DateTime.parse("#{options[:date]} 00:00:00 PST").to_i
      else
        options[:epoch] = DateTime.now.midnight.to_i
      end
      new(client_identity, options).get_activities_list
    end
  end

  def initialize(client_identity, options={})
    @client_token = client_identity.access_token
    @options      = options
  end

  # GET https://www.strava.com/api/v3/athlete
  def get_profile
    self.class.get("/v3/athlete", headers: headers)
  end

  # GET https://www.strava.com/api/v3/athlete/activities
  def get_activities_list
    self.class.get("/v3/athlete/activities", query: { after: @options[:epoch] }, headers: headers)
  end

  private

  def headers
    {
      'Authorization' => "Bearer #{@client_token}",
      'Content-Type' => 'application/x-www-form-urlencoded'
    }
  end

end