class MergeAndDestroyServiceWorker
  include Sidekiq::Worker 
  sidekiq_options retry: false 

  def perform(service_id_to_delete, service_id_to_copy)
    service_to_delete = Service.find(service_id_to_delete)
    destination_service = Service.find(service_id_to_copy)
    corporation = service_to_delete.corporation
    planning_id = corporation.planning.id
    nurses = corporation.nurses

    Appointment.where(title: service_to_delete.title, planning_id: planning_id).update_all(service_id: destination_service.id, title: destination_service.title, updated_at: Time.current)
    RecurringAppointment.where(title: service_to_delete.title, planning_id: planning_id).update_all(service_id: destination_service.id, title: destination_service.title, updated_at: Time.current)

    nurses.each do |nurse|
      destination_nurse_service = Service.where(nurse_id: nurse.id, title: destination_service.title, corporation_id: service_to_delete.corporation_id).first
      service_salary_id = destination_nurse_service.present? ? destination_nurse_service.id : destination_service.id

      provided_services_to_update = ProvidedService.from_appointments.not_archived.where(title: service_to_delete.title, planning_id: planning_id, nurse_id: nurse.id)

      if provided_services_to_update.present? 
        provided_services_to_update.each do |provided_service|
          if destination_nurse_service.present?
            new_unit_cost = provided_service.weekend_holiday_provided_service? ? destination_nurse_service.weekend_unit_wage : destination_nurse_service.unit_wage 
          else
            new_unit_cost = provided_service.weekend_holiday_provided_service? ? destination_service.weekend_unit_wage : destination_service.unit_wage
          end
          provided_service.update(title: destination_service.title, service_salary_id: service_salary_id, hour_based_wage: destination_service.hour_based_wage, unit_cost: new_unit_cost, skip_callbacks_except_calculate_total_wage: true)
        end
        years_and_months_selected = provided_services_to_update.pluck(:service_date).map{|e| e.strftime("%Y-%m")}.uniq.map{|e| e.split('-')}
        years_and_months_selected.each do |year_and_month|
          RecalculateProvidedServicesFromSalaryRulesWorker.perform_async(nurse.id, year_and_month[0], year_and_month[1])
        end
      end

    end

    Service.where(title: service_to_delete.title).delete_all
    corporation.touch
  end
end