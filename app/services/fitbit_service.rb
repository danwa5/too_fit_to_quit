class FitbitService
  include HTTParty

  base_uri Figaro.env.fitbit_api_url

  def self.get_profile(client_identity)
    new(client_identity).get_profile
  end

  def self.get_steps(client_identity, options={})
    defaults = {
      :date   => Date.today.strftime('%Y-%m-%d'),
      :period => '1d'
    }
    options = defaults.merge(options)
    new(client_identity, options).get_steps
  end

  # def self.get_request(client_identity, options)
  #   new(client_identity, options).get_request
  # end

  def initialize(client_identity, options={})
    @client_token = client_identity.access_token
    @client_uid   = client_identity.uid
    @options      = options
  end

  # GET https://api.fitbit.com/1/user/[user-id]/profile.json
  def get_profile
    self.class.get(Figaro.env.fitbit_api_url + "/1/user/#{@client_uid}/profile.json", headers: headers)
  end

  # GET https://api.fitbit.com/1/user/[user-id]/activities/steps/date/today/1m.json
  def get_steps
    self.class.get(Figaro.env.fitbit_api_url + "/1/user/#{@client_uid}/activities/steps/date/#{@options[:date]}/#{@options[:period]}.json", headers: headers)
  end

  private

  def headers
    {
      'Authorization' => "Bearer #{@client_token}",
      'Content-Type' => 'application/x-www-form-urlencoded'
    }
  end
end
