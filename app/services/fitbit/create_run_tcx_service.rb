module Fitbit
  class CreateRunTcxService
    include Services::BaseService
    extend Dry::Initializer

    option :user_activity
    option :tcx_data

    def call
      Try() {
        gps_data = Hash.new
        gps_data['raw'], gps_data['derived'] = get_gps_data

        coordinates = gps_data['derived']['markers'].first
        geocode = Geocoder.search(coordinates.reverse.join(',')).first

        @user_activity.activity.update_attributes!({
          gps_data: gps_data,
          tcx_data: tcx_data,
          city: geocode.city,
          state_province: geocode.state,
          country: geocode.country
        })

        true
      }
    end

    private

    def get_gps_data
      raw = []
      derived = {}
      bounds = {}
      markers = []

      @tcx_data['TrainingCenterDatabase']['Activities']['Activity']['Lap'].each do |lap|
        lap['Track']['Trackpoint'].each_with_index do |track_point, index|
          position = [track_point['Position']['LongitudeDegrees'].to_f, track_point['Position']['LatitudeDegrees'].to_f]

          # Take the first, last, and every 15th data point in between
          if index == 0 || index % 15 == 0 || index == (lap['Track']['Trackpoint'].length-1)
            raw << {
              'datetime' => track_point['Time'],
              'coordinate' => position,
              'distance' => track_point['DistanceMeters'],
              'altitude' => track_point['AltitudeMeters'],
              'heart_rate' => track_point['HeartRateBpm']['Value']
            }
          end

          markers << position if index == (lap['Track']['Trackpoint'].length-1)

          # Determine the route's maximum boundaries
          bounds['north'] = get_max_bounds(bounds['north'], position[1])
          bounds['east'] = get_max_bounds(bounds['east'], position[0])
          bounds['south'] = get_min_bounds(bounds['south'], position[1])
          bounds['west'] = get_min_bounds(bounds['west'], position[0])
        end
      end

      derived['bounds'] = bounds
      markers.delete_at(-1)
      derived['markers'] = markers

      return raw, derived
    end

    # Maximum northern and eastern coordinates
    def get_max_bounds(max_coordinate, current_coordinate)
      return current_coordinate if max_coordinate.nil?
      current_coordinate > max_coordinate ? current_coordinate : max_coordinate
    end

    # Minimum southern and western coordinates
    def get_min_bounds(min_coordinate, current_coordinate)
      return current_coordinate if min_coordinate.nil?
      current_coordinate < min_coordinate ? current_coordinate : min_coordinate
    end

  end
end
