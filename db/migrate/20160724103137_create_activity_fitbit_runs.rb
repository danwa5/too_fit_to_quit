class CreateActivityFitbitRuns < ActiveRecord::Migration
  def change
    create_table :activity_fitbit_runs do |t|
      t.references :user, index: true, foreign_key: true, null: false
      t.integer :activity_type_id
      t.integer :avg_heart_rate
      t.integer :steps

      t.timestamps null: false
    end
  end
end
