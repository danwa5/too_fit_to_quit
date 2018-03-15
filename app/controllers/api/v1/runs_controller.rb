module Api
  module V1
    class RunsController < Api::V1::ApiController
      include ApplicationHelper

      before_action :run, only: :show

      def index
        runs = Activity::FitbitRun.includes(:user_activity)
                                  .select('user_activities.id, user_activities.start_time, user_activities.distance, user_activities.duration, activity_fitbit_runs.steps, activity_fitbit_runs.city, activity_fitbit_runs.country')
                                  .where(user: current_user)
                                  .search(search_params.compact)
                                  .order('user_activities.start_time')

        dataset = runs.map { |run| Api::RunPresenter.new(run) }

        render json: dataset.to_json
      end

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

      def runs_params
        params.permit(:id, :start_date, :end_date, :steps_min, :steps_max, :distance_min, :distance_max, :duration_min, :duration_max, :location)
      end

      def search_params
        {
          start_date: start_date,
          end_date: end_date,
          steps_min: runs_params[:steps_min],
          steps_max: runs_params[:steps_max],
          distance_min: format_distance(runs_params[:distance_min], 'mile'),
          distance_max: format_distance(runs_params[:distance_max], 'mile'),
          duration_min: convert_to_seconds(runs_params[:duration_min]),
          duration_max: convert_to_seconds(runs_params[:duration_max]),
          time_zone: current_user.fitbit_identity.time_zone,
          city: runs_params[:location].to_s.split(',').first
        }
      end

      def start_date
        return nil unless runs_params[:start_date].present?
        parse_date(runs_params[:start_date])
      end

      def end_date
        return nil unless runs_params[:end_date].present?
        parse_date(runs_params[:end_date])
      end

      def parse_date(date)
        begin
          Date.parse(date.to_s).strftime('%Y-%m-%d')
        rescue ArgumentError
          nil
        end
      end
    end
  end
end
