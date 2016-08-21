module Strava
  class ImportRunMetricsWorker
    include Sidekiq::Worker

    def perform(user_id, uid)
      user = User.find_by(id: user_id)
      return false if user.nil?

      user_activity = UserActivity.where(user_id: user.id, uid: uid, activity_type: 'Activity::StravaRun').first
      return false if user_activity.nil?

      data = StravaService.get_activity(user.strava_identity, { uid: user_activity.uid }).parsed_response
      return false if data.blank?

      user_activity.activity.splits = {
        'metric' => data['splits_metric'],
        'standard' => data['splits_standard']
      }

      user_activity.activity.save!

      return true
    end
  end
end
