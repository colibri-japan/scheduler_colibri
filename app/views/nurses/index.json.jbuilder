json.array!(@nurses) do |nurse|
	json.id nurse.id
	json.title nurse.name
	json.is_nurse_resource true
end