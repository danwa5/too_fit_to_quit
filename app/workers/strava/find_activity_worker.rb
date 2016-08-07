module Strava
  class FindActivityWorker
    include Sidekiq::Worker

    def perform(user_id, date=nil)
      user = User.find_by(id: user_id)
      return false if user.nil?

      options = if date.present?
        { date: date }
      else
        { date: Date.today.strftime('%Y-%m-%d') }
      end

      results = StravaService.get_activities_list(user.strava_identity, options).parsed_response

      return false if results.kind_of?(Hash) && results['errors'].present?

      results.each do |activity_hash|
        if activity_hash['type'] == 'Run'
          Strava::ImportRunWorker.perform_async(user.id, activity_hash)
        end
      end

      return true
    end
  end
end
