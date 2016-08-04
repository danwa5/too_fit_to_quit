class ImportFitbitRunTcxWorker
  include Sidekiq::Worker

  def perform(user_id, uid)
    user = User.find_by(id: user_id)
    return false if user.nil?

    user_activity = UserActivity.where(user_id: user.id, uid: uid, activity_type: 'Activity::FitbitRun').first
    return false if user_activity.nil?

    tcx_data = FitbitService.get_activity_tcx(user.fitbit_identity, { log_id: user_activity.uid }).parsed_response
    return false if tcx_data.blank?

    gps_data = Hash.new
    gps_data['coordinates'] = get_gps_data(tcx_data)

    user_activity.activity.gps_data = gps_data
    user_activity.activity.tcx_data = tcx_data
    user_activity.activity.save!

    return true
  end

  private

  def get_gps_data(tcx_data)
    coordinates = []

    tcx_data['TrainingCenterDatabase']['Activities']['Activity']['Lap'].each do |lap|
      lap['Track']['Trackpoint'].each_with_index do |track_point, index|
        point = {
          :lat => track_point['Position']['LatitudeDegrees'],
          :lng => track_point['Position']['LongitudeDegrees']
        }
        coordinates << point if index == 0 || index % 15 == 0 || index == lap['Track']['Trackpoint'].length
      end
    end

    return coordinates
  end
end
