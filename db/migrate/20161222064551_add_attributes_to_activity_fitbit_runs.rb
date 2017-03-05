class AddAttributesToActivityFitbitRuns < ActiveRecord::Migration
  def change
    add_column :activity_fitbit_runs, :city, :string
    add_column :activity_fitbit_runs, :state_province, :string
    add_column :activity_fitbit_runs, :country, :string
  end
end
