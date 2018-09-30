class Service < ApplicationRecord
  attribute :recalculate_previous_wages, :boolean
  attribute :skip_create_nurses_callback, :boolean

  belongs_to :corporation
  has_many :invoice_setting_services
  has_many :invoice_settings, through: :invoice_setting_services
  belongs_to :nurse, optional: true

  after_save :recalculate_wages, if: :recalculate_previous_wages
  after_create :create_nurse_services, unless: :skip_create_nurses_callback

  private 

  def recalculate_wages
    puts 'recalculating wages'
    if self.corporation.equal_salary == true 
      plannings_ids = self.corporation.plannings.ids
      puts 'planning ids'
      puts plannings_ids
      @provided_services = ProvidedService.where(title: self.title, planning_id: plannings_ids, deactivated: false, temporary: false)

      puts 'provided service counts'
      puts @provided_services.count

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

    nurses.each do |nurse|
      nurse_service = Service.create(corporation_id: self.corporation_id, title: self.title, nurse_id: nurse.id, unit_wage: self.unit_wage, weekend_unit_wage: self.weekend_unit_wage, skip_create_nurses_callback: true)
    end
  end


end
