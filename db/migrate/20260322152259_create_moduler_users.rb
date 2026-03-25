class CreateModulerUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :moduler_users, id: :uuid do |t|
      t.string :email_address, null: false
      t.string :password_digest

      t.timestamps null: false
    end

    add_index :moduler_users, :email_address, unique: true
  end
end
