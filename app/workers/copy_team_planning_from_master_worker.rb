class CopyTeamPlanningFromMasterWorker
	include Sidekiq::Worker
	sidekiq_options retry: false

  def perform(team_id, month, year)
    team = Team.find(team_id)
    corporation = team.corporation 
    planning = corporation.planning

    nurse_ids = team.nurses.ids
    
    first_day = DateTime.new(year.to_i, month.to_i, 1, 0, 0, 0)
    last_day = DateTime.new(year.to_i, month.to_i, -1, 23, 59, 59)

    new_appointments = []

    planning.recurring_appointments.not_archived.not_terminated_at(first_day).where(nurse_id: nurse_ids).find_each do |recurring_appointment|
      occurrences = recurring_appointment.appointments(first_day, last_day)

      occurrences.each do |occurrence|
        new_appointment = Appointment.new(
          starts_at: DateTime.new(occurrence.year, occurrence.month, occurrence.day, recurring_appointment.starts_at.hour, recurring_appointment.starts_at.min),
          ends_at: DateTime.new(occurrence.year, occurrence.month, occurrence.day, recurring_appointment.ends_at.hour, recurring_appointment.ends_at.min) + recurring_appointment.duration.to_i,
          title: recurring_appointment.title,
          color: recurring_appointment.color, 
          nurse_id: recurring_appointment.nurse_id, 
          patient_id: recurring_appointment.patient_id,
          description: recurring_appointment.description,
          planning_id: recurring_appointment.planning_id,
          recurring_appointment_id: recurring_appointment.id,
          original_recurring_appointment_id: recurring_appointment.id,
          service_id: recurring_appointment.service_id,
          should_request_edit_for_overlapping_appointments: true
        )
        new_appointment.run_callbacks(:save) { false }
        new_appointments << new_appointment
      end
    end

    Appointment.import(new_appointments)

  end
end
