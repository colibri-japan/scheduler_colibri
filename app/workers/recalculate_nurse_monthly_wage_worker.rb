class RecalculateNurseMonthlyWageWorker
    include Sidekiq::Worker
    sidekiq_options retry: false

    def perform(nurse_id, year, month)
        nurse = Nurse.find(nurse_id)
        start_of_month = DateTime.new(year.to_i, month.to_i, 1,0,0,0)
        end_of_month = start_of_month.end_of_month

        #recalculate wages from appointments
        nurse.appointments.operational.in_range(start_of_month..end_of_month).each do |appointment|
            if appointment.service.present?
                nurse_service_wage = nurse.nurse_service_wages.where(service_id: appointment.service.id).first

                if nurse_service_wage.present?
                    unit_wage_to_apply = appointment.weekend_holiday_salary_line_item? ? (nurse_service_wage.weekend_unit_wage || nurse_service_wage.unit_wage || 0) : (nurse_service_wage.unit_wage || 0)
                    total_wage = appointment.service.hour_based_wage? ? ((appointment.duration.to_f || 0) / 3600) * unit_wage_to_apply.to_i : unit_wage_to_apply.to_i
                    appointment.update_column(:total_wage, total_wage)
                else
                    unit_wage_to_apply = appointment.weekend_holiday_salary_line_item? ? (appointment.service.weekend_unit_wage || appointment.service.unit_wage || 0) : (appointment.service.unit_wage || 0)
                    total_wage = appointment.service.hour_based_wage? ? ((appointment.duration.to_f || 0) / 3600) * unit_wage_to_apply.to_i : unit_wage_to_apply.to_i
                    appointment.update_column(:total_wage, total_wage)
                end
            end
        end

        #delete and recalculate wages from salary rules, leave manually added bonuses as is
        nurse.salary_line_items.from_salary_rules.in_range(start_of_month..end_of_month).delete_all
        RecalculateSalaryLineItemsFromSalaryRulesWorker.perform_async(nurse_id, year, month)

    end

end