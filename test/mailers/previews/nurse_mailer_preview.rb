# Preview all emails at http://localhost:3000/rails/mailers/nurse_mailer
class NurseMailerPreview < ActionMailer::Preview

    def reminder_email
        nurse = Nurse.first
        appointments = nurse.appointments.where(starts_at: Date.today.beginning_of_day..(Date.today + 3.days).end_of_day)
        days = [Date.today, Date.today+1]
        NurseMailer.reminder_email(nurse, appointments, days       )
    end

end