class CreateModulerSentEmails < ActiveRecord::Migration[8.1]
  def change
    create_table :moduler_sent_emails do |t|
      t.references :moduler_user, type: :uuid, foreign_key: true
      t.string :to_address, null: false
      t.string :subject, null: false
      t.text :body, null: false

      t.timestamps null: false
    end
  end
end
