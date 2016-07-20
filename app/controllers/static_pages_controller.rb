class StaticPagesController < ApplicationController

  def index
    @options = {}
    if steps_params[:steps].present?
      date = parse_date(steps_params[:date])
      @options = {period: steps_params[:steps]}
      @options.merge!({date: date}) if date.present?
      results = FitbitService.get_steps(Identity.first, @options).parsed_response
      @steps_data = results['activities-steps']

      if results['success'] == false
        flash[:alert] = '<a href="/users/auth/fitbit_oauth2">Please request authorization from Fitbit to access your private data</a>.'.html_safe
      end
    end
  end

  private

  def steps_params
    params.permit(:steps, :date)
  end

  def parse_date(date)
    begin
      Date.parse(date.to_s).strftime('%Y-%m-%d')
    rescue ArgumentError
      nil
    end
  end
end