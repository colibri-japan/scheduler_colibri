class RecalculateProvidedServicesFromSalaryRulesWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(updated_provided_service_id)
    now_in_japan = Time.current + 9.hours
    updated_provided_service = ProvidedService.find(updated_provided_service_id)
    start_of_month = updated_provided_service.service_date.beginning_of_month
    end_of_month = start_of_month.end_of_month
    end_of_today = now_in_japan.end_of_day > end_of_month ? end_of_month : now_in_japan.end_of_day
    corporation = updated_provided_service.planning.corporation
    targeted_salary_rules = SalaryRule.where(corporation_id: corporation.id).where('target_all_nurses IS TRUE OR (target_all_nurses IS FALSE AND ? = ANY(nurse_id_list))', updated_provided_service.nurse_id.to_s).not_expired_at(now_in_japan)
    
    
    targeted_salary_rules.each do |salary_rule|
        targeted_titles = salary_rule.target_all_services ? corporation.services.where(nurse_id: nil).pluck(:title) : salary_rule.service_title_list
        provided_service_from_rule = ProvidedService.where(nurse_id: updated_provided_service.nurse_id, salary_rule_id: salary_rule.id).in_range(start_of_month..end_of_month)
        targeted_services = ProvidedService.includes(:appointment).where(nurse_id: updated_provided_service.nurse_id, salary_rule_id: nil, archived_at: nil, cancelled: false, title: targeted_titles).from_appointments.where(appointments: {edit_requested: false}).in_range(start_of_month..end_of_today)
        
        case salary_rule.date_constraint
        when 1
            #holidays
            targeted_services = targeted_services.where('DATE(provided_services.service_date) IN (?)', HolidayJp.between(start_of_month, end_of_today).map(&:date))
        when 2
            #sunday
            targeted_services = targeted_services.where('EXTRACT(dow from provided_services.service_date) = 0')
        else
        end
        
        service_counts = targeted_services.count 
        service_duration = targeted_services.sum(:service_duration)

        if salary_rule.operator == 0
            #addition
            if salary_rule.hour_based
                total_wage = (service_duration / 60) * (salary_rule.argument.to_f / 60) || 0
            else
                total_wage = service_counts * salary_rule.argument.to_f || 0
            end
        elsif salary_rule.operator == 1
            total_wage = targeted_services.sum(:total_wage) * salary_rule.argument.to_f || 0
        else
            total_wage = 0
        end
        
        if provided_service_from_rule.present? 
            puts 'updating existing service'
            provided_service_from_rule.first.update_columns(service_counts: service_counts, service_duration: service_duration, total_wage: total_wage)
        else
            puts 'creating new service'
            ProvidedService.create(nurse_id: updated_provided_service.nurse_id, planning_id: corporation.planning.id, salary_rule_id: salary_rule.id, service_date: end_of_today.beginning_of_day, title: salary_rule.title, hour_based_wage: salary_rule.hour_based, total_wage: total_wage, service_duration: service_duration, service_counts: service_counts, skip_callbacks_except_calculate_total_wage: true, skip_wage_credits_and_invoice_calculations: true)
        end
    end
  end

end