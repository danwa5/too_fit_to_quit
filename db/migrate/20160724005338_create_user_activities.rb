class CreateUserActivities < ActiveRecord::Migration
  def change
    create_table :user_activities do |t|
      t.references :user, index: true, foreign_key: true, null: false
      t.references :activity, polymorphic: true, index: true
      t.string   :uid, null: false
      t.decimal  :distance
      t.integer  :duration
      t.datetime :start_time

      t.timestamps null: false
    end

    add_index(:user_activities, [:user_id, :activity_type, :activity_id], unique: true, name: 'index_user_and_activity')
    add_index(:user_activities, [:user_id, :activity_type, :uid], unique: true)
  end
end
