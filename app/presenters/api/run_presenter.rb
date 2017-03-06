class Api::RunPresenter < Presenters::Base
  presents :run

  def as_json(*)
    {
      'distance' => run.user_activity.distance.to_f,
      'duration' => run.user_activity.duration,
      'start_time' => run.user_activity.start_time,
      'location' => {
        'city' => run.city,
        'state_province' => run.state_province,
        'country' => run.country
      }
    }
  end
  
end
