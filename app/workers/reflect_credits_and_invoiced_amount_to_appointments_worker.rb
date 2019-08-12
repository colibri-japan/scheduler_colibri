class ReflectCreditsAndInvoicedAmountToAppointmentsWorker
    include Sidekiq::Worker
    sidekiq_options retry: false

    def perform(service_id)
        service = Service.find(service_id)

        if service.present?
            service.appointments.update_all(total_credits: service.unit_credits, total_invoiced: service.invoiced_amount)
        end
    end

end