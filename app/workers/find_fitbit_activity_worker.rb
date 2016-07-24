class FindFitbitActivityWorker
  include Sidekiq::Worker

  def perform(user, date=nil)
    return false if user.nil?

    options = {}
    options.merge!({date: Date.today.strftime('%Y-%m-%d')}) if date.blank?
    results = FitbitService.get_activities_list(user.fitbit_identity, options).parsed_response

    return false if results['success'] == false

    results['activities'].each do |activity_hash|
      if activity_hash['activityName'] == 'Run'
        ImportFitbitRunWorker.perform_async(user, activity_hash)
      end
    end

    return true
  end
end
