class ImportsController < ApplicationController
  before_action :ensure_authenticated, only: [:create]

  def create
    if import_params[:import_date].present? && import_params[:import_date].match(/\d{4}-\d{2}-\d{2}/)
      Fitbit::FindActivityWorker.perform_async(current_user.id, import_params[:import_date])
      Strava::FindActivityWorker.perform_async(current_user.id, import_params[:import_date])
      redirect_to runs_path, notice: "Activity data from Fitbit and Strava will be imported beginning on #{import_params[:import_date]}"
    else
      redirect_to runs_path, alert: "Date needs to be in YYYY-MM-DD format"
    end
  end

  private

  def import_params
    params.permit(:import_date)
  end

  def ensure_authenticated
    if Time.now.to_i > current_user.fitbit_identity.expires_at
      redirect_to runs_path, alert: "Please re-authenticate with Fitbit before attempting to import data."
    end
  end
end
