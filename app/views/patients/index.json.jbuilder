json.array!(@patients) do |patient|
	json.id patient.id
	json.title patient.name
	json.is_nurse_resource false
end