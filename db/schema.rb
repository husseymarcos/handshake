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

ActiveRecord::Schema[8.1].define(version: 2026_04_21_183954) do
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

  create_table "capabilities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "professional_id", null: false
    t.datetime "updated_at", null: false
    t.index ["professional_id"], name: "index_capabilities_on_professional_id"
  end

  create_table "experiences", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "github_url"
    t.string "name"
    t.integer "professional_id", null: false
    t.string "stack"
    t.string "title"
    t.datetime "updated_at", null: false
    t.integer "year"
    t.index ["professional_id"], name: "index_experiences_on_professional_id"
  end

  create_table "opportunities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "generated_typst"
    t.string "organization_name", null: false
    t.text "posting", null: false
    t.boolean "posting_truncated", default: false, null: false
    t.integer "professional_id", null: false
    t.datetime "updated_at", null: false
    t.index ["professional_id"], name: "index_opportunities_on_professional_id"
  end

  create_table "professionals", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "handle"
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_professionals_on_email", unique: true
    t.index ["handle"], name: "index_professionals_on_handle", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "professional_id", null: false
    t.string "token_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["professional_id"], name: "index_sessions_on_professional_id"
    t.index ["token_digest"], name: "index_sessions_on_token_digest", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "capabilities", "professionals"
  add_foreign_key "experiences", "professionals"
  add_foreign_key "opportunities", "professionals"
  add_foreign_key "sessions", "professionals"
end
