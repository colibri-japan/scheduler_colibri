class CompletionReport < ApplicationRecord
    belongs_to :reportable, polymorphic: true
    belongs_to :forecasted_report, class_name: 'CompletionReport', optional: true 
    has_many :achieved_reports, class_name: 'CompletionReport', foreign_key: :forecasted_report_id

    scope :from_appointments, -> { where(reportable_type: 'Appointment') }
    scope :from_recurring_appointments, -> { where(reportable_type: 'RecurringAppointment') }
    scope :with_general_comment, -> { where.not(general_comment: [nil, '']) }

    def self.from_nurse(nurse_id)
        joins('INNER JOIN appointments on appointments.id = completion_reports.reportable_id').where(appointments: {nurse_id: nurse_id})
    end

    def self.from_patient(patient_id)
        joins('INNER JOIN appointments on appointments.id = completion_reports.reportable_id').where(appointments: {patient_id: patient_id})
    end

    def self.attributed_to_ignore_when_comparing
        [:id, :created_at, :updated_at, :forecasted_report_id, :reportable_type, :reportable_id, :general_comment, :patient_looked_good, :patient_transpired, :body_temperature, :blood_pressure_systolic, :blood_pressure_diastolic, :house_was_clean, :patient_could_discuss, :patient_could_gather_and_share_information, :checking_report, :checked_gas_when_leaving, :checked_electricity_when_leaving, :checked_water_when_leaving, :checked_door_when_leaving]
    end

    def identical?(other_report)
        return true if other_report.nil?
        self.attributes.except(*self.class.attributed_to_ignore_when_comparing.map(&:to_s)) ==
        other_report.attributes.except(*self.class.attributed_to_ignore_when_comparing.map(&:to_s))
    end

    def attributes_differences_with(forecast)
        forecasted = forecast.attributes.except(*self.class.attributed_to_ignore_when_comparing.map(&:to_s)).to_a
        actual = self.attributes.except(*self.class.attributed_to_ignore_when_comparing.map(&:to_s)).to_a
        (forecasted - actual).map {|k,v| k}.uniq
    end

    def difference_between_actual_and_forecasted(forecast)
        keys = attributes_differences_with(forecast)
        difference_hash = {}
        keys.each do |key|
            difference_hash[key] = {forecasted: forecast.attributes[key], actual: self.attributes[key]}
        end
        difference_hash
    end

    def with_anything_checked?
        with_personal_care? || with_handicap_care? || with_medical_care? ||  with_house_care?
    end

    def with_personal_care?
        with_bathroom_assistance? || with_feeding? || with_body_cleaning? ||
        with_grooming? || with_movement_assistance? || with_bed_assistance?
    end

    def with_bathroom_assistance?
        batch_assisted_bathroom? || assisted_bathroom? || assisted_portable_bathroom? ||  changed_diapers? ||
        changed_bed_pad? || changed_stained_clothes? || wiped_patient? || patient_urinated? ||
        urination_count.present? || amount_of_urine.present? || patient_defecated? ||
        defecation_count.present? || visual_aspect_of_feces.present? 
    end

    def with_feeding?
        batch_assisted_meal? || patient_maintains_good_posture_while_eating? || explained_menu_to_patient? ||
        assisted_patient_to_eat? || patient_ate_full_plate.present? || ratio_of_leftovers.present? || 
        patient_hydrated? || amount_of_liquid_drank.present? || meal_specificities.present?
    end

    def with_grooming?
        full_or_partial_body_wash? || hands_and_feet_wash? || hair_wash?
    end

    def with_body_cleaning?
        bath_or_shower? || face_wash? ||  mouth_wash? || 
        (washing_details != [''] && washing_details != []) || 
        changed_clothes? 
    end

    def with_movement_assistance?
        assisted_patient_to_change_body_posture? || assisted_patient_to_transfer? ||
        assisted_patient_to_move? || commuted_to_the_hospital? || assisted_patient_to_shop? ||
        assisted_patient_to_go_somewhere? || patient_destination_place.present?
    end

    def with_bed_assistance?
        assisted_patient_to_go_out_of_bed? || assisted_patient_to_go_to_bed?
    end
    
    def with_medical_care?
        assisted_to_take_medication || assisted_to_apply_a_cream || 
        assisted_to_take_eye_drops || assisted_to_extrude_mucus || 
        assisted_to_take_suppository || remarks_around_medication.present?
    end
    
    def with_handicap_care?
        (activities_done_with_the_patient != [''] && activities_done_with_the_patient != []) || 
        trained_patient_to_communicate? || 
        trained_patient_to_memorize? || watch_after_patient_safety? || (watched_after_patient_safety_doing != [''] && watched_after_patient_safety_doing != [])
    end

    def with_house_care?
        batch_assisted_house_cleaning? || with_house_cleaning? || with_laundry? || with_bed_make? || with_clothes_arranging? ||
         with_house_cooking? || with_shopping?
    end

    def with_house_cleaning?
        (clean_up != [] && clean_up != ['']) || took_out_trash? 
    end

    def with_laundry?
        batch_assisted_laundry? || washed_clothes? || dried_clothes? || stored_clothes? || ironed_clothes?
    end

    def with_bed_make?
        batch_assisted_bedmake? || changed_bed_sheets? || changed_bed_cover? 
    end

    def with_clothes_arranging?
        batch_assisted_storing_furniture? || rearranged_clothes? || repaired_clothes? || dried_the_futon?
    end

    def with_house_cooking?
        batch_assisted_cooking? || set_the_table? || cooked_for_the_patient? || cleaned_the_table? || 
        remarks_around_cooking.present?
    end

    def with_shopping?
        batch_assisted_groceries? || grocery_shopping? ||  medecine_shopping? || amount_received_for_shopping.present? ||
        amount_spent_for_shopping.present? || change_left_after_shopping? || shopping_items.present?
    end


end
