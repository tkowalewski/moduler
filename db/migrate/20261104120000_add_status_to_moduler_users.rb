class AddStatusToModulerUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :moduler_users, :status, :integer, default: 1, null: false
    add_index :moduler_users, :status
  end
end
