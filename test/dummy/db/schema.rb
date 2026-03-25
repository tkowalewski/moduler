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

ActiveRecord::Schema[8.1].define(version: 2026_03_22_153744) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

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

  create_table "moduler_users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest"
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_moduler_users_on_email_address", unique: true
  end

  add_foreign_key "moduler_sessions", "moduler_users"
end
