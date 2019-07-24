class SalaryRule < ApplicationRecord
    attribute :one_time_salary_rule, :boolean 
    attribute :service_date_range_start, :datetime
    attribute :service_date_range_end, :datetime

    belongs_to :corporation
    has_many :salary_line_items

    scope :not_expired_at, -> date { where('expires_at IS NULL OR expires_at > ?', date) }
    scope :targeting_nurse, -> nurse_id { where('target_all_nurses IS TRUE OR (target_all_nurses IS FALSE AND ? = ANY(nurse_id_list))', nurse_id) }    

    before_create :set_expiry, if: :one_time_salary_rule
    after_create :create_salary_line_item, if: :one_time_salary_rule

    private

    def set_expiry
        self.expires_at = Time.current
    end

    def create_salary_line_item
        corporation = self.corporation
        targeted_nurses = self.target_all_nurses ? self.corporation.nurses.displayable : Nurse.where(id: self.nurse_id_list, corporation_id: corporation.id)
        targeted_titles = self.target_all_services ? corporation.services.where(nurse_id: nil).pluck(:title) : self.service_title_list
        start_of_range = self.service_date_range_start.to_datetime || Date.today.beginning_of_day
        end_of_range = self.service_date_range_end.to_datetime || Date.today.end_of_day
        
        targeted_nurses.each do |nurse|
            targeted_salary_line_items = SalaryLineItem.includes(:appointment).from_appointments.where(nurse_id: nurse.id, salary_rule_id: nil, archived_at: nil, cancelled: false, title: targeted_titles).where(appointments: {edit_requested: false}).in_range(start_of_range..end_of_range)
            
            case self.date_constraint
            when 1
                targeted_salary_line_items = targeted_salary_line_items.where('DATE(salary_line_items.service_date) IN (?)', HolidayJp.between(start_of_range, end_of_range))
            when 2
                targeted_salary_line_items = targeted_salary_line_items.where('EXTRACT(dow from salary_line_items.service_date) = 0')
            else
            end

            service_counts = targeted_salary_line_items.count || 0
            service_duration = targeted_salary_line_items.sum(:service_duration) || 0

            if self.operator == 0
                if self.hour_based 
                    total_wage = (service_duration / 60) * (self.argument.to_f / 60) || 0
                else
                    total_wage = service_counts * self.argument.to_f || 0
                end
            elsif self.operator == 1
                total_wage = targeted_salary_line_items.sum(:total_wage) * self.argument.to_f || 0
            else
                total_wage = 0
            end

            SalaryLineItem.create(nurse_id: nurse.id, planning_id: corporation.planning.id, service_date: (Time.current + 9.hours), title: self.title, hour_based_wage: self.hour_based, service_counts: service_counts, service_duration: service_duration, total_wage: total_wage, skip_callbacks_except_calculate_total_wage: true, skip_wage_credits_and_invoice_calculations: true)
        end
    end

    def self.calculate_salaries
        now_in_japan = Time.current + 9.hours
        start_of_month = now_in_japan.beginning_of_month
        end_of_today = now_in_japan.end_of_day

        SalaryRule.not_expired_at(now_in_japan).find_each do |salary_rule|
            corporation = salary_rule.corporation
            nurses = salary_rule.target_all_nurses ? corporation.nurses.displayable : Nurse.where(id: salary_rule.nurse_id_list, corporation_id: corporation.id)
            targeted_titles = salary_rule.target_all_services ? corporation.services.where(nurse_id: nil).pluck(:title) : salary_rule.service_title_list

            nurses.each do |nurse|
                targeted_appointments = nurse.appointments.operational.where(title: targeted_titles).in_range(start_of_month..end_of_today)
                
                #further targeting services from date condition
                case salary_rule.date_constraint
                when 1
                    #holidays
                    targeted_appointments = targeted_appointments.where('DATE(appointments.starts_at) IN (?)', HolidayJp.between(start_of_month, end_of_today).map(&:date)) 
                when 2
                    #sundays
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
                    appointments_count -= previous_career_bonus.service_counts if previous_career_bonus.present?
                    appointments_duration -= previous_career_bonus.service_duration if previous_career_bonus.present?
                when 2
                    previous_career_rule_id = corporation.salary_rules.where(target_nurse_by_filter: 1).first.try(:id)
                    previous_career_bonus = nurse.salary_line_items.where(salary_rule_id: previous_career_rule_id).in_range(start_of_month..end_of_today).first
                    appointments_count -= previous_career_bonus.service_counts if previous_career_bonus.present?
                    appointments_duration -= previous_career_bonus.service_duration if previous_career_bonus.present?
                else
                end

                #calculating total wage
                if salary_rule.operator == 0
                    #addition
                    if salary_rule.hour_based
                        #addition based on worked hours
                        total_wage = (appointments_duration / 60) * (salary_rule.argument.to_f / 60) || 0
                    else
                        #addition based on service counts
                        total_wage = appointments_count * salary_rule.argument.to_f || 0
                    end
                elsif salary_rule.operator == 1
                    #multiplication
                    total_wage = targeted_appointments.sum(:total_wage) * salary_rule.argument.to_f || 0
                else 
                    total_wage = 0
                end

                #creating/updating provided service
                salary_line_item_from_rule = salary_rule.salary_line_items.where(nurse_id: nurse.id, planning_id: corporation.planning.id, title: salary_rule.title, hour_based_wage: salary_rule.hour_based).in_range(start_of_month..end_of_today).first_or_create
                salary_line_item_from_rule.update_columns(service_counts: appointments_count, service_duration: appointments_duration, total_wage: total_wage, updated_at: Time.current, service_date: end_of_today.beginning_of_day)
            end
        end
    end

    def self.refresh_targeted_nurses
        SalaryRule.where.not(target_nurse_by_filter: nil).find_each do |salary_rule|
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
