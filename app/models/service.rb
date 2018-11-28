class Service < ApplicationRecord
  attribute :recalculate_previous_wages, :boolean
  attribute :skip_create_nurses_callback, :boolean
  attribute :skip_update_nurses_callback, :boolean
  attribute :planning_id, :integer

  belongs_to :corporation
  has_many :invoice_setting_services
  has_many :invoice_settings, through: :invoice_setting_services
  has_many :appointments
  has_many :recurring_appointments
  has_many :provided_services
  belongs_to :nurse, optional: true

  before_create :default_hour_based_wage
  before_create :default_equal_salary

  after_create :create_nurse_services, unless: :skip_create_nurses_callback
  after_update :update_nurse_services, unless: :skip_update_nurses_callback
  before_destroy :destroy_services_for_other_nurses

  scope :order_by_title, -> { order(:title) }
  scope :without_nurse_id, -> { where(nurse_id: nil) }

  private 

  def default_hour_based_wage
    self.hour_based_wage = self.corporation.hour_based_wage if self.hour_based_wage.nil?
  end

  def default_equal_salary
    self.equal_salary = self.corporation.equal_salary if self.equal_salary.nil?
  end

  def recalculate_wages
    puts 'recalculating wages'
    #do it only for a fraction of services and the rest in background

    if self.equal_salary == true 
      plannings_ids = self.corporation.plannings.ids
      @provided_services = ProvidedService.where(title: self.title, planning_id: plannings_ids)
    else
      if self.nurse_id.present?
        @provided_services = ProvidedService.where(title: self.title, nurse_id: self.nurse_id)
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
        new_service = Service.new(corporation_id: self.corporation_id, title: self.title, nurse_id: nurse.id, unit_wage: self.unit_wage, weekend_unit_wage: self.weekend_unit_wage, hour_based_wage: self.hour_based_wage, equal_salary: self.equal_salary, skip_create_nurses_callback: true)
        new_services << new_service
      end
    end

    Service.import new_services
  end

  def update_nurse_services
    #update other services only if updated the 'main' service, or if the equal salary option is set to true
    if self.nurse_id.nil? 
      nurse_services_ids = Service.where(corporation_id: self.corporation_id, title: self.title).where.not(nurse_id: nil).ids
      puts 'nurse id nil'
      puts 'ids of services to update'
      puts nurse_services_ids

      UpdateServicesWorker.perform_async(self.id, nurse_services_ids)
    else
      if self.equal_salary == true 
        puts 'equal salary is true'
        services_to_update_ids = Service.where(corporation_id: self.corporation_id, title: self.title).where.not(id: self.id).ids 
        puts 'ids of services to update'
        puts services_to_update_ids
        UpdateServicesWorker.perform_async(self.id, services_to_update_ids)
      end
    end
  end

  def destroy_services_for_other_nurses
    if self.nurse_id.present? 
      other_services = Service.where(corporation_id: self.corporation_id, title: self.title).where.not(nurse_id: self.nurse_id)

      other_services.delete_all
    end
  end


end
