# Preview all emails at http://localhost:3000/rails/mailers/nurse_mailer
class NurseMailerPreview < ActionMailer::Preview

    def reminder_email
        nurse = Nurse.first
        appointments = nurse.appointments.last(5)
        NurseMailer.reminder_email(nurse, appointments)
    end

end