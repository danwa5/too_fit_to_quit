class ImportFitbitRunTcxWorker
  include Sidekiq::Worker

  def perform(user_id, uid)
    user = User.find_by(id: user_id)
    return false if user.nil?

    user_activity = UserActivity.where(user_id: user.id, uid: uid, activity_type: 'Activity::FitbitRun').first
    return false if user_activity.nil?

    xml_data = FitbitService.get_activity_tcx(user.fitbit_identity, { log_id: user_activity.uid }).parsed_response
    return false if xml_data.blank?

    user_activity.activity.tcx_data = xml_data
    user_activity.activity.save!

    return true
  end
end
