class Service < ApplicationRecord
  attribute :recalculate_previous_wages, :boolean
  attribute :skip_create_nurses_callback, :boolean

  belongs_to :corporation
  has_many :invoice_setting_services
  has_many :invoice_settings, through: :invoice_setting_services
  has_many :appointments
  has_many :recurring_appointments
  has_many :provided_services
  belongs_to :nurse, optional: true

  after_save :recalculate_wages, if: :recalculate_previous_wages
  after_create :create_nurse_services, unless: :skip_create_nurses_callback

  before_destroy :destroy_services_for_other_nurses

  scope :order_by_title, -> { order(:title) }
  scope :without_nurse_id, -> { where(nurse_id: nil) }

  private 

  def recalculate_wages
    puts 'recalculating wages'
    if self.corporation.equal_salary == true 
      plannings_ids = self.corporation.plannings.ids

      @provided_services = ProvidedService.where(title: self.title, planning_id: plannings_ids, deactivated: false, temporary: false)

    else
      if self.nurse_id.present?
        @provided_services = ProvidedService.where(title: self.title, nurse_id: self.nurse_id, temporary: false).where.not(deactivated: true)
      else
        @provided_services = []
      end
    end

    @weekday_wage = self.unit_wage 
    @weekend_wage = self.weekend_unit_wage

    @provided_services.each do |provided_service|
      if provided_service.temporary == false && provided_service.service_date.present?

        provided_service.unit_cost = provided_service.weekend_holiday_provided_service? ? @weekend_wage : @weekday_wage

        provided_service.skip_callbacks_except_calculate_total_wage = true 

        provided_service.save!

      end
    end


  end

  def create_nurse_services 
    nurses = self.corporation.nurses.where(displayable: true)
    nurse_services = Service.where(title: self.title, nurse_id: nurses.ids).all
    new_services = []

    nurses.each do |nurse|
      nurse_service = nurse_services.where(nurse_id: nurse.id).first 

      unless nurse_service.present?
        new_service = Service.new(corporation_id: self.corporation_id, title: self.title, nurse_id: nurse.id, unit_wage: self.unit_wage, weekend_unit_wage: self.weekend_unit_wage, skip_create_nurses_callback: true)
        new_services << new_service
      end
    end

    Service.import new_services
  end

  def destroy_services_for_other_nurses
    if self.nurse_id.present? 
      other_services = Service.where(corporation_id: self.corporation_id, title: self.title).where.not(nurse_id: self.nurse_id)

      other_services.delete_all
    end
  end


end
