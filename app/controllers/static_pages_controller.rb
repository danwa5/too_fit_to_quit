class StaticPagesController < ApplicationController

  def index
    if params[:steps].present?
      results = FitbitService.get_steps(Identity.first, {period: params[:steps]})
      @steps_data = results.parsed_response['activities-steps']
    end
  end

end