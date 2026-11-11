class CreateModulerOrganizations < ActiveRecord::Migration[8.1]
  def change
    create_table :moduler_organizations, id: :uuid do |t|
      t.string :name, null: false

      t.timestamps null: false
    end

    add_index :moduler_organizations, :name, unique: true
  end
end
