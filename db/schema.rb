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

ActiveRecord::Schema.define(version: 20181022170829) do

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
    t.string "previous_patient"
    t.string "previous_nurse"
    t.datetime "previous_start"
    t.datetime "previous_end"
    t.date "previous_anchor"
    t.bigint "nurse_id"
    t.bigint "patient_id"
    t.string "previous_color"
    t.boolean "previous_deleted"
    t.text "previous_description"
    t.string "previous_title"
    t.boolean "previous_edit_requested"
    t.integer "previous_duration"
    t.datetime "new_start"
    t.datetime "new_end"
    t.date "new_anchor"
    t.string "new_nurse"
    t.string "new_patient"
    t.string "new_title"
    t.string "new_color"
    t.boolean "new_edit_requested"
    t.index ["nurse_id"], name: "index_activities_on_nurse_id"
    t.index ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type"
    t.index ["owner_type", "owner_id"], name: "index_activities_on_owner_type_and_owner_id"
    t.index ["patient_id"], name: "index_activities_on_patient_id"
    t.index ["planning_id"], name: "index_activities_on_planning_id"
    t.index ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type"
    t.index ["recipient_type", "recipient_id"], name: "index_activities_on_recipient_type_and_recipient_id"
    t.index ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type"
    t.index ["trackable_type", "trackable_id"], name: "index_activities_on_trackable_type_and_trackable_id"
  end

  create_table "appointments", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "nurse_id"
    t.bigint "patient_id"
    t.bigint "planning_id"
    t.boolean "master"
    t.boolean "displayable"
    t.bigint "original_id"
    t.bigint "recurring_appointment_id"
    t.decimal "duration", default: "0.0"
    t.boolean "edit_requested", default: false
    t.string "color"
    t.boolean "deactivated", default: false
    t.boolean "deleted", default: false
    t.datetime "deleted_at"
    t.bigint "service_id"
    t.index ["nurse_id"], name: "index_appointments_on_nurse_id"
    t.index ["original_id"], name: "index_appointments_on_original_id"
    t.index ["patient_id"], name: "index_appointments_on_patient_id"
    t.index ["planning_id"], name: "index_appointments_on_planning_id"
    t.index ["recurring_appointment_id"], name: "index_appointments_on_recurring_appointment_id"
    t.index ["service_id"], name: "index_appointments_on_service_id"
  end

  create_table "corporations", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.string "identifier"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "default_view", default: "agendaWeek"
    t.string "business_start_hour", default: "07:00:00"
    t.string "business_end_hour", default: "24:00:00"
    t.boolean "hour_based_payroll", default: true
    t.string "email"
    t.boolean "equal_salary"
    t.text "custom_email_intro_text"
    t.text "custom_email_outro_text"
    t.string "default_master_view", default: "agendaWeek"
  end

  create_table "deleted_occurrences", force: :cascade do |t|
    t.bigint "recurring_appointment_id"
    t.date "deleted_day"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recurring_appointment_id"], name: "index_deleted_occurrences_on_recurring_appointment_id"
  end

  create_table "invoice_setting_nurses", force: :cascade do |t|
    t.bigint "invoice_setting_id"
    t.bigint "nurse_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_setting_id"], name: "index_invoice_setting_nurses_on_invoice_setting_id"
    t.index ["nurse_id"], name: "index_invoice_setting_nurses_on_nurse_id"
  end

  create_table "invoice_setting_services", force: :cascade do |t|
    t.bigint "invoice_setting_id"
    t.bigint "service_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_setting_id"], name: "index_invoice_setting_services_on_invoice_setting_id"
    t.index ["service_id"], name: "index_invoice_setting_services_on_service_id"
  end

  create_table "invoice_settings", force: :cascade do |t|
    t.bigint "corporation_id"
    t.string "title"
    t.integer "target_services_by_1"
    t.integer "target_services_by_2"
    t.integer "target_services_by_3"
    t.integer "invoice_line_option"
    t.integer "operator"
    t.decimal "argument"
    t.boolean "hour_based"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["corporation_id"], name: "index_invoice_settings_on_corporation_id"
  end

  create_table "nurses", force: :cascade do |t|
    t.string "name"
    t.string "phone_number"
    t.string "phone_mail"
    t.string "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "corporation_id"
    t.string "kana"
    t.boolean "reminderable", default: false
    t.boolean "displayable", default: true
    t.boolean "full_timer", default: false
    t.text "description"
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
    t.string "kana"
    t.boolean "active", default: true
    t.datetime "toggled_active_at"
    t.boolean "gender", default: true
    t.index ["corporation_id"], name: "index_patients_on_corporation_id"
  end

  create_table "plannings", force: :cascade do |t|
    t.integer "business_month"
    t.integer "business_year"
    t.bigint "corporation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.boolean "archived", default: false
    t.index ["corporation_id"], name: "index_plannings_on_corporation_id"
  end

  create_table "provided_services", force: :cascade do |t|
    t.string "payable_type"
    t.bigint "payable_id"
    t.integer "unit_cost"
    t.integer "service_duration"
    t.integer "total_wage"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "nurse_id"
    t.bigint "patient_id"
    t.bigint "planning_id"
    t.integer "service_counts"
    t.boolean "countable"
    t.string "title"
    t.boolean "temporary", default: false, null: false
    t.boolean "provided", default: false
    t.boolean "deactivated", default: false
    t.bigint "appointment_id"
    t.boolean "hour_based_wage", default: true
    t.datetime "service_date"
    t.datetime "appointment_start"
    t.datetime "appointment_end"
    t.bigint "invoice_setting_id"
    t.bigint "service_salary_id"
    t.index ["appointment_id"], name: "index_provided_services_on_appointment_id", unique: true
    t.index ["invoice_setting_id"], name: "index_provided_services_on_invoice_setting_id"
    t.index ["nurse_id"], name: "index_provided_services_on_nurse_id"
    t.index ["patient_id"], name: "index_provided_services_on_patient_id"
    t.index ["payable_type", "payable_id"], name: "index_provided_services_on_payable_type_and_payable_id"
    t.index ["planning_id"], name: "index_provided_services_on_planning_id"
    t.index ["service_salary_id"], name: "index_provided_services_on_service_salary_id"
  end

  create_table "recurring_appointments", force: :cascade do |t|
    t.string "title"
    t.date "anchor"
    t.integer "frequency"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "nurse_id"
    t.bigint "patient_id"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.bigint "planning_id"
    t.boolean "master"
    t.boolean "displayable"
    t.bigint "original_id"
    t.string "color"
    t.text "description"
    t.boolean "deleted"
    t.datetime "deleted_at"
    t.date "end_day"
    t.integer "duration"
    t.boolean "edit_requested", default: false
    t.boolean "deactivated", default: false
    t.bigint "service_id"
    t.index ["nurse_id"], name: "index_recurring_appointments_on_nurse_id"
    t.index ["original_id"], name: "index_recurring_appointments_on_original_id"
    t.index ["patient_id"], name: "index_recurring_appointments_on_patient_id"
    t.index ["planning_id"], name: "index_recurring_appointments_on_planning_id"
    t.index ["service_id"], name: "index_recurring_appointments_on_service_id"
  end

  create_table "recurring_unavailabilities", force: :cascade do |t|
    t.string "title"
    t.date "anchor"
    t.integer "frequency"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.bigint "planning_id"
    t.bigint "nurse_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "patient_id"
    t.index ["nurse_id"], name: "index_recurring_unavailabilities_on_nurse_id"
    t.index ["patient_id"], name: "index_recurring_unavailabilities_on_patient_id"
    t.index ["planning_id"], name: "index_recurring_unavailabilities_on_planning_id"
  end

  create_table "services", force: :cascade do |t|
    t.string "title"
    t.bigint "corporation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "unit_wage"
    t.decimal "weekend_unit_wage"
    t.bigint "nurse_id"
    t.index ["corporation_id"], name: "index_services_on_corporation_id"
    t.index ["nurse_id"], name: "index_services_on_nurse_id"
  end

  create_table "unavailabilities", force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.bigint "nurse_id"
    t.bigint "planning_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "patient_id"
    t.boolean "edit_requested", default: false
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
    t.boolean "admin", default: false
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.integer "invitations_count", default: 0
    t.string "kana"
    t.index ["corporation_id"], name: "index_users_on_corporation_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by_type_and_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "appointments", "plannings"
  add_foreign_key "deleted_occurrences", "recurring_appointments"
  add_foreign_key "invoice_setting_nurses", "invoice_settings"
  add_foreign_key "invoice_setting_nurses", "nurses"
  add_foreign_key "invoice_setting_services", "invoice_settings"
  add_foreign_key "invoice_setting_services", "services"
  add_foreign_key "invoice_settings", "corporations"
  add_foreign_key "recurring_appointments", "plannings"
  add_foreign_key "services", "corporations"
end
