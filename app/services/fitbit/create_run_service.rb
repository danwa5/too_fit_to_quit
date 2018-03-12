module Fitbit
  class CreateRunService
    include Services::BaseService
    extend Dry::Initializer

    option :user
    option :activity_hash

    def call
      Try() {
        user_activity = UserActivity.where(user_id: @user.id, activity_type: 'Activity::FitbitRun', uid: @activity_hash['logId']).first_or_create!

        if user_activity.processed?
          nil
        else
          user_activity.processing!

          user_activity_attributes = {
            duration: set_duration,
            distance: set_distance,
            start_time: set_start_time,
            start_time_rounded_epoch: start_time_rounded_epoch(@activity_hash['startTime']),
            activity_data: @activity_hash
          }

          unless user_activity.activity.present?
            user_activity_attributes[:activity] = Activity::FitbitRun.create!(user: user, user_activity: user_activity)
          end

          run_attributes = {
            activity_type_id: @activity_hash['activityTypeId'].to_i,
            steps: @activity_hash['steps'].to_i
          }

          user_activity.activity.update_attributes!(run_attributes)
          user_activity.update_attributes!(user_activity_attributes)

          user_activity
        end
      }
    end

    private

    def set_duration
      @activity_hash['activeDuration'].to_i / 1000
    end

    def set_start_time
      DateTime.parse(@activity_hash['startTime'])
    end

    def set_distance
      (@activity_hash['distance'].to_f) * 1000 if @activity_hash['distanceUnit'] == 'Kilometer'
    end
  end
end
