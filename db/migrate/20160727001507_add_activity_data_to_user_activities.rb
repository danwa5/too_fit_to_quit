class AddActivityDataToUserActivities < ActiveRecord::Migration
  def change
    add_column :user_activities, :activity_data, :json
  end
end
