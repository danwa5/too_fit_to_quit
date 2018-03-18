class Api::V2::RunsController < Api::V2::ApiController
  def index
    runs = Activity::FitbitRun.includes(:user_activity)
                              .where(user: current_user)
                              .search(formatted_search_params)
                              .order('user_activities.start_time desc')
    render json: runs, status: :ok
  end

  private

  def search_params
    params.permit(:id, :start_date, :end_date, :steps_min, :steps_max, :distance_min, :distance_max, :duration_min, :duration_max, :location)
  end

  def formatted_search_params
    {
      start_date: start_date,
      end_date: end_date,
      steps_min: search_params[:steps_min],
      steps_max: search_params[:steps_max],
      distance_min: Converters::DistanceService.call(value: search_params[:distance_min], unit: 'mile'),
      distance_max: Converters::DistanceService.call(value: search_params[:distance_max], unit: 'mile'),
      duration_min: Converters::DurationService.call(value: search_params[:duration_min], unit: 'minute'),
      duration_max: Converters::DurationService.call(value: search_params[:duration_max], unit: 'minute'),
      time_zone: current_user.fitbit_identity.time_zone,
      city: search_params[:location].to_s.split(',').first
    }.compact
  end

  def start_date
    return nil unless search_params[:start_date].present?
    parse_date(search_params[:start_date])
  end

  def end_date
    return nil unless search_params[:end_date].present?
    parse_date(search_params[:end_date])
  end

  def parse_date(date)
    begin
      Date.parse(date.to_s).strftime('%Y-%m-%d')
    rescue ArgumentError
      nil
    end
  end
end
