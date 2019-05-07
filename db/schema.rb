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

ActiveRecord::Schema.define(version: 20190507161455) do

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
    t.boolean "previous_cancelled"
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
    t.boolean "cancelled", default: false
    t.datetime "archived_at"
    t.bigint "service_id"
    t.index ["nurse_id"], name: "index_appointments_on_nurse_id"
    t.index ["original_id"], name: "index_appointments_on_original_id"
    t.index ["patient_id"], name: "index_appointments_on_patient_id"
    t.index ["planning_id"], name: "index_appointments_on_planning_id"
    t.index ["recurring_appointment_id"], name: "index_appointments_on_recurring_appointment_id"
    t.index ["service_id"], name: "index_appointments_on_service_id"
  end

  create_table "care_manager_corporations", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.string "phone_number"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "corporation_id"
    t.index ["corporation_id"], name: "index_care_manager_corporations_on_corporation_id"
  end

  create_table "care_managers", force: :cascade do |t|
    t.string "name"
    t.string "kana"
    t.bigint "care_manager_corporation_id"
    t.string "registration_id"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "phone_number"
    t.index ["care_manager_corporation_id"], name: "index_care_managers_on_care_manager_corporation_id"
  end

  create_table "completion_reports", force: :cascade do |t|
    t.bigint "appointment_id"
    t.boolean "patient_looked_good"
    t.boolean "patient_transpired"
    t.decimal "body_temperature"
    t.integer "blood_pressure_systolic"
    t.integer "blood_pressure_diastolic"
    t.boolean "house_was_clean"
    t.boolean "patient_could_discuss"
    t.boolean "patient_could_gather_and_share_information"
    t.boolean "checking_report", default: true
    t.boolean "assisted_bathroom"
    t.boolean "assisted_portable_bathroom"
    t.boolean "changed_diapers"
    t.boolean "changed_bed_pad"
    t.boolean "changed_stained_clothes"
    t.boolean "wiped_patient"
    t.boolean "patient_urinated"
    t.integer "urination_count"
    t.integer "amount_of_urine"
    t.boolean "patient_defecated"
    t.integer "defecation_count"
    t.string "visual_aspect_of_feces"
    t.boolean "patient_maintains_good_posture_while_eating"
    t.boolean "explained_menu_to_patient"
    t.boolean "assisted_patient_to_eat"
    t.boolean "patient_ate_full_plate"
    t.decimal "ratio_of_leftovers"
    t.boolean "patient_hydrated"
    t.integer "amount_of_liquid_drank"
    t.string "meal_specificities"
    t.integer "full_or_partial_body_wash"
    t.integer "hands_and_feet_wash"
    t.boolean "hair_wash"
    t.integer "bath_or_shower"
    t.boolean "face_wash"
    t.boolean "mouth_wash"
    t.text "washing_details", default: [], array: true
    t.boolean "changed_clothes"
    t.boolean "prepared_patient_to_go_out"
    t.boolean "assisted_patient_to_change_body_posture"
    t.boolean "assisted_patient_to_transfer"
    t.boolean "assisted_patient_to_move"
    t.boolean "commuted_to_the_hospital"
    t.boolean "assisted_patient_to_shop"
    t.boolean "assisted_patient_to_go_somewhere"
    t.string "patient_destination_place"
    t.boolean "assisted_patient_to_go_out_of_bed"
    t.boolean "assisted_patient_to_go_to_bed"
    t.text "activities_done_with_the_patient", default: [], array: true
    t.boolean "trained_patient_to_communicate"
    t.boolean "trained_patient_to_memorize"
    t.boolean "watch_after_patient_safety"
    t.text "other_assistance_for_patient_independency"
    t.boolean "assisted_to_take_medication"
    t.boolean "assisted_to_apply_a_cream"
    t.boolean "assisted_to_take_eye_drops"
    t.boolean "assisted_to_extrude_mucus"
    t.boolean "assisted_to_take_suppository"
    t.string "remarks_around_medication"
    t.text "clean_up", default: [], array: true
    t.boolean "took_out_trash"
    t.boolean "washed_clothes"
    t.boolean "dried_clothes"
    t.boolean "stored_clothes"
    t.boolean "ironed_clothes"
    t.boolean "changed_bed_sheets"
    t.boolean "changed_bed_cover"
    t.boolean "dried_the_futon"
    t.boolean "rearranged_clothes"
    t.boolean "repaired_clothes"
    t.boolean "set_the_table"
    t.boolean "cooked_for_the_patient"
    t.boolean "cleaned_the_table"
    t.string "remarks_around_cooking"
    t.boolean "grocery_shopping"
    t.boolean "medecine_shopping"
    t.integer "amount_received_for_shopping"
    t.integer "amount_spent_for_shopping"
    t.integer "change_left_after_shopping"
    t.string "shopping_items"
    t.text "general_comment"
    t.boolean "checked_gas_when_leaving"
    t.boolean "checked_electricity_when_leaving"
    t.boolean "checked_water_when_leaving"
    t.boolean "checked_door_when_leaving"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["appointment_id"], name: "index_completion_reports_on_appointment_id"
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
    t.string "default_individual_view", default: "agendaWeek"
    t.integer "default_first_day", default: 1
    t.string "reminder_email_hour", default: "11:00"
    t.integer "weekend_reminder_option", default: 0
    t.boolean "include_description_in_nurse_mailer", default: false
    t.string "non_master_schedule_default_url"
    t.decimal "credits_to_jpy_ratio"
    t.boolean "detailed_cancellation_options", default: true
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
    t.bigint "team_id"
    t.integer "days_worked", default: 0
    t.index ["corporation_id"], name: "index_nurses_on_corporation_id"
    t.index ["team_id"], name: "index_nurses_on_team_id"
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
    t.text "description"
    t.string "care_manager_name"
    t.string "doctor_name"
    t.integer "insurance_category"
    t.integer "kaigo_level"
    t.date "date_of_contract"
    t.bigint "nurse_id"
    t.integer "handicap_level"
    t.text "insurance_policy", default: [], array: true
    t.string "insurance_id"
    t.date "birthday"
    t.date "kaigo_certification_validity_start"
    t.date "kaigo_certification_validity_end"
    t.integer "ratio_paid_by_patient"
    t.string "public_assistance_id_1"
    t.string "public_assistance_id_2"
    t.date "end_of_contract"
    t.string "birthday_era"
    t.bigint "care_manager_id"
    t.index ["care_manager_id"], name: "index_patients_on_care_manager_id"
    t.index ["corporation_id"], name: "index_patients_on_corporation_id"
    t.index ["nurse_id"], name: "index_patients_on_nurse_id"
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

  create_table "posts", force: :cascade do |t|
    t.text "body"
    t.bigint "corporation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "author_id"
    t.bigint "patient_id"
    t.datetime "published_at"
    t.index ["author_id"], name: "index_posts_on_author_id"
    t.index ["corporation_id"], name: "index_posts_on_corporation_id"
    t.index ["patient_id"], name: "index_posts_on_patient_id"
  end

  create_table "printing_options", force: :cascade do |t|
    t.bigint "corporation_id"
    t.boolean "print_patient_comments", default: false
    t.boolean "print_nurse_comments", default: false
    t.boolean "print_patient_comments_in_master", default: false
    t.boolean "print_nurse_comments_in_master", default: false
    t.boolean "print_patient_dates", default: true
    t.boolean "print_nurse_dates", default: true
    t.boolean "print_patient_dates_in_master", default: true
    t.boolean "print_nurse_dates_in_master", default: true
    t.boolean "print_patient_description", default: false
    t.boolean "print_nurse_description", default: false
    t.boolean "print_patient_description_in_master", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "print_nurse_description_in_master", default: false
    t.index ["corporation_id"], name: "index_printing_options_on_corporation_id"
  end

  create_table "private_events", force: :cascade do |t|
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
    t.index ["nurse_id"], name: "index_private_events_on_nurse_id"
    t.index ["patient_id"], name: "index_private_events_on_patient_id"
    t.index ["planning_id"], name: "index_private_events_on_planning_id"
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
    t.boolean "cancelled", default: false
    t.bigint "appointment_id"
    t.boolean "hour_based_wage", default: true
    t.datetime "service_date"
    t.datetime "appointment_start"
    t.datetime "appointment_end"
    t.bigint "service_salary_id"
    t.datetime "verified_at"
    t.datetime "archived_at"
    t.bigint "verifier_id"
    t.bigint "second_verifier_id"
    t.datetime "second_verified_at"
    t.bigint "salary_rule_id"
    t.integer "total_credits"
    t.integer "invoiced_total"
    t.index ["appointment_id"], name: "index_provided_services_on_appointment_id", unique: true
    t.index ["nurse_id"], name: "index_provided_services_on_nurse_id"
    t.index ["patient_id"], name: "index_provided_services_on_patient_id"
    t.index ["payable_type", "payable_id"], name: "index_provided_services_on_payable_type_and_payable_id"
    t.index ["planning_id"], name: "index_provided_services_on_planning_id"
    t.index ["salary_rule_id"], name: "index_provided_services_on_salary_rule_id"
    t.index ["second_verifier_id"], name: "index_provided_services_on_second_verifier_id"
    t.index ["service_salary_id"], name: "index_provided_services_on_service_salary_id"
    t.index ["verifier_id"], name: "index_provided_services_on_verifier_id"
  end

  create_table "read_marks", id: :serial, force: :cascade do |t|
    t.string "readable_type", null: false
    t.integer "readable_id"
    t.string "reader_type", null: false
    t.integer "reader_id"
    t.datetime "timestamp"
    t.index ["readable_type", "readable_id"], name: "index_read_marks_on_readable_type_and_readable_id"
    t.index ["reader_id", "reader_type", "readable_type", "readable_id"], name: "read_marks_reader_readable_index", unique: true
    t.index ["reader_type", "reader_id"], name: "index_read_marks_on_reader_type_and_reader_id"
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
    t.datetime "archived_at"
    t.date "end_day"
    t.integer "duration"
    t.boolean "edit_requested", default: false
    t.boolean "cancelled", default: false
    t.bigint "service_id"
    t.boolean "duplicatable", default: true
    t.datetime "termination_date"
    t.index ["nurse_id"], name: "index_recurring_appointments_on_nurse_id"
    t.index ["original_id"], name: "index_recurring_appointments_on_original_id"
    t.index ["patient_id"], name: "index_recurring_appointments_on_patient_id"
    t.index ["planning_id"], name: "index_recurring_appointments_on_planning_id"
    t.index ["service_id"], name: "index_recurring_appointments_on_service_id"
  end

  create_table "reminders", force: :cascade do |t|
    t.datetime "anchor"
    t.integer "frequency"
    t.string "reminderable_type"
    t.bigint "reminderable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reminderable_type", "reminderable_id"], name: "index_reminders_on_reminderable_type_and_reminderable_id"
  end

  create_table "salary_rules", force: :cascade do |t|
    t.string "title"
    t.bigint "corporation_id"
    t.boolean "target_all_nurses", default: true
    t.text "nurse_id_list", default: [], array: true
    t.boolean "target_all_services", default: true
    t.text "service_title_list", default: [], array: true
    t.integer "date_constraint", default: 0
    t.integer "operator"
    t.decimal "argument"
    t.date "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "hour_based"
    t.integer "target_nurse_by_filter"
    t.index ["corporation_id"], name: "index_salary_rules_on_corporation_id"
  end

  create_table "services", force: :cascade do |t|
    t.string "title"
    t.bigint "corporation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "unit_wage"
    t.decimal "weekend_unit_wage"
    t.bigint "nurse_id"
    t.boolean "hour_based_wage"
    t.boolean "equal_salary"
    t.integer "category_1"
    t.integer "category_2"
    t.decimal "category_ratio"
    t.string "official_title"
    t.integer "unit_credits"
    t.string "service_code"
    t.index ["corporation_id"], name: "index_services_on_corporation_id"
    t.index ["nurse_id"], name: "index_services_on_nurse_id"
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.integer "taggable_id"
    t.string "tagger_type"
    t.integer "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at"
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "teams", force: :cascade do |t|
    t.bigint "corporation_id"
    t.string "team_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "credits_to_jpy_ratio"
    t.index ["corporation_id"], name: "index_teams_on_corporation_id"
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
    t.integer "role", default: 1
    t.bigint "nurse_id"
    t.string "schedule_default_url_option"
    t.index ["corporation_id"], name: "index_users_on_corporation_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by_type_and_invited_by_id"
    t.index ["nurse_id"], name: "index_users_on_nurse_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "wished_slots", force: :cascade do |t|
    t.string "title"
    t.date "anchor"
    t.integer "frequency"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.bigint "planning_id"
    t.bigint "nurse_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.date "end_day"
    t.integer "rank"
    t.integer "duration"
    t.index ["nurse_id"], name: "index_wished_slots_on_nurse_id"
    t.index ["planning_id"], name: "index_wished_slots_on_planning_id"
  end

  add_foreign_key "appointments", "plannings"
  add_foreign_key "care_manager_corporations", "corporations"
  add_foreign_key "completion_reports", "appointments"
  add_foreign_key "posts", "corporations"
  add_foreign_key "posts", "users", column: "author_id"
  add_foreign_key "printing_options", "corporations"
  add_foreign_key "provided_services", "users", column: "second_verifier_id"
  add_foreign_key "provided_services", "users", column: "verifier_id"
  add_foreign_key "recurring_appointments", "plannings"
  add_foreign_key "salary_rules", "corporations"
  add_foreign_key "services", "corporations"
  add_foreign_key "teams", "corporations"
end
