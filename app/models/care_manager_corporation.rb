class CareManagerCorporation < ApplicationRecord

    belongs_to :corporation
    has_many :care_managers

    def teikyohyo_data(first_day, last_day)
        patients = Patient.where(care_manager_id: self.care_managers.ids).still_active_at(first_day.to_date)
        event_and_services_by_patient = {}

        patients.each do |patient|
            events_array = ProvidedService.where(patient_id: patient.id).not_archived.from_appointments.includes(:appointment).where(appointments: {edit_requested: false}).in_range(first_day..last_day).order(:title).pluck(:title, :appointment_start, :appointment_end)
            formatted_events_array = extract_start_and_end_time(events_array)
            event_hash = format_to_hash(formatted_events_array)

            event_and_services_by_patient[patient] = get_previsional_and_provided_dates_for(event_hash, patient, first_day..last_day)
        end

        event_and_services_by_patient
    end

    private

    def extract_start_and_end_time(events_array)
        events_array.map {|e| e[1] = e[1].strftime('%H:%M:%S')}
        events_array.map {|e| e[2] = e[2].strftime('%H:%M:%S')}
        events_array.uniq!
        events_array = keep_only_formatted_kaigo_insured_services(events_array)
    end

    def keep_only_formatted_kaigo_insured_services(events_array)
        formatted_array = []
        events_array.each do |service_array|
            original_service = Service.where(nurse_id: nil, title: service_array[0]).first 
            if original_service.unit_credits.present?
                formatted_array << [service_array[0], original_service.official_title || '', original_service.service_code || '', original_service.unit_credits || 0, service_array[1], service_array[2]]
            end
        end
        puts formatted_array
        formatted_array
    end

    def format_to_hash(formatted_events_array)
        keys = [:title, :official_title, :service_code, :unit_credits, :start_time, :end_time]
        array = formatted_events_array.map {|service_array| service_array.map {|el| [keys[service_array.index(el)], el]} }
        formatted_hash = array.map(&:to_h)
    end

    def get_previsional_and_provided_dates_for(array_of_hashes, patient, date_range)
        previsional_and_provided_by_services = {}

        array_of_hashes.each do |event_hash|
            recurring_appointments = RecurringAppointment.from_master.where(patient_id: patient.id, title: event_hash[:title]).where('starts_at::timestamp::time = ? AND ends_at::timestamp::time = ?', event_hash[:start_time], event_hash[:end_time]).not_terminated_at(date_range.first)
            
            event_hash[:previsional] = recurring_appointments.map {|r| r.appointments(date_range.first, date_range.last).map(&:to_date)}.flatten
            event_hash[:provided] = ProvidedService.from_appointments.includes(:appointment).where(appointments: {edit_requested: false}).where(title: event_hash[:title], patient_id: patient.id, cancelled: false, archived_at: nil).in_range(date_range).where('appointment_start::timestamp::time = ? AND appointment_end::timestamp::time = ?', event_hash[:start_time], event_hash[:end_time]).pluck(:appointment_start).map(&:to_date)

            event_hash[:provided_sum_credits] = ProvidedService.from_appointments.includes(:appointment).where(appointments: {edit_requested: false}).where(title: event_hash[:title], patient_id: patient.id, cancelled: false, archived_at: nil).in_range(date_range).where('appointment_start::timestamp::time = ? AND appointment_end::timestamp::time = ?', event_hash[:start_time], event_hash[:end_time]).sum(:total_credits)
        end

        array_of_hashes
    end

end
