class ReflectWageToAppointmentsWorker
    include Sidekiq::Worker
    sidekiq_options retry: false

    def perform(service_id)
        service = Service.find(service_id)

        #will need to take weekend holidays into account

        if service.present?
            weekend_holiday_appointment_ids = service.appointments.operational.select{|a| a.weekend_holiday_salary_line_item? }.map &:id
            weekday_appointment_ids = [service.appointments.operational.pluck(:id) - weekend_holiday_appointment_ids]
            if service.hour_based_wage?
                Appointment.where(id: weekend_holiday_appointment_ids).pluck(:id, :duration).group_by {|id_and_duration| id_and_duration[1]}.each do |duration, arrays_of_id_and_duration|
                    total_wage = (duration.to_f / 3600) * (service.weekend_unit_wage || service.unit_wage || 0) 
                    Appointment.where(id: arrays_of_id_and_duration.map {|e| e[0]}).update_all(total_wage: total_wage)
                end
                Appointment.where(id: weekday_appointment_ids).pluck(:id, :duration).group_by {|id_and_duration| id_and_duration[1]}.each do |duration, arrays_of_id_and_duration|
                    total_wage = (duration.to_f / 3600) * (service.unit_wage || 0) 
                    Appointment.where(id: arrays_of_id_and_duration.map {|e| e[0]}).update_all(total_wage: total_wage)
                end
            else
                Appointment.where(id: weekend_holiday_appointment_ids).update_all(total_wage: (service.weekend_unit_wage || service.unit_wage || 0 ))
                Appointment.where(id: weekday_appointment_ids).update_all(total_wage: (service.unit_wage || 0))
            end
        end
    end

end