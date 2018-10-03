json.allDay appointment.all_day_appointment?

date_format = json.allDay ? '%Y-%m-%d' : '%Y-%m-%dT%H:%M'

json.id "appointment_#{appointment.id}"
json.title "#{appointment.patient.try(:name)} - #{appointment.nurse.try(:name)}"
json.extract! appointment, :description, :start, :end, :color, :master, :displayable
json.resourceId appointment.nurse_id
json.patientId appointment.patient_id
json.nurse_name appointment.nurse.try(:name)
json.patient_name appointment.patient.try(:name)

json.editRequested appointment.edit_requested
json.borderColor '#F98050' if appointment.edit_requested == true

json.base_url planning_appointment_path(@planning, appointment)
json.edit_url edit_planning_appointment_path(@planning, appointment)
json.recurring_appointment_path "/plannings/#{@planning.id}/recurring_appointments/#{appointment.recurring_appointment_id}/edit" if appointment.recurring_appointment_id.present?
