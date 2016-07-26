class ImportFitbitRunWorker
  include Sidekiq::Worker

  def perform(user_id, activity_hash)
    user = User.find_by(id: user_id)
    return false if user.nil?

    keys = activity_hash.keys
    required_keys = %w(activeDuration activityName activityTypeId distance distanceUnit logId startTime steps)

    # all required keys should be present
    return false unless (required_keys - keys).empty?

    user_activity = UserActivity.where(user_id: user.id, activity_type: 'Activity::FitbitRun', uid: activity_hash['logId']).first_or_create!

    # parse attributes
    user_activity_attributes = {
      duration: (activity_hash['activeDuration'].to_i / 1000),
      start_time: DateTime.parse(activity_hash['startTime'])
    }
    user_activity_attributes[:distance] = (activity_hash['distance'].to_f) * 1000 if activity_hash['distanceUnit'] == 'Kilometer'

    unless user_activity.activity.present?
      user_activity_attributes[:activity] = Activity::FitbitRun.create(user: user, user_activity: user_activity)
    end

    run_attributes = {
      activity_type_id: activity_hash['activityTypeId'].to_i,
      steps: activity_hash['steps'].to_i
    }

    user_activity.activity.update_attributes(run_attributes)
    user_activity.update_attributes(user_activity_attributes)

    return true
  end
end
