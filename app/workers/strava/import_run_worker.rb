module Strava
  class ImportRunWorker
    include Sidekiq::Worker

    def perform(user_id, activity_hash)
      user = User.find_by(id: user_id)
      return false if user.nil?

      keys = activity_hash.keys
      required_keys = %w(id type distance moving_time total_elevation_gain start_date elev_high elev_low)

      # all required keys should be present
      return false unless (required_keys - keys).empty?

      user_activity = UserActivity.where(user_id: user.id, activity_type: 'Activity::StravaRun', uid: activity_hash['id']).first_or_create!

      user_activity_attributes = {
        distance: activity_hash['distance'].to_f,
        duration: activity_hash['moving_time'].to_i,
        start_time: DateTime.parse(activity_hash['start_date']),
        start_time_rounded_epoch: DateTime.parse(activity_hash['start_date']).to_i / 240,
        activity_data: activity_hash
      }

      unless user_activity.activity.present?
        user_activity_attributes[:activity] = Activity::StravaRun.create(user: user, user_activity: user_activity)
      end

      run_attributes = {
        total_elevation_gain: activity_hash['total_elevation_gain'].to_f,
        elevation_high: activity_hash['elev_high'].to_f,
        elevation_low: activity_hash['elev_low'].to_f
      }

      user_activity.activity.update_attributes(run_attributes)
      user_activity.update_attributes(user_activity_attributes)

      Strava::ImportRunMetricsWorker.perform_async(user.id, activity_hash['id'])

      return true
    end
  end
end