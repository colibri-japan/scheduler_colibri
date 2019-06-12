class CancelAppointmentsWorker
    include Sidekiq::Worker
    sidekiq_options retry: false

    def perform(appointment_ids)
        puts 'cancelling appointments of ids:'
        puts appointment_ids
        Appointment.where(id: appointment_ids).update_all(cancelled: true, updated_at: Time.current)
        ProvidedService.where(appointment_id: appointment_ids).update_all(cancelled: true, total_wage: 0, total_credits: 0, invoiced_total: 0, updated_at: Time.current)
    end
end