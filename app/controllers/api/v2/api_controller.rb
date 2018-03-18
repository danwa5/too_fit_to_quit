class Api::V2::ApiController < ::ApplicationController
  # include WardenHelper

  protect_from_forgery with: :null_session

  rescue_from ActiveRecord::RecordNotFound,       with: :not_found
  rescue_from ActionController::ParameterMissing, with: :missing_param_error

  private

  def not_found
    render json: '', status: :not_found
  end

  def missing_param_error(exception)
    render json: { error: exception.message }, status: :unprocessable_entity
  end
end
