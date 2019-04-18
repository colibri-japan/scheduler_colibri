class SalaryRule < ApplicationRecord
    belongs_to :corporation
    has_many :provided_services

    private

    def self.calculate_salaries
        start_of_month = (Time.current + 9.hours).beginning_of_month
        end_of_month = start_of_month.end_of_month
        end_of_today = (Time.current + 9.hours).end_of_day > end_of_month ? end_of_month : (Time.current + 9.hours).end_of_day

        SalaryRule.all.each do |salary_rule|
            corporation = salary_rule.corporation
            nurses = salary_rule.target_all_nurses ? corporation.nurses.displayable : Nurse.where(id: salary_rule.nurse_id_list, corporation_id: corporation.id)
            targeted_titles = salary_rule.target_all_services ? corporation.services.where(nurse_id: nil).pluck(:title) : salary_rule.service_title_list

            nurses.each do |nurse|
                provided_services_from_rule = ProvidedService.where(nurse_id: nurse.id, salary_rule_id: salary_rule.id).in_range(start_of_month..end_of_month)
                targeted_services = ProvidedService.includes(:appointment).where(nurse_id: nurse.id, salary_rule_id: nil, archived_at: nil, cancelled: false, title: targeted_titles).where(appointments: {edit_requested: false}).from_appointments.in_range(start_of_month..end_of_today)
                service_counts = targeted_services.count
                service_duration = targeted_services.sum(:service_duration)

                #substract previous career bonus
                case salary_rule.target_nurse_by_filter
                when 1
                    previous_career_rule = SalaryRule.where(corporation_id: corporation.id, target_nurse_by_filter: 0).first
                    previous_career_bonus = ProvidedService.where(nurse_id: nurse.id, salary_rule_id: previous_career_rule.id).in_range(start_of_month..end_of_month).first
                    service_counts -= previous_career_bonus.service_counts  unless previous_career_bonus.nil?
                    service_duration -= previous_career_bonus.service_duration unless previous_career_bonus.nil?
                when 2
                    previous_career_rule = SalaryRule.where(corporation_id: corporation.id, target_nurse_by_filter: 1).first
                    previous_career_bonus = ProvidedService.where(nurse_id: nurse.id, salary_rule_id: previous_career_rule.id).in_range(start_of_month..end_of_month).first
                    service_counts -= previous_career_bonus.service_counts unless previous_career_bonus.nil?
                    service_duration -= previous_career_bonus.service_duration unless previous_career_bonus.nil?
                else
                end

                #calculating total wage
                if salary_rule.operator == 0
                    #addition
                    if salary_rule.hour_based
                        #addition based on worked hours
                        total_wage = (service_duration / 60) * (salary_rule.argument.to_f / 60) || 0
                    else
                        #addition based on service counts
                        total_wage = service_counts * salary_rule.argument.to_f || 0
                    end
                elsif salary_rule.operator == 1
                    #multiplication
                    total_wage = targeted_services.sum(:total_wage) * salary_rule.argument.to_f || 0
                else 
                    total_wage = 0
                end

                #creating/updating provided service
                if provided_services_from_rule.present?
                    provided_services_from_rule.first.update(service_counts: service_counts, service_duration: service_duration, total_wage: total_wage)
                else
                    ProvidedService.create(nurse_id: nurse.id, planning_id: corporation.planning.id, salary_rule_id: salary_rule.id, service_date: (Time.current + 9.hours), title: salary_rule.title, hour_based_wage: salary_rule.hour_based, total_wage: total_wage, service_duration: service_duration, service_counts: service_counts)
                end
            end
        end
    end

    def self.refresh_targeted_nurses
        SalaryRule.where.not(target_nurse_by_filter: nil).each do |salary_rule|
            case salary_rule.target_nurse_by_filter
            when 0
                nurse_ids = salary_rule.corporation.nurses.displayable.where('days_worked BETWEEN ? and ?', 100, 299).ids
            when 1
                nurse_ids = salary_rule.corporation.nurses.displayable.where('days_worked BETWEEN ? and ?', 300, 499).ids
            when 2
                nurse_ids = salary_rule.corporation.nurses.displayable.where('days_worked >= ?', 500).ids
            else
                nurse_ids =[]
            end

            salary_rule.update_columns(nurse_id_list: nurse_ids, updated_at: Time.current)
        end
    end

end
