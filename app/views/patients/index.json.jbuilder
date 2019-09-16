json.array!(@patients) do |patient|
	json.id "patient_#{patient.id}"
	json.title patient.name
	json.model_name 'patient'
	json.record_id patient.id
end