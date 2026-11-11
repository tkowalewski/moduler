class AddNameToModulerUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :moduler_users, :name, :string
  end
end
