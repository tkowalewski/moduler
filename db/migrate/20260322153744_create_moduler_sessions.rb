class CreateModulerSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :moduler_sessions, id: :uuid do |t|
      t.references :moduler_user, null: false, foreign_key: true, type: :uuid
      t.string :ip_address
      t.string :user_agent
      t.datetime :signed_in_at
      t.datetime :signed_out_at

      t.timestamps null: false
    end
  end
end
