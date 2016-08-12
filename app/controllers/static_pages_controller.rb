class StaticPagesController < ApplicationController

  def index
    @runs_options = {}

    if runs_params[:after_date].present?
      date = parse_date(runs_params[:after_date])
      @runs_data = current_user.user_activities.where(activity_type: 'Activity::FitbitRun').where('start_time >= ?', date)
      
      user_activity = @runs_data.first
      gps_data = user_activity.activity.gps_data
      @loc_arr = gps_data['coordinates']
      @runs_options[:date] = date
    end
  end

  private

  def runs_params
    params.permit(:after_date)
  end

  def parse_date(date)
    begin
      Date.parse(date.to_s).strftime('%Y-%m-%d')
    rescue ArgumentError
      nil
    end
  end
end