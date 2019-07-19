class RecalculatePreviousWagesWorker
  include Sidekiq::Worker 
  sidekiq_options retry: false 

  def perform(service_id)
    puts 'performing recalculate previous wages'
    updated_service = Service.find(service_id)
    planning_id = updated_service.corporation.planning.id

    #if updated_service.equal_salary == true 
    #    salary_line_items_to_update = SalaryLineItem.where(title: updated_service.title, planning_id: planning_id)
    #else
    #    salary_line_items_to_update = SalaryLineItem.where(title: updated_service.title, planning_id: planning_id, nurse_id: updated_service.nurse_id)
    #end

    salary_line_items_to_update.find_each do |salary_line_item|
      if salary_line_item.appointment.present?
          salary_line_item.unit_cost = salary_line_item.weekend_holiday_salary_line_item? ? updated_service.weekend_unit_wage : updated_service.unit_wage
          salary_line_item.skip_callbacks_except_calculate_total_wage = true 
          salary_line_item.save
      end
    end
  end

end