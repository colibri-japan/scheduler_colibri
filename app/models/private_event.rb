class PrivateEvent < ApplicationRecord
	include PublicActivity::Common

	belongs_to :nurse, optional: true
	belongs_to :planning
	belongs_to :patient, optional: true

	before_validation :set_title
	validates :title, presence: true


	def self.overlapping(range)
		where('((private_events.starts_at >= ? AND private_events.starts_at < ?) OR (private_events.ends_at > ? AND private_events.ends_at <= ?)) OR (private_events.starts_at < ? AND private_events.ends_at > ?)', range.first, range.last, range.first, range.last, range.first, range.last)
	end
	def all_day_private_event?
		self.starts_at == self.starts_at.midnight && self.ends_at == self.ends_at.midnight
	end
	
	def as_json(options = {})
		{
			id: "private_event_#{self.id}",
			title: "#{self.nurse.try(:name)} #{self.patient.try(:name)}:#{self.title}",
			start: self.starts_at,
			end: self.ends_at,
			patient_id: self.patient_id,
			nurse_id: self.nurse_id,
			edit_requested: self.edit_requested,
			description: self.description || '',
			resourceId: options[:patient_resource] == true ? self.patient_id : self.nurse_id,
			allDay: self.all_day_private_event?,
			color: '#ff7777',
			base_url: "/plannings/#{self.planning_id}/private_events/#{self.id}",
			edit_url: "/plannings/#{self.planning_id}/private_events/#{self.id}/edit",
			displayable: true,
			private_event: true,
			service_type: self.title || '',
			nurse: {
				name: self.nurse.try(:name),
			},
			eventType: 'private_event',
			patient: {
				name: self.patient.try(:name),
				address: self.patient.try(:address)
			},

		}
	end


	private

	def set_title
		self.title = "サービス不可" if self.title.empty?
	end
end
