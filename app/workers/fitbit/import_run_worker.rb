module Fitbit
  class ImportRunWorker
    include Sidekiq::Worker

    def perform(user_id, activity_hash)
      user = User.find(user_id)

      keys = activity_hash.keys
      required_keys = %w(activeDuration activityName activityTypeId distance distanceUnit logId startTime steps).freeze

      # all required keys should be present
      raise "RuntimeError: missing required key in activity (logId #{activity_hash['logId']})" unless (required_keys - keys).empty?

      Fitbit::CreateRunService.call(user: user, activity_hash: activity_hash) do |m|
        m.success do |user_activity|
          Fitbit::ImportRunTcxWorker.perform_async(user.id, activity_hash['logId']) if user_activity.present?
        end

        m.failure do |v|
          raise v.exception
        end
      end
    end
  end
end
