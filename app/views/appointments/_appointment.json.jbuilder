json.allDay appointment.all_day_appointment?

date_format = json.allDay ? '%Y-%m-%d' : '%Y-%m-%dT%H:%M'

json.id "appointment_#{appointment.id}"
json.title "#{appointment.patient.try(:name)} - #{appointment.nurse.try(:name)}"
json.extract! appointment, :color, :master, :displayable, :nurse_id, :patient_id, :edit_requested
json.start appointment.starts_at
json.end appointment.ends_at
json.description appointment.description ? appointment.description : ''
json.resourceId appointment.nurse_id
json.nurse_name appointment.nurse.try(:name)
json.patient_name appointment.patient.try(:name)
json.service_type appointment.title ? appointment.title : ''

json.unavailability false

json.frequency appointment.recurring_appointment.frequency if appointment.recurring_appointment_id.present?

json.borderColor '#FFBBA0' if appointment.edit_requested == true

json.base_url planning_appointment_path(@planning, appointment)
json.edit_url edit_planning_appointment_path(@planning, appointment)
json.recurring_appointment_path "/plannings/#{@planning.id}/recurring_appointments/#{appointment.recurring_appointment_id}/edit" if appointment.recurring_appointment_id.present?
