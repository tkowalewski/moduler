class CreateModulerUserDocuments < ActiveRecord::Migration[8.1]
  def change
    create_table :moduler_user_documents do |t|
      t.references :moduler_user, type: :uuid, null: false, foreign_key: true
      t.references :moduler_document, null: false, foreign_key: true, index: false

      t.timestamps
    end

    add_index :moduler_user_documents, %i[ moduler_document_id moduler_user_id ], unique: true
  end
end
