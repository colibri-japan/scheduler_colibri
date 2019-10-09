class CompletionReport < ApplicationRecord
    belongs_to :reportable, polymorphic: true

    scope :from_appointments, -> { where(reportable_type: 'Appointment') }
    scope :from_recurring_appointments, -> { where(reportable_type: 'RecurringAppointment') }
end
