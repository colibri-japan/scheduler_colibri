class CancelAppointmentsWorker
    include Sidekiq::Worker
    sidekiq_options retry: false

    def perform(appointment_ids)
        puts 'cancelling appointments of ids:'
        puts appointment_ids
        Appointment.where(id: appointment_ids).update_all(cancelled: true, updated_at: Time.current)
        ProvidedService.where(appointment_id: appointment_ids).update_all(cancelled: true, updated_at: Time.current)
    end
end