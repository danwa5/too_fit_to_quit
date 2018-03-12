module Strava
  class ImportRunMetricsWorker
    include Sidekiq::Worker

    def perform(user_id, uid)
      user = User.find(user_id)
      user_activity = UserActivity.where(activity_type: 'Activity::StravaRun', user_id: user.id, uid: uid).first!
      return false unless user_activity.processing?

      data = StravaService.get_activity(user.strava_identity, { uid: user_activity.uid }).parsed_response
      return false if data.blank?

      user_activity.activity.splits = {
        'metric' => data['splits_metric'],
        'standard' => data['splits_standard']
      }

      user_activity.activity.save!
      user_activity.processed!

      return true
    end
  end
end
