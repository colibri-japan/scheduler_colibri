class RecalculatePreviousWagesWorker
  include Sidekiq::Worker 
  sidekiq_options retry: false 

  def perform(service_id)
    puts 'performing recalculate previous wages'
    updated_service = Service.find(service_id)
    planning_id = updated_service.corporation.planning.id

    #if updated_service.equal_salary == true 
    #    provided_services_to_update = ProvidedService.where(title: updated_service.title, planning_id: planning_id)
    #else
    #    provided_services_to_update = ProvidedService.where(title: updated_service.title, planning_id: planning_id, nurse_id: updated_service.nurse_id)
    #end

    provided_services_to_update.find_each do |provided_service|
      if provided_service.appointment.present?
          provided_service.unit_cost = provided_service.weekend_holiday_provided_service? ? updated_service.weekend_unit_wage : updated_service.unit_wage
          provided_service.skip_callbacks_except_calculate_total_wage = true 
          provided_service.save
      end
    end
  end

end