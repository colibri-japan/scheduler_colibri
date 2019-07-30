class ReflectCreditsToAppointmentsWorker
    include Sidekiq::Worker
    sidekiq_options retry: false

    def perform(service_id)
        service = Service.find(service_id)
        corporation = service.corporation 

        if corporation.teams.any?
            corporation.teams.each do |team|
                team_nurses_ids = team.nurses.ids
                case service.insurance_category_1
                when 0
                    total_to_invoice = (team.credits_to_jpy_ratio || corporation.credits_to_jpy_ratio || 0) * (service.unit_credits || 0)
                when 1
                    total_to_invoice = service.invoiced_amount
                else
                    total_to_invoice = 0
                end
                SalaryLineItem.where(title: service.title, planning_id: corporation.planning.id, archived_at: nil, nurse_id: team_nurses_ids, cancelled: false).update_all(total_credits: service.unit_credits, invoiced_total: total_to_invoice, updated_at: Time.current)
            end
        else
            case service.insurance_category_1
            when 0
                total_to_invoice = (corporation.credits_to_jpy_ratio || 0) * (service.unit_credits || 0)
            when 1
                total_to_invoice = service.invoiced_amount
            else
                total_to_invoice = 0
            end
            SalaryLineItem.where(title: service.title, planning_id: corporation.planning.id, archived_at: nil, cancelled: false).update_all(total_credits: service.unit_credits, invoiced_total: total_to_invoice, updated_at: Time.current)
        end

    end

end