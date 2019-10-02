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

    def calculate_from_hours?
        operator == 1
    end

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
            targeted_appointments = nurse.appointments.operational.where(title: targeted_titles).in_range(start_of_range..end_of_range)
            
            case self.date_constraint
            when 1
                targeted_appointments = targeted_appointments.where('DATE(appointments.starts_at) IN (?)', HolidayJp.between(start_of_range, end_of_range))
            when 2
                targeted_appointments = targeted_appointments.where('EXTRACT(dow from appointments.starts_at) = 0')
            else
            end

            appointments_count = targeted_appointments.size || 0
            appointments_duration = targeted_appointments.sum(:duration) || 0

            #calculate total wage in function of operator
            case self.operator
            when 0
                #add arg per count
                total_wage = (appointments_count || 0) * (self.argument.to_f || 0) 
            when 1
                #add arg per hour
                total_wage = (appointments_duration || 0) * (self.argument.to_f || 0) / 3600
            when 2 
                #multiply salary by arg
                total_wage = (targeted_appointments.sum(:total_wage) || 0 ) * (self.argument.to_f || 0)
            when 3
                #add arg only once
                total_wage = self.argument || 0
            else
                total_wage = 0
            end

            SalaryLineItem.create(nurse_id: nurse.id, planning_id: corporation.planning.id, service_date: (Time.current + 9.hours), title: self.title, hour_based_wage: self.calculate_from_hours?, service_counts: appointments_count, service_duration: appointments_duration, total_wage: total_wage)
        end
    end

end
