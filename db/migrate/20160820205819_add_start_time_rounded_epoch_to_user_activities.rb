class AddStartTimeRoundedEpochToUserActivities < ActiveRecord::Migration
  def change
    add_column :user_activities, :start_time_rounded_epoch, :integer

    add_index(:user_activities, [:user_id, :start_time_rounded_epoch])
  end
end
