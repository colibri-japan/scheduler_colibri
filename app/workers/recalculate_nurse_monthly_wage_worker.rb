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
                    unit_wage_to_apply = appointment.on_weekend_or_holiday? ? (nurse_service_wage.weekend_unit_wage || nurse_service_wage.unit_wage || appointment.service.try(:weekend_unit_wage) || appointment.service.try(:unit_wage) || 0) : (nurse_service_wage.unit_wage || appointment.service.try(:unit_wage) || 0)
                    if appointment.service.hour_based_wage?
                        hour_based_calculation = (((appointment.duration.to_f || 0) / 3600) * unit_wage_to_apply.to_i).round
                        if appointment.service.minimum_wage.present? 
                            total_wage = hour_based_calculation >= appointment.service.minimum_wage ? hour_based_calculation : appointment.service.minimum_wage
                        else
                            total_wage = hour_based_calculation
                        end
                    else
                        total_wage = unit_wage_to_apply.to_i
                    end
                    appointment.update_column(:total_wage, total_wage)
                else
                    unit_wage_to_apply = appointment.on_weekend_or_holiday? ? (appointment.service.weekend_unit_wage || appointment.service.unit_wage || 0) : (appointment.service.unit_wage || 0)
                    if appointment.service.hour_based_wage?
                        hour_based_calculation = (((appointment.duration.to_f || 0) / 3600) * unit_wage_to_apply.to_i).round 
                        if appointment.service.minimum_wage.present?
                            total_wage = hour_based_calculation >= appointment.service.minimum_wage ? hour_based_calculation : appointment.service.minimum_wage
                        else
                            total_wage = hour_based_calculation
                        end
                    else
                        total_wage = unit_wage_to_apply.to_i
                    end
                    appointment.update_column(:total_wage, total_wage)
                end
                if appointment.second_nurse_id.present? && appointment.service.second_nurse_unit_wage.present? 
                    appointment.second_nurse_wage = appointment.service.second_nurse_hour_based_wage? ? ((appointment.duration.to_f / 3600) * appointment.service.second_nurse_unit_wage.to_i).round : appointment.service.second_nurse_unit_wage
                end
            end
        end

        #recalculate bonuses
        RecalculateSalaryLineItemsFromSalaryRulesWorker.perform_async(nurse_id, year, month)

    end

end