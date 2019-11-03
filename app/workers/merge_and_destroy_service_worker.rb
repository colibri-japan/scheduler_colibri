class MergeAndDestroyServiceWorker
  include Sidekiq::Worker 
  sidekiq_options retry: false 

  def perform(service_id_to_delete, service_id_to_copy)
    service_to_delete = Service.find(service_id_to_delete)
    destination_service = Service.find(service_id_to_copy)
    corporation = service_to_delete.corporation
    planning_id = corporation.planning.id
    nurses = corporation.nurses

    nurse_year_and_months = []
    
    nurses.each do |nurse|
      years_and_months = nurse.appointments.where(service_id: service_to_delete.id).not_archived.pluck(:starts_at).map {|e| [nurse.id, e.year, e.month]}.uniq
      nurse_year_and_months << years_and_months if years_and_months.present?
    end

    nurse_year_and_months = nurse_year_and_months.flatten(1)

    service_to_delete.appointments.update_all(service_id: destination_service.id, title: destination_service.title, updated_at: Time.current)
    service_to_delete.recurring_appointments.update_all(service_id: destination_service.id, title: destination_service.title, updated_at: Time.current)
    
    nurse_year_and_months.each do |nurse_id, year, month|
      RecalculateNurseMonthlyWageWorker.perform_async(nurse_id, year, month)
    end

    service_to_delete.delete
    corporation.touch
  end
end