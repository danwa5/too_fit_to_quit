class AddTcxDataToActivityFitbitRuns < ActiveRecord::Migration
  def change
    add_column :activity_fitbit_runs, :tcx_data, :xml
  end
end
