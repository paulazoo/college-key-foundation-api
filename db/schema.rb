# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_07_19_062207) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "google_id"
    t.string "name"
    t.string "email"
    t.string "image_url"
    t.string "token"
    t.string "display_name"
    t.string "given_name"
    t.string "family_name"
    t.string "phone"
    t.string "bio"
    t.string "user_type"
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "school"
    t.integer "grad_year"
    t.index ["user_type", "user_id"], name: "index_accounts_on_user_type_and_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "link"
    t.string "image_url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer "kind", default: 0
    t.string "host"
  end

  create_table "invitations", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "event_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["account_id"], name: "index_invitations_on_account_id"
    t.index ["event_id"], name: "index_invitations_on_event_id"
  end

  create_table "mentees", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "mentors", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "mentors_mentees", force: :cascade do |t|
    t.bigint "mentor_id", null: false
    t.bigint "mentee_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["mentee_id"], name: "index_mentors_mentees_on_mentee_id"
    t.index ["mentor_id", "mentee_id"], name: "index_mentors_mentees_on_mentor_id_and_mentee_id", unique: true
    t.index ["mentor_id"], name: "index_mentors_mentees_on_mentor_id"
  end

  create_table "newsletter_emails", force: :cascade do |t|
    t.string "email"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "invitations", "accounts"
  add_foreign_key "invitations", "events"
  add_foreign_key "mentors_mentees", "mentees"
  add_foreign_key "mentors_mentees", "mentors"
end
