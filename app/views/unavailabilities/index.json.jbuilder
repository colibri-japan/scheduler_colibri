json.array! @unavailabilities.each do |unavailability|
    date_format = unavailability.all_day_unavailability? ? '%Y-%m-%d' : '%Y-%m-%dT%H:%M:%S'

    json.id "unavailability_#{unavailability.id}"

    json.extract! unavailability, :patient_id, :nurse_id, :edit_requested
    json.start unavailability.starts_at
    json.end unavailability.ends_at
    json.description unavailability.description ? unavailability.description : ''
    json.service_type unavailability.title ? unavailability.title : ''
    json.title "#{unavailability.patient.try(:name)} #{unavailability.nurse.try(:name)}: #{unavailability.title}" 

    json.allDay unavailability.all_day_unavailability? ? true : false

    json.unavailability true
    json.displayable true
    json.patient do 
        json.name unavailability.patient.try(:name)
        json.address unavailability.patient.try(:address)
    end

    json.resourceId unavailability.nurse_id

    if unavailability.nurse_id.present?
        json.nurse do 
            json.name unavailability.nurse.try(:name)
        end
    end

    json.color '#ff7777'

    json.base_url planning_unavailability_path(@planning, unavailability)
    json.edit_url edit_planning_unavailability_path(@planning, unavailability)
    json.update_url planning_unavailability_path(@planning, unavailability, method: :patch)
end