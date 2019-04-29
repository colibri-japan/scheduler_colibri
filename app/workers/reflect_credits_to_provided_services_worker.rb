class ReflectCreditsToProvidedServicesWorker
    include Sidekiq::Worker
    sidekiq_options retry: false

    def perform(service_id)
        service = Service.find(service_id)
        corporation = service.corporation 

        if corporation.teams.any?
            corporation.teams.each do |team|
                team_nurses_ids = team.nurses.ids
                total_to_invoice = (team.credits_to_jpy_ratio || corporation.credits_to_jpy_ratio || 0) * service.unit_credits
                ProvidedService.where(title: service.title, planning_id: corporation.planning.id, archived_at: nil, nurse_id: team_nurses_ids).update_all(total_credits: service.unit_credits, invoiced_total: total_to_invoice, updated_at: Time.current)
            end
        else
            total_to_invoice = (corporation.credits_to_jpy_ratio || 0) * service.unit_credits
            ProvidedService.where(title: service.title, planning_id: corporation.planning.id, archived_at: nil).update_all(total_credits: service.unit_credits, invoiced_total: total_to_invoice, updated_at: Time.current)
        end

    end

end