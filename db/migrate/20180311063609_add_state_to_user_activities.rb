class AddStateToUserActivities < ActiveRecord::Migration
  def change
    add_column :user_activities, :state, :string
  end
end
