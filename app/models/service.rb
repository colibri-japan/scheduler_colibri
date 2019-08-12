class Service < ApplicationRecord
  attribute :planning_id, :integer

  belongs_to :corporation, touch: true
  has_many :appointments
  has_many :recurring_appointments
  has_many :salary_line_items
  belongs_to :nurse, optional: true
  has_many :nurse_service_wages

  before_create :default_hour_based_wage

  after_commit :reflect_credits_and_invoiced_amount_to_appointments, on: :update, if: :should_recalculate_credits_and_invoiced_amount
  after_commit :recalculate_appointments_wage, on: :update, if: :should_recalculate_wages
  before_destroy :destroy_services_for_other_nurses

  scope :order_by_title, -> { order(:title) }
  scope :without_nurse_id, -> { where(nurse_id: nil) }


  def invoiced_to_insurance?
    service_code.present? && official_title.present? && inside_insurance_scope?
  end

  def self.delivered_in_range(range)
    joins('left join appointments on appointments.service_id = services.id').where(appointments: {cancelled: false, edit_requested: false, archived_at: nil, starts_at: range})
  end

  def should_recalculate_credits_and_invoiced_amount
    saved_change_to_unit_credits? || saved_change_to_invoiced_amount?
  end

  def should_recalculate_wages
    saved_change_to_unit_wage? || saved_change_to_hour_based_wage?
  end

  private 

  def default_hour_based_wage
    self.hour_based_wage = self.corporation.hour_based_payroll if self.hour_based_wage.nil?
  end

  def reflect_credits_and_invoiced_amount_to_appointments
    ReflectCreditsAndInvoicedAmountToAppointmentsWorker.perform_async(self.id)
  end

  def recalculate_appointments_wage
    ReflectWageToAppointmentsWorker.perform_async(self.id)
  end

  def destroy_services_for_other_nurses
    Service.where(corporation_id: self.corporation_id, title: self.title).where.not(nurse_id: self.nurse_id).delete_all if self.nurse_id.present? 
  end


end
