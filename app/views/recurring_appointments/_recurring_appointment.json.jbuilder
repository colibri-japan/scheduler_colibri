appointments = recurring_appointment.appointments(params[:start], params[:end])

json.array! appointments do |appointment|
        json.allDay recurring_appointment.all_day_recurring_appointment?
        date_format = json.allDay ? '%Y-%m-%d' : '%Y-%m-%dT%H:%M'
        json.id "recurring_#{recurring_appointment.id}"
        json.extract! recurring_appointment, :color, :frequency, :patient_id, :nurse_id, :termination_date
        json.title "#{recurring_appointment.patient.try(:name)} - #{recurring_appointment.nurse.try(:name)}"
        json.start DateTime.new(appointment.year, appointment.month, appointment.day, recurring_appointment.starts_at.hour, recurring_appointment.starts_at.min).strftime(date_format)
        json.end (DateTime.new(appointment.year, appointment.month, appointment.day, recurring_appointment.ends_at.hour, recurring_appointment.ends_at.min) + recurring_appointment.duration.to_i).strftime(date_format)
        json.resourceId params[:patient_resource].present? ? recurring_appointment.patient_id : recurring_appointment.nurse_id
        json.private_event false
        json.service_type recurring_appointment.title
        json.description recurring_appointment.description ||= ''
        json.patient do  
            json.name recurring_appointment.patient.try(:name)
            json.address recurring_appointment.patient.try(:address) 
        end
        json.nurse do   
            json.name recurring_appointment.nurse.try(:name)
        end
        json.eventType 'recurring_appointment'

        json.base_url planning_recurring_appointment_path(@planning, recurring_appointment)
        json.update_url planning_recurring_appointment_path(@planning, recurring_appointment, method: :patch)
        json.edit_url edit_planning_recurring_appointment_path(@planning, recurring_appointment)
end