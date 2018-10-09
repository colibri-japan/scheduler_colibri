json.array!(@patients) do |patient|
	json.id patient.id
	json.title patient.name
end