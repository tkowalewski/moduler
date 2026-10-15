class AddRoleToModulerUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :moduler_users, :role, :integer, default: 0
  end
end
