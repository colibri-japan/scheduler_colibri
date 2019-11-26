class RecalculateSalaryLineItemsFromSalaryRulesWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(nurse_id, year, month)
    now_in_japan = Time.current + 9.hours
    @start_of_month = DateTime.new(year.to_i, month.to_i, 1,0,0,0)
    @end_of_month = @start_of_month.end_of_month
    @end_of_today = now_in_japan.month != month.to_i ? @end_of_month : now_in_japan.end_of_day
    @nurse = Nurse.find(nurse_id)
    corporation = @nurse.corporation
    targeted_salary_rules = corporation.salary_rules.targeting_nurse(nurse_id.to_s).not_expired_at(now_in_japan)
    
    #delete existing salary line items for cleaner calculation
    @nurse.salary_line_items.from_salary_rules.in_range(@start_of_month..@end_of_month).delete_all

    #calculate salary line items
    targeted_salary_rules.each do |salary_rule|
        next if skip_because_of_worked_days_constraint(salary_rule)
        next if skip_because_of_worked_duration_constraint(salary_rule)
        
        targeted_titles = salary_rule.target_all_services ? corporation.services.where(nurse_id: nil).pluck(:title) : salary_rule.service_title_list
        targeted_appointments = @nurse.appointments.operational.where(title: targeted_titles).in_range(@start_of_month..@end_of_today)

        # here specify the targeted appointments from min max days worked rule
        targeted_appointments = targeted_appointments.where('starts_at >= ?', @nurse.date_from_work_day_number(salary_rule.min_days_worked, inside_insurance_scope: salary_rule.only_count_days_inside_insurance_scope).beginning_of_day) if salary_rule.min_days_worked.present?
        targeted_appointments = targeted_appointments.where('starts_at <= ?', @nurse.date_from_work_day_number(salary_rule.max_days_worked, inside_insurance_scope: salary_rule.only_count_days_inside_insurance_scope).end_of_day) if salary_rule.max_days_worked.present?
        
        #targeting appointments from min max worked months
        targeted_appointments = targeted_appointments.where('starts_at >= ?', @nurse.date_from_worked_months(salary_rule.min_months_worked)) if salary_rule.min_months_worked.present?
        targeted_appointments = targeted_appointments.where('starts_at <= ?', @nurse.date_from_worked_months(salary_rule.max_months_worked)) if salary_rule.max_months_worked.present?


        case salary_rule.date_constraint
        when 1
            #holidays
            targeted_appointments = targeted_appointments.where('DATE(appointments.starts_at) IN (?)', HolidayJp.between(@start_of_month, @end_of_today).map(&:date))
        when 2
            #sunday
            targeted_appointments = targeted_appointments.where('EXTRACT(dow from appointments.starts_at) = 0')
        else
        end
        
        appointments_count = targeted_appointments.size 
        appointments_duration = targeted_appointments.sum(:duration)

        #verify if met goals
        met_goals = true 

        if salary_rule.min_monthly_service_count.present? && (!salary_rule.max_monthly_service_count.present?)
          met_goals = appointments_count >= salary_rule.min_monthly_service_count
          appointments_count = appointments_count >= salary_rule.min_monthly_service_count ? (appointments_count - salary_rule.min_monthly_service_count) : 0
        elsif salary_rule.max_monthly_service_count.present? && (!salary_rule.min_monthly_service_count.present?)
          met_goals = appointments_count <= salary_rule.max_monthly_service_count
          appointments_count = appointments_count <= salary_rule.max_monthly_service_count ? appointments_count : salary_rule.max_monthly_service_count
        elsif salary_rule.min_monthly_service_count.present? && salary_rule.max_monthly_service_count.present? 
          met_goals = (appointments_count >= salary_rule.min_monthly_service_count) && (appointments_count <= salary_rule.max_monthly_service_count)
          if appointments_count <= salary_rule.min_monthly_service_count
            appointments_count = salary_rule.min_monthly_service_count
          elsif appointments_count >= salary_rule.max_monthly_service_count
            appointments_count = salary_rule.max_monthly_service_count
          else
            appointments_count -= salary_rule.min_monthly_service_count
          end
        end
        
        #filtering duration from goals
        if salary_rule.min_monthly_hours_worked.present? && (!salary_rule.max_monthly_hours_worked.present?)
          met_goals = appointments_duration >= (salary_rule.min_monthly_hours_worked * 3600)
          appointments_duration = appointments_duration >= (salary_rule.min_monthly_hours_worked * 3600) ? (appointments_duration - (salary_rule.min_monthly_hours_worked * 3600)) : 0
        elsif salary_rule.max_monthly_hours_worked.present? && (!salary_rule.min_monthly_hours_worked.present?)
          met_goals = appointments_duration < (salary_rule.max_monthly_hours_worked * 3600)
          appointments_duration = appointments_duration <= (salary_rule.max_monthly_hours_worked * 3600) ? appointments_duration : salary_rule.max_monthly_hours_worked * 3600
        elsif salary_rule.min_monthly_hours_worked.present? && salary_rule.max_monthly_hours_worked.present? 
          met_goals = (appointments_duration >= (salary_rule.min_monthly_hours_worked * 3600)) && (appointments_duration < (salary_rule.max_monthly_hours_worked * 3600))
          if appointments_duration <= (salary_rule.min_monthly_hours_worked * 3600)
            appointments_duration = salary_rule.min_monthly_hours_worked * 3600
          elsif appointments_duration >= (salary_rule.max_monthly_hours_worked * 3600)
            appointments_duration = salary_rule.max_monthly_hours_worked * 3600
          end
        end

        # substract number of days worked from appointments count if only_count_between_appointments
        if salary_rule.only_count_between_appointments?
          day_count = targeted_appointments.present? ? targeted_appointments.pluck(:starts_at).map(&:to_date).uniq.size : 0
          appointments_count -= day_count
        end

        #calculate total wage in function of operator
        case salary_rule.operator
        when 0
            #add arg per count
            total_wage = (appointments_count || 0) * (salary_rule.argument.to_f || 0) 
        when 1
            #add arg per hour
            total_wage = (appointments_duration || 0) * (salary_rule.argument.to_f || 0) / 3600
        when 2 
            #multiply salary by arg
            total_wage = (targeted_appointments.sum(:total_wage) || 0 ) * (salary_rule.argument.to_f || 0)
        when 3
            #add arg only once if goals are met
            total_wage = met_goals ? (salary_rule.argument || 0) : 0
        else
            total_wage = 0
        end
        
        #creating/updating provided service
        if met_goals
          salary_line_item_from_rule = salary_rule.salary_line_items.where(nurse_id: nurse_id, planning_id: corporation.planning.id, title: salary_rule.title, hour_based_wage: salary_rule.calculate_from_hours?).in_range(@start_of_month..@end_of_month).first_or_create
          salary_line_item_from_rule.update_columns(service_counts: appointments_count, service_duration: appointments_duration, total_wage: total_wage, updated_at: Time.current, service_date: @end_of_today.beginning_of_day)
        end
    end
  end

  private 

  def skip_because_of_worked_days_constraint(salary_rule)
    if salary_rule.min_days_worked.present? && salary_rule.max_days_worked.present? 
        days_worked_at_end_inferior_to_min_required(salary_rule) || days_worked_at_start_greater_than_max_allowed(salary_rule)
    elsif salary_rule.min_days_worked.present? 
        days_worked_at_end_inferior_to_min_required(salary_rule)
    elsif salary_rule.max_days_worked.present?
        days_worked_at_start_greater_than_max_allowed(salary_rule)
    else
        false
    end
  end

  def days_worked_at_end_inferior_to_min_required(salary_rule)
    days_worked_at_end_of_range = @nurse.days_worked_at(@end_of_today, inside_insurance_scope: salary_rule.only_count_days_inside_insurance_scope)
    days_worked_at_end_of_range.present? ? days_worked_at_end_of_range < salary_rule.min_days_worked : false
  end

  def days_worked_at_start_greater_than_max_allowed(salary_rule)
    days_worked_at_start_of_range = @nurse.days_worked_at(@start_of_month, inside_insurance_scope: salary_rule.only_count_days_inside_insurance_scope)
    days_worked_at_start_of_range.present? ? days_worked_at_start_of_range > salary_rule.max_days_worked : false
  end

  def skip_because_of_worked_duration_constraint(salary_rule)
    if salary_rule.min_months_worked.present? && salary_rule.max_months_worked.present? 
        bonus_end_date_inferior_to_range_start(salary_rule.max_months_worked) || bonus_start_date_greater_than_range_end(salary_rule.min_months_worked)
    elsif salary_rule.min_months_worked.present? 
        bonus_start_date_greater_than_range_end(salary_rule.min_months_worked)
    elsif salary_rule.max_months_worked.present? 
        bonus_end_date_inferior_to_range_start((salary_rule.max_months_worked))
    else 
        false
    end
  end

  def bonus_start_date_greater_than_range_end(min_months)
    bonus_start_date = @nurse.date_from_worked_months(min_months)
    bonus_start_date.present? ? bonus_start_date > @end_of_today.to_date : false
  end

  def bonus_end_date_inferior_to_range_start(max_months)
    bonus_end_date = @nurse.date_from_worked_months(max_months)
    bonus_end_date.present? ? bonus_end_date < @start_of_month.to_date : false
  end

end