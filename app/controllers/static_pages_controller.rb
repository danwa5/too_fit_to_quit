class StaticPagesController < ApplicationController

  def index
    @options = {}
    @runs_options = {}

    if steps_params[:steps].present?
      date = parse_date(steps_params[:date])
      @options = {period: steps_params[:steps]}
      @options.merge!({date: date}) if date.present?
      results = FitbitService.get_steps(current_user.fitbit_identity, @options).parsed_response
      @steps_data = results['activities-steps']

      if results['success'] == false
        flash[:alert] = '<a href="/users/auth/fitbit_oauth2">Please request authorization from Fitbit to access your private data</a>.'.html_safe
      end
    end

    if runs_params[:after_date].present?
      date = parse_date(runs_params[:after_date])
      @runs_data = current_user.user_activities.where(activity_type: 'Activity::FitbitRun').where('start_time >= ?', date)
      
      user_activity = @runs_data.first
      gps_data = user_activity.activity.gps_data
      @loc_arr = gps_data['coordinates']
    end

    if strava_params[:commit].present? && strava_params[:commit] == 'Display Profile'
      @results = StravaService.get_profile(current_user.strava_identity).parsed_response

      if @results['success'] == false
        flash[:alert] = '<a href="/users/auth/strava">Please request authorization from Strava to access your private data</a>.'.html_safe
      else
        render json: @results
      end
    end
  end

  private

  def steps_params
    params.permit(:steps, :date)
  end

  def runs_params
    params.permit(:after_date)
  end

  def strava_params
    params.permit(:commit)
  end

  def parse_date(date)
    begin
      Date.parse(date.to_s).strftime('%Y-%m-%d')
    rescue ArgumentError
      nil
    end
  end
end