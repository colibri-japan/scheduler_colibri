class CompletionReport < ApplicationRecord
    belongs_to :reportable, polymorphic: true

    scope :from_appointments, -> { where(reportable_type: 'Appointment') }
    scope :from_recurring_appointments, -> { where(reportable_type: 'RecurringAppointment') }

    def with_personal_care?
        #evaluate if any personal care element has been checked
        with_bathroom_assistance? || with_feeding? || with_body_cleaning? ||
        with_movement_assistance? || with_bed_assistance?
    end

    def with_bathroom_assistance?
        new_record? ||
        assisted_bathroom? || assisted_portable_bathroom? ||  changed_diapers? ||
        changed_bed_pad? || changed_stained_clothes? || wiped_patient? || patient_urinated? ||
        urination_count.present? || amount_of_urine.present? || patient_defecated? ||
        defecation_count.present? || visual_aspect_of_feces.present? 
    end

    def with_feeding?
        new_record? ||
        patient_maintains_good_posture_while_eating? || explained_menu_to_patient? ||
        assisted_patient_to_eat? || patient_ate_full_plate.present? || ratio_of_leftovers.present? || 
        patient_hydrated? || amount_of_liquid_drank.present? || meal_specificities.present?
    end

    def with_body_cleaning?
        new_record? ||
        full_or_partial_body_wash? || hands_and_feet_wash? || hair_wash? ||
        bath_or_shower? || face_wash? ||  mouth_wash? || washing_details != [''] || 
        changed_clothes? 
    end

    def with_movement_assistance?
        new_record? || 
        assisted_patient_to_change_body_posture? || assisted_patient_to_transfer? ||
        assisted_patient_to_move? || commuted_to_the_hospital? || assisted_patient_to_shop? ||
        assisted_patient_to_go_somewhere? || patient_destination_place.present?
    end

    def with_bed_assistance?
        new_record? ||
        assisted_patient_to_go_out_of_bed? || assisted_patient_to_go_to_bed?
    end
    
    def with_medical_care?
        #evaluate if any medical element has been checked
        new_record? ||
        assisted_to_take_medication || assisted_to_apply_a_cream || 
        assisted_to_take_eye_drops || assisted_to_extrude_mucus || 
        assisted_to_take_suppository || remarks_around_medication.present?
    end
    
    def with_handicap_care?
        #evaluate if any handicap element has been checked
        new_record? ||
        activities_done_with_the_patient != [''] || trained_patient_to_communicate || trained_patient_to_memorize || watch_after_patient_safety
    end

    def with_house_care?
        #evaluate if any house care element has been checked
        with_house_cleaning? || with_house_cooking? || with_shopping?
    end

    def with_house_cleaning?
        new_record? ||
        clean_up != [''] || took_out_trash? || washed_clothes? || dried_clothes? ||
        stored_clothes? || ironed_clothes? || changed_bed_sheets? || changed_bed_cover? ||
        rearranged_clothes? || repaired_clothes? || dried_the_futon?
    end

    def with_house_cooking?
        new_record? ||
        set_the_table? || cooked_for_the_patient? || cleaned_the_table? || 
        remarks_around_cooking.present?
    end

    def with_shopping?
        new_record? ||
        grocery_shopping? ||  medecine_shopping? || amount_received_for_shopping.present? ||
        amount_spent_for_shopping.present? || change_left_after_shopping? || shopping_items.present?
    end


end
