class SalaryRule < ApplicationRecord
    attribute :one_time_salary_rule, :boolean 
    attribute :service_date, :date
    # attribute :service_date_range_start, :datetime
    # attribute :service_date_range_end, :datetime

    belongs_to :corporation
    has_many :salary_line_items

    scope :not_expired_at, -> date { where('expires_at IS NULL OR expires_at > ?', date) }
    scope :targeting_nurse, -> nurse_id { where('target_all_nurses IS TRUE OR (target_all_nurses IS FALSE AND ? = ANY(nurse_id_list))', nurse_id) }    

    before_create :set_expiry, if: :one_time_salary_rule
    after_commit :create_salary_line_item, if: :one_time_salary_rule

    def calculate_from_hours?
        operator == 1
    end

    private

    def set_expiry
        self.expires_at = Time.current
    end

    def create_salary_line_item
        CreateSalaryLineItemFromOneTimeSalaryRuleWorker.perform_async(self.id, self.service_date)
    end

end
