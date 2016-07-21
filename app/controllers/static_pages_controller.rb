class StaticPagesController < ApplicationController

  def index
    @options = {}
    @runs_options = { }

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
      @runs_options = { date: date }
      results = FitbitService.get_activities_list(current_user.fitbit_identity, @runs_options).parsed_response

      if results['success'] == false
        flash[:alert] = '<a href="/users/auth/fitbit_oauth2">Please request authorization from Fitbit to access your private data</a>.'.html_safe
      else
        @runs_data = []
        results['activities'].each do |activity_hash|
          @runs_data << activity_hash if activity_hash['activityName'] == 'Run'
        end
        render json: @runs_data
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

  def parse_date(date)
    begin
      Date.parse(date.to_s).strftime('%Y-%m-%d')
    rescue ArgumentError
      nil
    end
  end
end