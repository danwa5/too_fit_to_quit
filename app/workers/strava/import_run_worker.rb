module Strava
  class ImportRunWorker
    include Sidekiq::Worker

    def perform(user_id, activity_hash)
      user = User.find(user_id)

      keys = activity_hash.keys
      required_keys = %w(id type distance moving_time total_elevation_gain start_date elev_high elev_low).freeze

      # all required keys should be present
      raise "RuntimeError: missing required key in activity (ID #{activity_hash['id']})" unless (required_keys - keys).empty?

      Strava::CreateRunService.call(user: user, activity_hash: activity_hash) do |m|
        m.success do |user_activity|
          Strava::ImportRunMetricsWorker.perform_async(user.id, activity_hash['id']) if user_activity.present?
        end

        m.failure do |v|
          raise v.exception
        end
      end
    end
  end
end
