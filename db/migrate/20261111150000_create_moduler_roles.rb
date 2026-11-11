class CreateModulerRoles < ActiveRecord::Migration[8.1]
  def change
    create_table :moduler_roles, id: :uuid do |t|
      t.references :moduler_organization, type: :uuid, null: false, foreign_key: true, index: false
      t.string :name, null: false
      t.string :permissions, array: true, null: false, default: []

      t.timestamps null: false
    end

    add_index :moduler_roles, %i[ moduler_organization_id name ], unique: true
  end
end
