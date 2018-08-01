class NurseMailer < ApplicationMailer


	def reminder_email(nurse, recurring_appointments)
		@nurse = nurse
		@corporation = @nurse.corporation
		@appointments = recurring_appointments

		mail to: @nurse.phone_mail, subject: "#{@corporation.name}：本日のスケジュール"
	end


end
