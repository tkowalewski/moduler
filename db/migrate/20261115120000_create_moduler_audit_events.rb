class CreateModulerAuditEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :moduler_audit_events, id: :uuid do |t|
      # Events outlive users and organizations: removing one only removes it from its events.
      t.references :moduler_user, type: :uuid, foreign_key: { on_delete: :nullify }, index: false
      t.references :moduler_organization, type: :uuid, foreign_key: { on_delete: :nullify }, index: false
      t.string :action, null: false
      # A string, so subjects can be records of the host application with integer ids too.
      t.string :subject_type
      t.string :subject_id
      t.jsonb :metadata, null: false, default: {}
      t.string :ip_address
      t.string :request_id

      t.datetime :created_at, null: false
    end

    add_index :moduler_audit_events, :created_at
    add_index :moduler_audit_events, %i[ moduler_user_id created_at ]
    add_index :moduler_audit_events, %i[ moduler_organization_id created_at ]
    add_index :moduler_audit_events, %i[ subject_type subject_id ]
  end
end
