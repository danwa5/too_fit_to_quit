module Api
  class ApiController < ::ApplicationController
    respond_to :json
    skip_before_action :authenticate_user!
    # skip_before_filter :verify_authenticity_token
    rescue_from ActionController::ParameterMissing, with: :parameter_missing_handler

    private

    def parameter_missing_handler(e)
      respond_to do |format|
        format.json do
          render json: { status: 422 }, status: :unprocessable_entity
        end
      end
    end
  end
end
