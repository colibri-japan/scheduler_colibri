class CareManagerCorporation < ApplicationRecord

    belongs_to :corporation
    has_many :care_managers

    def teikyohyo_data(first_day, last_day)
        patients = Patient.where(care_manager_id: self.care_managers.ids).still_active_at(first_day.to_date)

        services_and_shifts_per_patient = {}

        patients.each do |patient|
            array_of_service_shifts_hashes = []

            array_of_services_hash = build_array_of_services_hash(patient, first_day..last_day)

            array_of_services_hash.each do |service_hash|
                shifts_by_service_hash = {}
                shifts_by_service_hash[:service_hash] = service_hash
                shifts_by_service_hash[:shifts_hash] = build_array_of_shifts(patient, service_hash[:title], first_day..last_day)                
                array_of_service_shifts_hashes << shifts_by_service_hash
            end
            services_and_shifts_per_patient[patient] = array_of_service_shifts_hashes
        end

        services_and_shifts_per_patient
    end

    private

    def build_array_of_services_hash(patient, date_range)
        array_of_services_hashes = []
        provided_services_titles = ProvidedService.where(patient: patient.id, archived_at: nil).from_appointments.includes(:appointment).where(appointments: {edit_requested: false}).in_range(date_range).pluck(:title).uniq

        provided_services_titles.each do |title|
            service_type = Service.where(nurse_id: nil, title: title, corporation_id: patient.corporation_id).first
            service_hash = {}
            if service_type.present? && service_type.official_title.present?
                provided_services = ProvidedService.where(patient: patient.id, archived_at: nil, cancelled: false, title: title).from_appointments.includes(:appointment).where(appointments: {edit_requested: false}).in_range(date_range)
                service_hash[:title] = title
                service_hash[:official_title] = service_type.official_title if service_type.present?
                service_hash[:service_code] = service_type.service_code if service_type.present?
                service_hash[:unit_credits] = service_type.unit_credits if service_type.present?
                service_hash[:sum_total_credits] = provided_services.sum(:total_credits)
                service_hash[:sum_invoiced_total] = provided_services.sum(:invoiced_total)
                service_hash[:count] = provided_services.count

                array_of_services_hashes << service_hash
            end
        end
        array_of_services_hashes
    end

    def build_array_of_shifts(patient, service_title, date_range)
        array_of_shifts = []

        shift_dates = ProvidedService.where(patient_id: patient.id, title: service_title).from_appointments.includes(:appointment).where(appointments: {edit_requested: false}).not_archived.in_range(date_range).pluck(:appointment_start, :appointment_end)

        shift_dates.map {|e| e[0] = e[0].strftime("%H:%M:%S")}
        shift_dates.map {|e| e[1] = e[1].strftime("%H:%M:%S")}
        shift_dates.uniq!


        shift_dates.each do |start_and_end|
            shift_hash = {}
            shift_hash[:start_time] = start_and_end[0]
            shift_hash[:end_time] = start_and_end[1]
            recurring_appointments = RecurringAppointment.from_master.where(patient_id: patient.id, title: service_title).where('starts_at::timestamp::time = ? AND ends_at::timestamp::time = ?', start_and_end[0], start_and_end[1]).not_terminated_at(date_range.first)
            shift_hash[:previsional] = recurring_appointments.map {|r| r.appointments(date_range.first, date_range.last).map(&:to_date) }.flatten
            shift_hash[:provided] = ProvidedService.from_appointments.includes(:appointment).where(appointments: {edit_requested: false}).where(title: service_title, patient_id: patient.id, cancelled: false, archived_at: nil).in_range(date_range).where('appointment_start::timestamp::time = ? AND appointment_end::timestamp::time = ?', start_and_end[0], start_and_end[1]).pluck(:appointment_start).map(&:to_date)
            array_of_shifts << shift_hash
        end

        array_of_shifts
    end

end
