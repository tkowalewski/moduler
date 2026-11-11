class CreateModulerEmails < ActiveRecord::Migration[8.1]
  def change
    create_table :moduler_emails do |t|
      t.string :subject, null: false
      t.string :sender
      t.string :kind, null: false
      t.string :event
      t.text :body, null: false

      t.timestamps null: false
    end

    add_index :moduler_emails, :event, unique: true, where: "event IS NOT NULL"
  end
end
