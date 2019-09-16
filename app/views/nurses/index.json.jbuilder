json.array!(@nurses) do |nurse|
	json.id "nurse_#{nurse.id}"
	json.title nurse.name
	json.model_name 'nurse'
	json.record_id nurse.id
end