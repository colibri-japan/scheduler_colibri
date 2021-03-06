class PrivateEvent < ApplicationRecord
	include PublicActivity::Common
	include CalendarEvent

	belongs_to :nurse, optional: true
	belongs_to :planning
	belongs_to :patient, optional: true

	before_validation :set_title
	validates :title, presence: true


	def self.overlapping(range)
		where('((private_events.starts_at >= ? AND private_events.starts_at < ?) OR (private_events.ends_at > ? AND private_events.ends_at <= ?)) OR (private_events.starts_at < ? AND private_events.ends_at > ?)', range.first, range.last, range.first, range.last, range.first, range.last)
	end
	
	def as_json(options = {})
		date_format = self.all_day? ? '%Y-%m-%d' : '%Y-%m-%dT%H:%M'
		{
			id: "private_event_#{self.id}",
			title: self.title,
			start: self.starts_at.try(:strftime, date_format),
			end: self.ends_at.try(:strftime, date_format),
			patient_id: self.patient_id,
			nurse_id: self.nurse_id,
			edit_requested: self.edit_requested,
			description: self.description || '',
			resourceIds: ["nurse_#{self.nurse_id}", "patient_#{self.patient_id}"],
			allDay: self.all_day?,
			color: '#ff7777',
			serviceType: self.title || '',
			nurse: {
				name: self.nurse.try(:name),
			},
			eventType: 'private_event',
			eventId: self.id,
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
