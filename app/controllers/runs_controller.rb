class RunsController < ApplicationController

  def index
    @runs_options = {}

    search_date = runs_params[:after_date].present? ? runs_params[:after_date] : Date.today - 60
    date = parse_date(search_date)

    @dataset = current_user.user_activities.where(activity_type: 'Activity::FitbitRun')
                                               .where('start_time >= ?', date)
                                               .order(:start_time)
    @runs_options[:date] = date
  end

  def show
    @run = current_user.user_activities.where(activity_type: 'Activity::FitbitRun', id: runs_params[:id]).first
    @chart_data  = Fitbit::GpsDataParser.new(@run.activity.gps_data, %w(datetime altitude heart_rate)).parse
    @coordinates = Fitbit::GpsDataParser.new(@run.activity.gps_data, %w(coordinate)).parse

    bounds = @run.activity.gps_data['derived']['bounds']
    @bounds = [
      [ bounds['west'].to_f - 0.008, bounds['south'].to_f - 0.008 ],
      [ bounds['east'].to_f + 0.008, bounds['north'].to_f + 0.008 ]
    ]
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