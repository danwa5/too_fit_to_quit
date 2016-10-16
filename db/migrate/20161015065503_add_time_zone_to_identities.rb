class AddTimeZoneToIdentities < ActiveRecord::Migration
  def change
    add_column :identities, :time_zone, :string
  end
end
