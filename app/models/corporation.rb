class Corporation < ApplicationRecord
	has_many :users
	has_many :plannings
	has_many :nurses
	has_many :patients
	has_many :services

	after_create :create_undefined_nurse

	def self.add_undefined_nurse
		corporations = Corporation.all

		corporations.each do |corporation|
			corporation.nurses.create(name: "未定", displayable: false, kana: "あああああ")
		end
	end

	private

	def create_undefined_nurse
		self.nurses.create(name: "未定", displayable: false, kana: "あああああ")
	end

	def self.add_services
		corporations = Corporation.all 

		corporations.each do |corporation|
			plannings = corporation.plannings

			appointments = Appointment.where(planning_id: plannings.ids, master: true)

			appointments.each do |appointment|
				existing_service = corporation.services.where(title: appointment.title)

				unless existing_service.present?
					new_service = corporation.services.create(title: appointment.title)
				end
			end

		end
	end

end
