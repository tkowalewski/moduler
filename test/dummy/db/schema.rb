# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_11_12_150000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "moduler_articles", force: :cascade do |t|
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.string "description", null: false
    t.string "keywords", null: false
    t.string "path", null: false
    t.integer "status", default: 0, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["path"], name: "index_moduler_articles_on_path", unique: true
    t.index ["status"], name: "index_moduler_articles_on_status"
  end

  create_table "moduler_documents", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "kind", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "moduler_emails", force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.string "event"
    t.string "kind", null: false
    t.string "sender"
    t.string "subject", null: false
    t.datetime "updated_at", null: false
    t.index ["event"], name: "index_moduler_emails_on_event", unique: true, where: "(event IS NOT NULL)"
  end

  create_table "moduler_memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "moduler_organization_id", null: false
    t.uuid "moduler_role_id", null: false
    t.uuid "moduler_user_id", null: false
    t.datetime "updated_at", null: false
    t.index ["moduler_organization_id", "moduler_user_id"], name: "idx_on_moduler_organization_id_moduler_user_id_36889816d0", unique: true
    t.index ["moduler_role_id"], name: "index_moduler_memberships_on_moduler_role_id"
    t.index ["moduler_user_id"], name: "index_moduler_memberships_on_moduler_user_id"
  end

  create_table "moduler_organizations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_moduler_organizations_on_name", unique: true
  end

  create_table "moduler_preferences", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "kind", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.string "value", null: false
    t.index ["name"], name: "index_moduler_preferences_on_name", unique: true
  end

  create_table "moduler_roles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "moduler_organization_id", null: false
    t.string "name", null: false
    t.string "permissions", default: [], null: false, array: true
    t.datetime "updated_at", null: false
    t.index ["moduler_organization_id", "name"], name: "index_moduler_roles_on_moduler_organization_id_and_name", unique: true
  end

  create_table "moduler_sent_emails", force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.uuid "moduler_user_id"
    t.string "subject", null: false
    t.string "to_address", null: false
    t.datetime "updated_at", null: false
    t.index ["moduler_user_id"], name: "index_moduler_sent_emails_on_moduler_user_id"
  end

  create_table "moduler_sessions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.uuid "moduler_user_id", null: false
    t.datetime "signed_in_at"
    t.datetime "signed_out_at"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.index ["moduler_user_id"], name: "index_moduler_sessions_on_moduler_user_id"
  end

  create_table "moduler_user_documents", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "moduler_document_id", null: false
    t.uuid "moduler_user_id", null: false
    t.datetime "updated_at", null: false
    t.index ["moduler_document_id", "moduler_user_id"], name: "idx_on_moduler_document_id_moduler_user_id_18d4771302", unique: true
    t.index ["moduler_user_id"], name: "index_moduler_user_documents_on_moduler_user_id"
  end

  create_table "moduler_user_emails", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "moduler_email_id", null: false
    t.uuid "moduler_user_id", null: false
    t.datetime "sent_at"
    t.datetime "updated_at", null: false
    t.index ["moduler_email_id", "moduler_user_id"], name: "idx_on_moduler_email_id_moduler_user_id_a60bc288cc", unique: true
    t.index ["moduler_user_id"], name: "index_moduler_user_emails_on_moduler_user_id"
  end

  create_table "moduler_users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "name"
    t.string "password_digest"
    t.integer "role", default: 0
    t.integer "status", default: 1, null: false
    t.string "time_zone"
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_moduler_users_on_email_address", unique: true
    t.index ["status"], name: "index_moduler_users_on_status"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "moduler_memberships", "moduler_organizations"
  add_foreign_key "moduler_memberships", "moduler_roles"
  add_foreign_key "moduler_memberships", "moduler_users"
  add_foreign_key "moduler_roles", "moduler_organizations"
  add_foreign_key "moduler_sent_emails", "moduler_users"
  add_foreign_key "moduler_sessions", "moduler_users"
  add_foreign_key "moduler_user_documents", "moduler_documents"
  add_foreign_key "moduler_user_documents", "moduler_users"
  add_foreign_key "moduler_user_emails", "moduler_emails"
  add_foreign_key "moduler_user_emails", "moduler_users"
end
