class RunsController < ApplicationController

  def index
    @runs_options = {}

    date = parse_date(search_date)

    @dataset = current_user.user_activities.where(activity_type: 'Activity::FitbitRun')
                                            .where('start_time >= ?', date)
                                            .includes(:activity)
                                            .order(:start_time)
    @runs_options[:date] = date
  end

  def show
    @fitbit_run = current_user.user_activities.where(activity_type: 'Activity::FitbitRun', id: runs_params[:id]).includes(:activity).first

    if @fitbit_run.present?
      @strava_run = current_user.user_activities.where.not(id: runs_params[:id])
                                                .where(start_time_rounded_epoch: @fitbit_run.start_time_rounded_epoch)
                                                .includes(:activity).first

      @chart_data  = Fitbit::GpsDataParser.new(@fitbit_run.activity.gps_data, %w(datetime altitude heart_rate)).parse
      @coordinates = Fitbit::GpsDataParser.new(@fitbit_run.activity.gps_data, %w(coordinate)).parse

      bounds = @fitbit_run.activity.gps_data['derived']['bounds']
      @bounds = [
        [ bounds['west'].to_f - 0.015, bounds['south'].to_f - 0.015 ],
        [ bounds['east'].to_f + 0.015, bounds['north'].to_f + 0.015 ]
      ]
    else
      redirect_to runs_path
    end
  end

  private

  def runs_params
    params.permit(:id, :after_date)
  end

  def search_date
    runs_params[:after_date].present? ? runs_params[:after_date] : Date.today - 60
  end

  def parse_date(date)
    begin
      Date.parse(date.to_s).strftime('%Y-%m-%d')
    rescue ArgumentError
      nil
    end
  end
end