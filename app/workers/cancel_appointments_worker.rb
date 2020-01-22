class CancelAppointmentsWorker
    include Sidekiq::Worker
    sidekiq_options retry: false

    def perform(appointment_ids)
        Appointment.where(id: appointment_ids).update_all(cancelled: true, total_wage: 0, total_credits: 0, invoiced_total: 0, updated_at: Time.current)

        years_months_and_nurses = Appointment.where(id: appointment_ids).pluck(:nurse_id, :starts_at).map {|nurse_id, starts_at| [nurse_id, starts_at.year, starts_at.month] }.uniq

        years_months_and_nurses.each do |year_month_and_nurse|
            RecalculateSalaryLineItemsFromSalaryRulesWorker.perform_async(year_month_and_nurse[0], year_month_and_nurse[1], year_month_and_nurse[2])
        end
    end
end