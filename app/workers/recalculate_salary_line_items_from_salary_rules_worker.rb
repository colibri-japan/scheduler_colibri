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
        targeted_appointments = salary_rule.include_appointments_as_second_nurse ? Appointment.with_nurse_or_second_nurse_by_id(nurse_id).operational.where(title: targeted_titles).in_range(@start_of_month..@end_of_today) : @nurse.appointments.operational.where(title: targeted_titles).in_range(@start_of_month..@end_of_today)

        # here specify the targeted appointments from min max days worked rule
        targeted_appointments = targeted_appointments.where('starts_at >= ?', @nurse.date_from_work_day_number(salary_rule.min_days_worked, inside_insurance_scope: salary_rule.only_count_days_inside_insurance_scope).beginning_of_day) if salary_rule.min_days_worked.present?
        targeted_appointments = targeted_appointments.where('starts_at <= ?', @nurse.date_from_work_day_number(salary_rule.max_days_worked, inside_insurance_scope: salary_rule.only_count_days_inside_insurance_scope).end_of_day) if salary_rule.max_days_worked.present?
        
        #targeting appointments from min max worked months
        targeted_appointments = targeted_appointments.where('starts_at >= ?', @nurse.date_from_worked_months(salary_rule.min_months_worked)) if salary_rule.min_months_worked.present?
        targeted_appointments = targeted_appointments.where('starts_at <= ?', @nurse.date_from_worked_months(salary_rule.max_months_worked)) if salary_rule.max_months_worked.present?


        appointments_count = targeted_appointments.size 
        appointments_duration = targeted_appointments.sum(:duration)


        #filter appointments with date constraints
        if salary_rule.holiday_operator == 2
          #only holidays
          targeted_appointments = targeted_appointments.where('DATE(appointments.starts_at) IN (?)', HolidayJp.between(@start_of_month, @end_of_today).map(&:date))

          appointments_count = targeted_appointments.size 
          appointments_duration = targeted_appointments.sum(:duration)
        else
          if salary_rule.holiday_operator == 0
            #no specific holiday filter
          elsif salary_rule.holiday_operator == 1
            #exclude holidays
            targeted_appointments = targeted_appointments.where('DATE(appointments.starts_at) NOT IN (?)', HolidayJp.between(@start_of_month, @end_of_today).map(&:date))
          end

          if salary_rule.targeted_wdays.present? && salary_rule.targeted_wdays != ['']
            #exclude holidays and target by wdays
            wdays = (salary_rule.targeted_wdays - ['']).map &:to_i
            targeted_appointments = targeted_appointments.where('EXTRACT(dow from appointments.starts_at) IN (?)', wdays)
            
            appointments_count = targeted_appointments.size 
            appointments_duration = targeted_appointments.sum(:duration)
          end
          
          if salary_rule.targeted_start_time.present? || salary_rule.targeted_end_time.present?
            #convert everything to the same date, and just compare times to see if the constraints are met
            time_range_start = "2020-01-01 #{salary_rule.targeted_start_time || '00:00'}".to_datetime
            time_range_end = "2020-01-01 #{salary_rule.targeted_end_time || '23:59'}".to_datetime

            targeted_appointments_array = targeted_appointments.pluck :starts_at, :ends_at, :duration
            targeted_appointments_by_time = targeted_appointments_array.map {|data| [data[0].change(day: 1, month: 1, year: 2020), data[1].change(day: 1, month: 1, year: 2020), data[3]]}

            filtered_appointments = []
            case salary_rule.time_constraint_operator
            when 1
              #starts_at within constraints
              filtered_appointments = targeted_appointments_by_time.filter {|data| data[0] >=time_range_start && data[0] < time_range_end }
            when 2
              #ends_at or starts_at within constraints
              filtered_appointments = targeted_appointments_by_time.filter {|data| data[1] > time_range_start && data[0] < time_range_end }
            when 3
              #starts_at and ends_at both within constraints
              filtered_appointments = targeted_appointments_by_time.filter {|data| data[0] >=time_range_start && data[0] < time_range_end && data[1] >time_range_start && data[1] <= time_range_end }
            else
              filtered_appointments = targeted_appointments_by_time
            end

            appointments_count = filtered_appointments.size 
            appointments_duration = filtered_appointments.sum {|data| data[3] || 0}
          end
        end

        #verify if met goals
        met_goals = true 

        #verify monthly days worked goal
        days_worked = @nurse.days_worked_in_range(@start_of_month..@end_of_today) 
        if salary_rule.min_monthly_days_worked.present? && !salary_rule.max_monthly_days_worked.present?
          met_goals = days_worked >= salary_rule.min_monthly_days_worked
        elsif salary_rule.max_monthly_days_worked.present? && !salary_rule.min_monthly_days_worked.present? 
          met_goals = days_worked <= salary_rule.max_monthly_days_worked
        elsif salary_rule.min_monthly_days_worked.present? && salary_rule.max_monthly_days_worked.present?
          met_goals = (days_worked >= salary_rule.min_monthly_days_worked) && (days_worked <= salary_rule.max_monthly_days_worked)
        end

        #verify monthly service count goal, and calculate appointments count
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
        
        #verify appointments hours worked goal, and calculate appointments duration
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
          if salary_rule.max_time_between_appointments.present? || salary_rule.min_time_between_appointments.present?
            return unless targeted_appointments.present?

            appointment_start_and_end_grouped_by_date = targeted_appointments.pluck(:starts_at, :ends_at).group_by {|appointment| appointment[0].try(:to_date) }
            count_with_condition = 0

            # for each day with appointments, count the times between appointments under time constraints
            appointment_start_and_end_grouped_by_date.each do |date, start_and_end|
              if start_and_end.count > 1
                for i in 0..(start_and_end.count - 2)
                  time_difference = start_and_end[i + 1][0] - start_and_end[i][1]

                  #time difference should be greater than minimum (or 0) and less than maximum (or 24hours i.e 1440min)
                  condition = (time_difference >= ((salary_rule.min_time_between_appointments || 0) * 60)) && (time_difference <= ((salary_rule.max_time_between_appointments || 1440)* 60))

                  count_with_condition += 1 if condition
                end
              end
            end

            appointments_count = count_with_condition
          else
            # simply count the times between appointments
            day_count = targeted_appointments.present? ? targeted_appointments.pluck(:starts_at).map(&:to_date).uniq.size : 0
            appointments_count -= day_count
          end
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
        when 5
            #multiply arg per number of days worked
            number_of_days_worked = targeted_appointments.present? ? targeted_appointments.pluck(:starts_at).map(&:to_date).uniq.count : 0
            total_wage = number_of_days_worked * (salary_rule.argument || 0)
        else
            total_wage = 0
        end
        
        #creating/updating provided service
        if met_goals && total_wage != 0
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