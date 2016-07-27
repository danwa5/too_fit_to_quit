class FitbitService
  include HTTParty

  base_uri Figaro.env.fitbit_api_url

  # format :json

  class << self
    def get_profile(client_identity)
      new(client_identity).get_profile
    end

    def get_steps(client_identity, options={})
      defaults = {
        :date   => Date.today.strftime('%Y-%m-%d'),
        :period => '1d'
      }
      options = defaults.merge(options)
      new(client_identity, options).get_steps
    end

    def get_activities_list(client_identity, options={})
      defaults = {
        :date => Date.today.strftime('%Y-%m-%d')
      }
      options = defaults.merge(options)
      new(client_identity, options).get_activities_list
    end

    def get_activity_tcx(client_identity, options={})
      new(client_identity, options).get_activity_tcx
    end
  end

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

  # GET https://api.fitbit.com/1/user/[user-id]/activities/list.json
  def get_activities_list
    self.class.get(Figaro.env.fitbit_api_url + "/1/user/#{@client_uid}/activities/list.json?afterDate=#{@options[:date]}&sort=asc&limit=20&offset=0", headers: headers)
  end

  # GET https://api.fitbit.com/1/user/[user-id]/activities/[log-id].tcx
  def get_activity_tcx
    self.class.get(Figaro.env.fitbit_api_url + "/1/user/#{@client_uid}/activities/#{@options[:log_id]}.tcx", headers: headers)
  end

  private

  def headers
    {
      'Authorization' => "Bearer #{@client_token}",
      'Content-Type' => 'application/x-www-form-urlencoded'
    }
  end
end
