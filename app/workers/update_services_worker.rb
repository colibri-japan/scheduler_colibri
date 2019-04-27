class UpdateServicesWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(service_id, service_ids_array)
    updated_service = Service.find(service_id)
    services_to_update = Service.where(id: service_ids_array.to_a)

    services_to_update.update_all(title: updated_service.title, unit_wage: updated_service.unit_wage, weekend_unit_wage: updated_service.weekend_unit_wage, hour_based_wage: updated_service.hour_based_wage, equal_salary: updated_service.equal_salary, category_1: updated_service.category_1, category_2: updated_service.category_2, category_ratio: updated_service.category_ratio, official_title: updated_service.official_title, unit_credits: updated_service.unit_credits, service_code: updated_service.service_code, updated_at: Time.current)
  end
end