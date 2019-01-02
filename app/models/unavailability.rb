class Unavailability < ApplicationRecord
	include PublicActivity::Common

	belongs_to :nurse, optional: true
	belongs_to :planning
	belongs_to :patient, optional: true

	before_validation :set_title
	validates :title, presence: true


	def all_day_unavailability?
		self.starts_at == self.starts_at.midnight && self.ends_at == self.ends_at.midnight ? true : false
	end
	
	def as_json
		{
			id: "unavailability_#{self.id}",
			title: self.title,
			start: self.starts_at,
			end: self.ends_at,
			patient_id: self.patient_id,
			nurse_id: self.nurse_id,
			edit_requested: self.edit_requested,
			description: self.description,
			resourceId: self.nurse_id,
			allDay: self.all_day_unavailability?,
			color: '#ff7777',
			base_url: "/plannings/#{self.planning_id}/unavailabilities/#{self.id}",
			edit_url: "/plannings/#{self.planning_id}/unavailabilities/#{self.id}/edit",
			displayable: true,
			unavailability: true,
			service_type: self.title,
			nurse: {
				name: self.nurse.name,
			},
			patient: {
				name: self.patient.name,
				address: self.patient.address
			},

		}
	end


	private

	def set_title
		self.title = "サービス不可" if self.title.empty?
	end
end
