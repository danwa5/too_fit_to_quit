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
      @bounds = [[bounds['west'],bounds['south']], [bounds['east'],bounds['north']]]
      @markers = @fitbit_run.activity.gps_data['derived']['markers']

      respond_to do |format|
        format.html
        format.json { render json: geojson }
      end
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

  def geojson
    {
      "route": {
        "type": "geojson",
        "data": {
          "type": "Feature",
          "properties": {},
          "geometry": {
            "type": "LineString",
            "coordinates": @coordinates
          }
        }
      },
      "points": {
        "type": "geojson",
        "data": {
          "type": "FeatureCollection",
          "features": points
        }
      },
      "bounds": @bounds
    }
  end

  def points
    features = [
      {
        "type": "Feature",
        "geometry": {
          "type": "Point",
          "coordinates": @coordinates[0]
        },
        "properties": { "icon": "star-15" }
      },
      {
        "type": "Feature",
        "geometry": {
          "type": "Point",
          "coordinates": @coordinates[-1]
        },
        "properties": { "icon": "embassy-15" }
      }
    ]

    @markers.each do |marker|
      features << {
        "type": "Feature",
        "geometry": {
          "type": "Point",
          "coordinates": marker
        },
        "properties": { "icon": "circle-11" }
      }
    end

    features
  end
end
