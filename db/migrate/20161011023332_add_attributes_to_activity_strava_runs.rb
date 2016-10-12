class AddAttributesToActivityStravaRuns < ActiveRecord::Migration
  def change
    add_column :activity_strava_runs, :start_latitude, :decimal
    add_column :activity_strava_runs, :start_longitude, :decimal
    add_column :activity_strava_runs, :city, :string
    add_column :activity_strava_runs, :state_province, :string
    add_column :activity_strava_runs, :country, :string
  end
end
