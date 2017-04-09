module Api
  class WorkersController < Api::ApiController
    skip_before_action :authenticate_user!

    def create
      worker = "::#{worker_params}".constantize
      args = (params[:args] || [])
      args = args.to_s.split(' ') unless args.kind_of?(Array)

      jid = worker.perform_async(*args)

      render json: {queued: 'success', jid: jid}
    rescue NameError, Redis::CannotConnectError => e
      render json: {queued: 'failed' + " - " + e.message}
    end

    private

    def worker_params
      params.require(:worker)
    end

  end
end
