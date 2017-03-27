module Fitbit
  class ImportRunTcxWorker
    include Sidekiq::Worker

    def perform(user_id, uid)
      user = User.find(user_id)
      user_activity = UserActivity.where(user_id: user.id, uid: uid, activity_type: 'Activity::FitbitRun').first!

      tcx_data = FitbitService.get_activity_tcx(user.fitbit_identity, { log_id: user_activity.uid }).parsed_response
      return false if tcx_data.blank?

      res = Fitbit::CreateRunTcxService.call(user_activity: user_activity, tcx_data: tcx_data)
      raise res.exception if res.failure?

      return true
    end
  end
end
