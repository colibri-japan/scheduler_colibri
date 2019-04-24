class CreateCompletionReports < ActiveRecord::Migration[5.1]
  def change
    create_table :completion_reports do |t|
      t.references :appointment, index: true, foreign_key: true
      t.boolean :patient_looked_good
      t.boolean :patient_transpired
      t.numeric :body_temperature
      t.integer :blood_pressure_systolic
      t.integer :blood_pressure_diastolic
      t.boolean :house_was_clean
      t.boolean :patient_could_discuss
      t.boolean :patient_could_gather_and_share_information
      t.boolean :checking_report, default: true

      t.boolean :assisted_bathroom
      t.boolean :assisted_portable_bathroom
      t.boolean :changed_diapers
      t.boolean :changed_bed_pad
      t.boolean :changed_stained_clothes
      t.boolean :wiped_patient
      t.boolean :patient_urinated
      t.integer :urination_count
      t.integer :amount_of_urine
      t.boolean :patient_defecated
      t.integer :defecation_count
      t.string :visual_aspect_of_feces

      t.boolean :patient_maintains_good_posture_while_eating
      t.boolean :explained_menu_to_patient
      t.boolean :assisted_patient_to_eat
      t.boolean :patient_ate_full_plate
      t.numeric :ratio_of_leftovers
      t.boolean :patient_hydrated
      t.integer :amount_of_liquid_drank
      t.string :meal_specificities

      t.integer :full_or_partial_body_wash
      t.integer :hands_and_feet_wash
      t.boolean :hair_wash
      t.integer :bath_or_shower
      t.boolean :face_wash
      t.boolean :mouth_wash
      t.text :washing_details, array: true, default: []
      t.boolean :changed_clothes
      t.boolean :prepared_patient_to_go_out

      t.boolean :assisted_patient_to_change_body_posture
      t.boolean :assisted_patient_to_transfer
      t.boolean :assisted_patient_to_move
      t.boolean :commuted_to_the_hospital
      t.boolean :assisted_patient_to_shop
      t.boolean :assisted_patient_to_go_somewhere
      t.string :patient_destination_place

      t.boolean :assisted_patient_to_go_out_of_bed
      t.boolean :assisted_patient_to_go_to_bed

      t.text :activities_done_with_the_patient, array: true, default: []
      t.boolean :trained_patient_to_communicate
      t.boolean :trained_patient_to_memorize
      t.boolean :watch_after_patient_safety
      t.text :other_assistance_for_patient_independency

      t.boolean :assisted_to_take_medication
      t.boolean :assisted_to_apply_a_cream
      t.boolean :assisted_to_take_eye_drops
      t.boolean :assisted_to_extrude_mucus
      t.boolean :assisted_to_take_suppository
      t.string :remarks_around_medication

      t.text :clean_up, array: true, default: []
      t.boolean :took_out_trash
      t.boolean :washed_clothes
      t.boolean :dried_clothes
      t.boolean :stored_clothes
      t.boolean :ironed_clothes
      t.boolean :changed_bed_sheets
      t.boolean :changed_bed_cover
      t.boolean :dried_the_futon
      t.boolean :rearranged_clothes
      t.boolean :repaired_clothes
      t.boolean :dried_the_futon
      t.boolean :set_the_table
      t.boolean :cooked_for_the_patient
      t.boolean :cleaned_the_table
      t.string :remarks_around_cooking
      t.boolean :grocery_shopping
      t.boolean :medecine_shopping

      t.integer :amount_received_for_shopping
      t.integer :amount_spent_for_shopping
      t.integer :change_left_after_shopping
      t.string :shopping_items

      t.text :general_comment

      t.boolean :checked_gas_when_leaving
      t.boolean :checked_electricity_when_leaving
      t.boolean :checked_water_when_leaving
      t.boolean :checked_door_when_leaving

      t.timestamps
    end
  end
end
