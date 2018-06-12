# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180612134744) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activities", force: :cascade do |t|
    t.string "trackable_type"
    t.bigint "trackable_id"
    t.string "owner_type"
    t.bigint "owner_id"
    t.string "key"
    t.text "parameters"
    t.string "recipient_type"
    t.bigint "recipient_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "planning_id"
    t.index ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type"
    t.index ["owner_type", "owner_id"], name: "index_activities_on_owner_type_and_owner_id"
    t.index ["planning_id"], name: "index_activities_on_planning_id"
    t.index ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type"
    t.index ["recipient_type", "recipient_id"], name: "index_activities_on_recipient_type_and_recipient_id"
    t.index ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type"
    t.index ["trackable_type", "trackable_id"], name: "index_activities_on_trackable_type_and_trackable_id"
  end

  create_table "appointments", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "start"
    t.datetime "end"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "nurse_id"
    t.bigint "patient_id"
    t.bigint "planning_id"
    t.index ["nurse_id"], name: "index_appointments_on_nurse_id"
    t.index ["patient_id"], name: "index_appointments_on_patient_id"
    t.index ["planning_id"], name: "index_appointments_on_planning_id"
  end

  create_table "corporations", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.string "identifier"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "nurses", force: :cascade do |t|
    t.string "name"
    t.string "phone_number"
    t.string "phone_mail"
    t.string "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "corporation_id"
    t.index ["corporation_id"], name: "index_nurses_on_corporation_id"
  end

  create_table "patients", force: :cascade do |t|
    t.string "name"
    t.string "phone_number"
    t.string "phone_mail"
    t.string "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "corporation_id"
    t.index ["corporation_id"], name: "index_patients_on_corporation_id"
  end

  create_table "plannings", force: :cascade do |t|
    t.integer "business_month"
    t.integer "business_year"
    t.bigint "corporation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["corporation_id"], name: "index_plannings_on_corporation_id"
  end

  create_table "recurring_appointments", force: :cascade do |t|
    t.string "title"
    t.date "anchor"
    t.integer "frequency"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "nurse_id"
    t.bigint "patient_id"
    t.datetime "start"
    t.datetime "end"
    t.bigint "planning_id"
    t.index ["nurse_id"], name: "index_recurring_appointments_on_nurse_id"
    t.index ["patient_id"], name: "index_recurring_appointments_on_patient_id"
    t.index ["planning_id"], name: "index_recurring_appointments_on_planning_id"
  end

  create_table "recurring_unavailabilities", force: :cascade do |t|
    t.string "title"
    t.date "anchor"
    t.integer "frequency"
    t.datetime "start"
    t.datetime "end"
    t.bigint "planning_id"
    t.bigint "nurse_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "patient_id"
    t.index ["nurse_id"], name: "index_recurring_unavailabilities_on_nurse_id"
    t.index ["patient_id"], name: "index_recurring_unavailabilities_on_patient_id"
    t.index ["planning_id"], name: "index_recurring_unavailabilities_on_planning_id"
  end

  create_table "unavailabilities", force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.datetime "start"
    t.datetime "end"
    t.bigint "nurse_id"
    t.bigint "planning_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "patient_id"
    t.index ["nurse_id"], name: "index_unavailabilities_on_nurse_id"
    t.index ["patient_id"], name: "index_unavailabilities_on_patient_id"
    t.index ["planning_id"], name: "index_unavailabilities_on_planning_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.bigint "corporation_id"
    t.index ["corporation_id"], name: "index_users_on_corporation_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "appointments", "plannings"
  add_foreign_key "recurring_appointments", "plannings"
end
