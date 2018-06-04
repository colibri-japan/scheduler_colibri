# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

	patients = Patient.create([{name: "利用者１", phone_number: "07010567834", phone_mail: "patient1234@docomo.co.jp", address: "横浜市港北区日吉本町２－５６７－４"}, {name: "利用者２", phone_number: "07017658790", phone_mail: "patient5678@docomo.co.jp", address: "横浜市港北区日吉本町２－６５－５"}, {name: "利用者３", phone_number: "07076907835", phone_mail: "patient3679@docomo.co.jp", address: "横浜市港北区日吉本町１－５－４５"}])