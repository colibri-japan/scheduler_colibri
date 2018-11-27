class UpdateServicesWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(service_id, service_ids_array)
    template_service = Service.find(service_id)
    services_to_update = service_ids_array.map {|id| Service.find(id)}

    services_to_update.each do |service|
      service.update(title: template_service.title, unit_wage: template_service.unit_wage, weekend_unit_wage: template_service.weekend_unit_wage, hour_based_wage: template_service.hour_based_wage, equal_salary: template_service.equal_salary)
    end
  end
end