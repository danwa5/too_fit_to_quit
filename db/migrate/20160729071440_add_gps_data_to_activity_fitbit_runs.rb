class AddGpsDataToActivityFitbitRuns < ActiveRecord::Migration
  def change
    add_column :activity_fitbit_runs, :gps_data, :json
  end
end
