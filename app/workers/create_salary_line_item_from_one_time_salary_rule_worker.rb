class CreateSalaryLineItemFromOneTimeSalaryRuleWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

    def perform(salary_rule_id, date)
        @salary_rule = SalaryRule.find(salary_rule_id)
        @corporation = @salary_rule.corporation
        targeted_nurses = @salary_rule.target_all_nurses ? @corporation.nurses.displayable : Nurse.where(id: @salary_rule.nurse_id_list, corporation_id: @corporation.id)
        targeted_titles = @salary_rule.target_all_services ? @corporation.services.where(nurse_id: nil).pluck(:title) : @salary_rule.service_title_list
        @targeted_date = date.to_date || Date.today
        
        targeted_nurses.each do |nurse|
            targeted_appointments = nurse.appointments.operational.where(title: targeted_titles).in_range((@targeted_date.beginning_of_day)..(@targeted_date.end_of_day))
            
            case @salary_rule.date_constraint
            when 1
                # holidays
                targeted_appointments = targeted_appointments.where('DATE(appointments.starts_at) IN (?)', HolidayJp.between(start_of_range, end_of_range))
            when 2
                # sundays
                targeted_appointments = targeted_appointments.where('EXTRACT(dow from appointments.starts_at) = 0')
            when 3
                # saturdays
                targeted_appointments = targeted_appointments.where('EXTRACT(dow from appointments.starts_at) = 6')
            else
            end

            appointments_count = targeted_appointments.size || 0
            appointments_duration = targeted_appointments.sum(:duration) || 0
            appointments_total_wage = targeted_appointments.sum(:total_wage) || 0

            #calculate total wage in function of operator
            case @salary_rule.operator
            when 0
                #add arg per count
                total_wage = appointments_count * (@salary_rule.argument.to_f || 0) 
            when 1
                #add arg per hour
                total_wage = appointments_duration * (@salary_rule.argument.to_f || 0) / 3600
            when 2 
                #multiply salary by arg
                total_wage = (appointments_total_wage * (@salary_rule.argument.to_f || 0)).ceil
            when 3
                #add arg only once
                total_wage = @salary_rule.argument || 0
            when 4
                #multiply salary plus bonus by arg
                total_bonus_wage = calculate_bonus_wage(nurse, @targeted_date)

                puts 'bonus and appointments total + grand total'

                puts total_bonus_wage
                puts appointments_total_wage
                
                total_wage = ((total_bonus_wage + appointments_total_wage) * (@salary_rule.argument.to_f || 0)).ceil
                puts total_wage
            else
                total_wage = 0
            end

            SalaryLineItem.create(nurse_id: nurse.id, planning_id: @corporation.planning.id, service_date: @targeted_date, title: @salary_rule.title, hour_based_wage: @salary_rule.calculate_from_hours?, service_counts: appointments_count, service_duration: appointments_duration, total_wage: total_wage)
        end
    end

    
    private 

    def calculate_bonus_wage(nurse, date)
        # ignore salary rules that are calculated only once a month, ignore salary_rule
        total_bonus_wage = 0
        targeted_salary_rules = @corporation.salary_rules.not_expired_at(Time.current).where.not(operator: 3).where.not(id: @salary_rule.id).targeting_nurse(["#{nurse.id}"])

        targeted_salary_rules.each do |rule|
            #date contraint for a given date
            next if rule.date_constraint == 1 && !HolidayJp.holiday?(date)
            next if rule.date_constraint == 2 && date.wday != 0
            next if rule.date_constraint == 3 && date.wday != 6

            #worked days constraint for a given date
            next if rule.min_days_worked.present? && nurse.days_worked_at(date, inside_insurance_scope: true) < rule.min_days_worked
            next if rule.max_days_worked.present? && nurse.days_worked_at(date, inside_insurance_scope: true) > rule.max_days_worked
            next if rule.min_months_worked.present? && nurse.date_from_worked_months(min_months_worked) > date
            next if rule.max_months_worked.present? && nurse.date_from_worked_months(max_months_worked) < date

            salary_rule_wage = 0

            bonus_titles = rule.target_all_services ? @corporation.services.where(nurse_id: nil).pluck(:title) : rule.service_title_list

            appointments_for_bonus = nurse.appointments.operational.in_range((date.beginning_of_day)..(date.end_of_day)).where(title: bonus_titles)


            appointments_for_bonus_count = appointments_for_bonus.size || 0
            appointments_for_bonus_duration = appointments_for_bonus.sum(:duration) || 0
            appointments_for_bonus_total_wage = appointments_for_bonus.sum(:total_wage) || 0

            #calculate bonus_wage
            case rule.operator
            when 0
                #add arg per count
                salary_rule_wage = appointments_for_bonus_count * (rule.argument.to_f || 0) 
            when 1
                #add arg per hour
                salary_rule_wage = appointments_for_bonus_duration * (rule.argument.to_f || 0) / 3600
            when 2 
                #multiply salary by arg
                salary_rule_wage = appointments_for_bonus_total_wage * (rule.argument.to_f || 0)
            end

            puts 'rule title and wage'
            puts rule.title 
            puts salary_rule_wage

            total_bonus_wage += salary_rule_wage
        end

        total_bonus_wage
    end
    


end