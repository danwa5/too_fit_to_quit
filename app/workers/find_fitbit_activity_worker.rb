class FindFitbitActivityWorker
  include Sidekiq::Worker

  def perform(user_id, date=nil)
    user = User.find_by(id: user_id)
    return false if user.nil?

    options = if date.present?
      { date: date }
    else
      { date: Date.today.strftime('%Y-%m-%d') }
    end

    results = FitbitService.get_activities_list(user.fitbit_identity, options).parsed_response

    return false if results['success'] == false

    results['activities'].each do |activity_hash|
      if activity_hash['activityName'] == 'Run'
        ImportFitbitRunWorker.perform_async(user.id, activity_hash)
      end
    end

    return true
  end
end
