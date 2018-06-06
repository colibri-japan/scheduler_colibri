json.array!(@nurses) do |nurse|
	json.id nurse.id
	json.title nurse.name
end