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

ActiveRecord::Schema[7.2].define(version: 2026_05_29_003924) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "campaigns", force: :cascade do |t|
    t.string "name"
    t.text "base_story"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_campaigns_on_user_id"
  end

  create_table "campaigns_collections", id: false, force: :cascade do |t|
    t.bigint "campaign_id", null: false
    t.bigint "collection_id", null: false
    t.index ["campaign_id", "collection_id"], name: "index_campaigns_collections_on_campaign_id_and_collection_id"
    t.index ["collection_id", "campaign_id"], name: "index_campaigns_collections_on_collection_id_and_campaign_id"
  end

  create_table "cards", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name"
    t.integer "category"
    t.integer "health"
    t.integer "intelligence"
    t.integer "strength"
    t.integer "physical"
    t.integer "agility"
    t.integer "mental"
    t.decimal "weight"
    t.integer "damage"
    t.string "rarity"
    t.string "active_bonus"
    t.boolean "consumable"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.bigint "collection_id"
    t.index ["collection_id"], name: "index_cards_on_collection_id"
    t.index ["user_id"], name: "index_cards_on_user_id"
  end

  create_table "collections", force: :cascade do |t|
    t.string "name"
    t.string "artistic_style"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_collections_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "campaigns", "users"
  add_foreign_key "cards", "collections"
  add_foreign_key "cards", "users"
  add_foreign_key "collections", "users"
end
