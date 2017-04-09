class Api::RunPresenter < Presenters::Base
  include ApplicationHelper

  presents :run

  def as_json(*)
    {
      'id' => run.user_activity.id,
      'distance' => format_distance(run.user_activity.distance.to_f),
      'duration' => format_duration(run.user_activity.duration),
      'location' => run.location,
      'pace' => format_pace(run.user_activity.duration, run.user_activity.distance),
      'start_time' => format_run_time(run.user_activity.start_time),
      'steps' => run.steps
    }
  end
end
