class RecalculateNurseMonthlyWageWorker
    include Sidekiq::Worker
    sidekiq_options retry: false

    def perform(nurse_id, year, month)
        nurse = Nurse.find(nurse_id)
        start_of_month = DateTime.new(year.to_i, month.to_i, 1,0,0,0)
        end_of_month = start_of_month.end_of_month

        nurse.appointments.operational.in_range(start_of_month..end_of_month).each do |appointment|
            if appointment.service.present?
                nurse_service_wage = nurse.nurse_service_wages.where(service_id: appointment.service.id).first

                unit_wage = nurse_service_wage.try(:unit_wage) || appointment.service.unit_wage || 0

                if appointment.service.hour_based_wage?
                    total_wage = ((appointment.duration || 0) / 3600) * (unit_wage || 0)
                    appointment.update_column(:total_wage, total_wage)
                else
                    appointment.update_column(:total_wage, unit_wage)
                end
            end
        end

        nurse.salary_line_items.from_salary_rules.in_range(start_of_month..end_of_month).delete_all

        RecalculateSalaryLineItemsFromSalaryRulesWorker.perform_async(nurse_id, year, month)
    end

end