class RunsController < ApplicationController
  include ApplicationHelper

  def index
    @dataset = Activity::FitbitRun.select('user_activities.id, user_activities.start_time, user_activities.distance, user_activities.duration, activity_fitbit_runs.steps, activity_fitbit_runs.city, activity_fitbit_runs.country')
                                  .where(user: current_user)
                                  .search(search_params)
                                  .order('user_activities.start_time')

    @monthly_breakdown = current_user.user_activities.monthly_breakdown(2016)
  end

  def show
    fitbit_run = current_user.user_activities.where(activity_type: 'Activity::FitbitRun', id: runs_params[:id]).includes(:activity).first

    if fitbit_run
      @decorated_run = RunPresenter.new(fitbit_run)
      @strava_run = current_user.user_activities.where.not(id: runs_params[:id])
                                                .where(start_time_rounded_epoch: fitbit_run.start_time_rounded_epoch)
                                                .includes(:activity).first
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
    params.permit(:id, :start_date, :end_date, :steps_min, :steps_max, :distance_min, :distance_max, :duration_min, :duration_max)
  end

  def search_params
    {
      start_date: start_date,
      end_date: end_date,
      steps_min: runs_params[:steps_min],
      steps_max: runs_params[:steps_max],
      distance_min: format_distance(runs_params[:distance_min], 'mile'),
      distance_max: format_distance(runs_params[:distance_max], 'mile'),
      duration_min: convert_to_seconds(runs_params[:duration_min]),
      duration_max: convert_to_seconds(runs_params[:duration_max]),
      time_zone: current_user.fitbit_identity.time_zone
    }
  end

  def start_date
    date = runs_params[:start_date].present? ? runs_params[:start_date] : Date.today - 90
    parse_date(date)
  end

  def end_date
    date = runs_params[:end_date].present? ? runs_params[:end_date] : Date.today
    parse_date(date)
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
      'route': {
        'type': 'geojson',
        'data': {
          'type': 'Feature',
          'properties': {},
          'geometry': {
            'type': 'LineString',
            'coordinates': @decorated_run.coordinates
          }
        }
      },
      'points': {
        'type': 'geojson',
        'data': {
          'type': 'FeatureCollection',
          'features': points
        }
      },
      'bounds': @decorated_run.bounds
    }
  end

  def points
    features = [
      {
        'type': 'Feature',
        'geometry': {
          'type': 'Point',
          'coordinates': @decorated_run.coordinates[0]
        },
        'properties': { 'icon': 'star-15' }
      },
      {
        'type': 'Feature',
        'geometry': {
          'type': 'Point',
          'coordinates': @decorated_run.coordinates[-1]
        },
        'properties': { 'icon': 'embassy-15' }
      }
    ]

    @decorated_run.markers.each do |marker|
      features << {
        'type': 'Feature',
        'geometry': {
          'type': 'Point',
          'coordinates': marker
        },
        'properties': { 'icon': 'circle-11' }
      }
    end

    features
  end
end
