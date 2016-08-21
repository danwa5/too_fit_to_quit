class AddSplitsToActivityStravaRuns < ActiveRecord::Migration
  def change
    add_column :activity_strava_runs, :splits, :json
  end
end
