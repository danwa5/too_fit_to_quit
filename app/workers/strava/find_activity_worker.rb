module Strava
  class FindActivityWorker
    include Sidekiq::Worker

    def perform(user_id, date=nil)
      user = User.find(user_id)

      options = get_options(date)

      results = StravaService.get_activities_list(user.strava_identity, options).parsed_response

      return false if results.kind_of?(Hash) && results['errors'].present?

      results.each do |activity_hash|
        if activity_hash['type'] == 'Run'
          Strava::ImportRunWorker.perform_async(user.id, activity_hash)
        end
      end

      return true
    end

    private

    def get_options(date)
      value = if date.present?
        Date.parse(date).strftime('%Y-%m-%d')
      else
        Date.today.strftime('%Y-%m-%d')
      end
      { date: value }
    end
  end
end
