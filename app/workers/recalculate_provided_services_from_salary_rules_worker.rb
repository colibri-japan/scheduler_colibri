class RecalculateProvidedServicesFromSalaryRulesWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(nurse_id, year, month)
    now_in_japan = Time.current + 9.hours
    start_of_month = DateTime.new(year.to_i, month.to_i, 1,0,0,0).beginning_of_month
    end_of_month = start_of_month.end_of_month
    end_of_today = now_in_japan.month != month.to_i ? end_of_month : now_in_japan.end_of_day
    corporation = Nurse.find(nurse_id).corporation
    targeted_salary_rules = SalaryRule.where(corporation_id: corporation.id).where('target_all_nurses IS TRUE OR (target_all_nurses IS FALSE AND ? = ANY(nurse_id_list))', nurse_id.to_s).not_expired_at(now_in_japan)
    
    targeted_salary_rules.each do |salary_rule|
        
        targeted_titles = salary_rule.target_all_services ? corporation.services.where(nurse_id: nil).pluck(:title) : salary_rule.service_title_list
        provided_service_from_rule = ProvidedService.where(nurse_id: nurse_id, salary_rule_id: salary_rule.id).in_range(start_of_month..end_of_month).first
        targeted_services = ProvidedService.includes(:appointment).where(nurse_id: nurse_id, salary_rule_id: nil, archived_at: nil, cancelled: false, title: targeted_titles).from_appointments.where(appointments: {edit_requested: false}).in_range(start_of_month..end_of_today)
        
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

        #substract previous career bonus
        case salary_rule.target_nurse_by_filter
        when 1
            previous_career_rule = SalaryRule.where(corporation_id: corporation.id, target_nurse_by_filter: 0).first
            previous_career_bonus = ProvidedService.where(nurse_id: nurse_id, salary_rule_id: previous_career_rule.id).in_range(start_of_month..end_of_today).first
            service_counts -= previous_career_bonus.service_counts  unless previous_career_bonus.nil?
            service_duration -= previous_career_bonus.service_duration unless previous_career_bonus.nil?
        when 2
            previous_career_rule = SalaryRule.where(corporation_id: corporation.id, target_nurse_by_filter: 1).first
            previous_career_bonus = ProvidedService.where(nurse_id: nurse_id, salary_rule_id: previous_career_rule.id).in_range(start_of_month..end_of_today).first
            service_counts -= previous_career_bonus.service_counts unless previous_career_bonus.nil?
            service_duration -= previous_career_bonus.service_duration unless previous_career_bonus.nil?
        else
        end

        #calculating total_wage
        if salary_rule.operator == 0
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
        
        #creating/updating provided service
        if provided_service_from_rule.present? 
            provided_service_from_rule.update_columns(service_counts: service_counts, service_duration: service_duration, total_wage: total_wage, updated_at: Time.current, service_date: end_of_today.beginning_of_day)
        else
            ProvidedService.create(nurse_id: nurse_id, planning_id: corporation.planning.id, salary_rule_id: salary_rule.id, service_date: end_of_today.beginning_of_day, title: salary_rule.title, hour_based_wage: salary_rule.hour_based, total_wage: total_wage, service_duration: service_duration, service_counts: service_counts, skip_callbacks_except_calculate_total_wage: true, skip_wage_credits_and_invoice_calculations: true)
        end
    end
  end

end