class CreateActivityStravaRuns < ActiveRecord::Migration
  def change
    create_table :activity_strava_runs do |t|
      t.references :user, index: true, foreign_key: true, null: false
      t.decimal :total_elevation_gain
      t.decimal :elevation_high
      t.decimal :elevation_low

      t.timestamps null: false
    end
  end
end
