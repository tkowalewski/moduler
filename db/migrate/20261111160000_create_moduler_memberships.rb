class CreateModulerMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :moduler_memberships, id: :uuid do |t|
      t.references :moduler_user, type: :uuid, null: false, foreign_key: true
      t.references :moduler_organization, type: :uuid, null: false, foreign_key: true, index: false
      t.references :moduler_role, type: :uuid, null: false, foreign_key: true

      t.timestamps null: false
    end

    add_index :moduler_memberships, %i[ moduler_organization_id moduler_user_id ], unique: true
  end
end
