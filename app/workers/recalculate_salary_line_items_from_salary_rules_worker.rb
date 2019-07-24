class RecalculateSalaryLineItemsFromSalaryRulesWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(nurse_id, year, month)
    now_in_japan = Time.current + 9.hours
    start_of_month = DateTime.new(year.to_i, month.to_i, 1,0,0,0)
    end_of_month = start_of_month.end_of_month
    end_of_today = now_in_japan.month != month.to_i ? end_of_month : now_in_japan.end_of_day
    nurse = Nurse.find(nurse_id)
    corporation = nurse.corporation
    targeted_salary_rules = corporation.salary_rules.targeting_nurse(nurse_id.to_s).not_expired_at(now_in_japan)
    
    targeted_salary_rules.each do |salary_rule|
        
        targeted_titles = salary_rule.target_all_services ? corporation.services.where(nurse_id: nil).pluck(:title) : salary_rule.service_title_list
        targeted_appointments = nurse.appointments.operational.where(title: targeted_titles).in_range(start_of_month..end_of_today)

        case salary_rule.date_constraint
        when 1
            #holidays
            targeted_appointments = targeted_appointments.where('DATE(appointments.starts_at) IN (?)', HolidayJp.between(start_of_month, end_of_today).map(&:date))
        when 2
            #sunday
            targeted_appointments = targeted_appointments.where('EXTRACT(dow from appointments.starts_at) = 0')
        else
        end
        
        appointments_count = targeted_appointments.size 
        appointments_duration = targeted_appointments.sum(:duration)

        #substract previous career bonus
        case salary_rule.target_nurse_by_filter
        when 1
            previous_career_rule_id = corporation.salary_rules.where(target_nurse_by_filter: 0).first.try(:id)
            previous_career_bonus = nurse.salary_line_items.where(salary_rule_id: previous_career_rule_id).in_range(start_of_month..end_of_today).first
            appointments_count -= previous_career_bonus.service_counts  if previous_career_bonus.present?
            appointments_duration -= previous_career_bonus.service_duration if previous_career_bonus.present?
        when 2
            previous_career_rule_id = corporation.salary_rules.where(target_nurse_by_filter: 1).first.try(:id)
            previous_career_bonus = nurse.salary_line_items.where(salary_rule_id: previous_career_rule_id).in_range(start_of_month..end_of_today).first
            appointments_count -= previous_career_bonus.service_counts if previous_career_bonus.present?
            appointments_duration -= previous_career_bonus.service_duration if previous_career_bonus.present?
        else
        end

        #calculating total_wage
        if salary_rule.operator == 0
            if salary_rule.hour_based
                total_wage = (appointments_duration / 60) * (salary_rule.argument.to_f / 60) || 0
            else
                total_wage = appointments_count * salary_rule.argument.to_f || 0
            end
        elsif salary_rule.operator == 1
            total_wage = targeted_appointments.sum(:total_wage) * salary_rule.argument.to_f || 0
        else
            total_wage = 0
        end
        
        #creating/updating provided service
        salary_line_item_from_rule = salary_rule.salary_line_items.where(nurse_id: nurse_id, planning_id: corporation.planning.id, title: salary_rule.title, hour_based_wage: salary_rule.hour_based).in_range(start_of_month..end_of_month).first_or_create
        salary_line_item_from_rule.update_columns(service_counts: appointments_count, service_duration: appointments_duration, total_wage: total_wage, updated_at: Time.current, service_date: end_of_today.beginning_of_day)
    end
  end

end