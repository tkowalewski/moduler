class CreateModulerDocuments < ActiveRecord::Migration[8.1]
  def change
    create_table :moduler_documents do |t|
      t.string :name, null: false
      t.string :kind, null: false

      t.timestamps null: false
    end
  end
end
