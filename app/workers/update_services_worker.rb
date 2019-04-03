class UpdateServicesWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(service_id, service_ids_array)
    updated_service = Service.find(service_id)
    services_to_update = Service.where(id: service_ids_array.to_a)

    services_to_update.update_all(title: updated_service.title, unit_wage: updated_service.unit_wage, weekend_unit_wage: updated_service.weekend_unit_wage, hour_based_wage: updated_service.hour_based_wage, equal_salary: updated_service.equal_salary, updated_at: Time.current)
  end
end