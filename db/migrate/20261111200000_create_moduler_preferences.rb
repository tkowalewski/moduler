class CreateModulerPreferences < ActiveRecord::Migration[8.1]
  def change
    create_table :moduler_preferences, id: :uuid do |t|
      t.string :kind, null: false
      t.string :name, null: false
      t.string :value, null: false

      t.timestamps null: false
    end

    add_index :moduler_preferences, :name, unique: true
  end
end
