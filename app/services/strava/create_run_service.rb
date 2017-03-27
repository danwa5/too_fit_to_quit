module Strava
  class CreateRunService
    include Services::BaseService
    extend Dry::Initializer

    option :user
    option :activity_hash

    def call
      Try() {
        user_activity = UserActivity.where(activity_type: 'Activity::StravaRun', user_id: user.id, uid: activity_hash['id']).first_or_create!

        user_activity_attributes = {
          distance: activity_hash['distance'].to_f,
          duration: activity_hash['moving_time'].to_i,
          start_time: DateTime.parse(activity_hash['start_date']),
          start_time_rounded_epoch: DateTime.parse(activity_hash['start_date']).to_i / 240,
          activity_data: activity_hash
        }

        unless user_activity.activity.present?
          user_activity_attributes[:activity] = Activity::StravaRun.create!(user: user, user_activity: user_activity)
        end

        run_attributes = {
          total_elevation_gain: activity_hash['total_elevation_gain'].to_f,
          elevation_high: activity_hash['elev_high'].to_f,
          elevation_low: activity_hash['elev_low'].to_f,
          start_latitude: activity_hash['start_latitude'].to_f,
          start_longitude: activity_hash['start_longitude'].to_f,
          city: activity_hash['location_city'],
          state_province: activity_hash['location_state'],
          country: activity_hash['location_country']
        }

        user_activity.activity.update_attributes!(run_attributes)
        user_activity.update_attributes!(user_activity_attributes)
      }
    end
  end
end
