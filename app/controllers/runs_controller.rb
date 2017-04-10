class RunsController < ApplicationController

  def index
    @locations = Activity::FitbitRun.where(user: current_user).select('city, country').distinct
    @monthly_breakdown = current_user.user_activities.monthly_breakdown(Date.today.year)
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
    params.permit(:id)
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
