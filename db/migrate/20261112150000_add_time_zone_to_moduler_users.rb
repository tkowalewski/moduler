class AddTimeZoneToModulerUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :moduler_users, :time_zone, :string
  end
end
