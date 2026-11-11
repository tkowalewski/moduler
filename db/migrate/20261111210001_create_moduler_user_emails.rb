class CreateModulerUserEmails < ActiveRecord::Migration[8.1]
  def change
    create_table :moduler_user_emails do |t|
      t.references :moduler_user, type: :uuid, null: false, foreign_key: true
      t.references :moduler_email, null: false, foreign_key: true, index: false
      t.datetime :sent_at

      t.timestamps null: false
    end

    add_index :moduler_user_emails, %i[ moduler_email_id moduler_user_id ], unique: true
  end
end
