module Api
  class RunsController < Api::ApiController
    before_action :run, only: :show

    def show
      if run
        render json: Api::RunPresenter.new(run)
      else
        render json: {}, status: :not_found
      end
    end

    private

    def run
      @run ||= Activity::FitbitRun.find_by(id: params[:id])
    end
  end
end
