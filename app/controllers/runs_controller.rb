class RunsController < ApplicationController

  def index
    @runs_options = {}

    if runs_params[:after_date].present?
      date = parse_date(runs_params[:after_date])
      @dataset = current_user.user_activities.where(activity_type: 'Activity::FitbitRun')
                                               .where('start_time >= ?', date)
                                               .order(:start_time)
      @runs_options[:date] = date
    end
  end

  def show
    @run = current_user.user_activities.where(activity_type: 'Activity::FitbitRun', id: runs_params[:id]).first
    @loc_arr = @run.activity.gps_data['coordinates']
  end

  private

  def runs_params
    params.permit(:id, :after_date)
  end

  def parse_date(date)
    begin
      Date.parse(date.to_s).strftime('%Y-%m-%d')
    rescue ArgumentError
      nil
    end
  end
end