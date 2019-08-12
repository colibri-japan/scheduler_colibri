class ReflectWageToAppointmentsWorker
    include Sidekiq::Worker
    sidekiq_options retry: false

    def perform(service_id)
        service = Service.find(service_id)

        if service.present?
            if service.hour_based_wage?
                service.appointments.pluck(:id, :duration).group_by {|id_and_duration| id_and_duration[1]}.each do |duration, arrays_of_id_and_duration|
                    total_wage = (duration.to_f / 3600) * service.unit_wage 
                    service.appointments.where(id: arrays_of_id_and_duration.map {|e| e[0]}).update_all(total_wage: total_wage)
                end
            else
                service.appointments.update_all(total_wage: service.unit_wage)
            end
        end
    end

end