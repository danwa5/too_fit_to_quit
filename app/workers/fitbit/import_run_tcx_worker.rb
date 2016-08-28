module Fitbit
  class ImportRunTcxWorker
    include Sidekiq::Worker

    def perform(user_id, uid)
      user = User.find_by(id: user_id)
      return false if user.nil?

      user_activity = UserActivity.where(user_id: user.id, uid: uid, activity_type: 'Activity::FitbitRun').first
      return false if user_activity.nil?

      tcx_data = FitbitService.get_activity_tcx(user.fitbit_identity, { log_id: user_activity.uid }).parsed_response
      return false if tcx_data.blank?

      gps_data = Hash.new
      gps_data['raw'], gps_data['derived'] = get_gps_data(tcx_data)

      user_activity.activity.gps_data = gps_data
      user_activity.activity.tcx_data = tcx_data
      user_activity.activity.save!

      return true
    end

    private

    def get_gps_data(tcx_data)
      raw = []
      derived = {}
      bounds = {}

      tcx_data['TrainingCenterDatabase']['Activities']['Activity']['Lap'].each do |lap|
        lap['Track']['Trackpoint'].each_with_index do |track_point, index|
          position = [track_point['Position']['LongitudeDegrees'].to_f, track_point['Position']['LatitudeDegrees'].to_f]

          # Take the first, last, and every 15th data point
          if index == 0 || index % 15 == 0 || index == (lap['Track']['Trackpoint'].length-1)
            raw << {
              'datetime' => track_point['Time'],
              'coordinate' => position,
              'distance' => track_point['DistanceMeters'],
              'altitude' => track_point['AltitudeMeters'],
              'heart_rate' => track_point['HeartRateBpm']['Value']
            }
          end

          # Determine the route's maximum boundaries
          bounds['north'] = get_max_bounds(bounds['north'], position[1])
          bounds['east'] = get_max_bounds(bounds['east'], position[0])
          bounds['south'] = get_min_bounds(bounds['south'], position[1])
          bounds['west'] = get_min_bounds(bounds['west'], position[0])
        end
      end

      derived['bounds'] = bounds

      return raw, derived
    end

    # maximum northern and eastern coordinates
    def get_max_bounds(max_coordinate, current_coordinate)
      return current_coordinate if max_coordinate.nil?
      current_coordinate > max_coordinate ? current_coordinate : max_coordinate
    end

    # minimum southern and western coordinates
    def get_min_bounds(min_coordinate, current_coordinate)
      return current_coordinate if min_coordinate.nil?
      current_coordinate < min_coordinate ? current_coordinate : min_coordinate
    end
  end
end
