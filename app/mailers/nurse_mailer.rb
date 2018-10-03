class NurseMailer < ApplicationMailer
	add_template_helper(ApplicationHelper)


	def reminder_email(nurse, appointments, custom_message)
		@nurse = nurse
		@corporation = @nurse.corporation
		@appointments = appointments
		@today = Time.current
		@custom_message = custom_message

		if [1,2,3,4].include?(@today.wday)
			subject = "#{@corporation.name}：#{@today.day + 1}日のスケジュール"
			mail to: @nurse.phone_mail, bcc: @corporation.email, from: @corporation.email, subject: subject
		elsif @today.wday == 5 
			subject = "#{@corporation.name}：#{@today.day + 1}、#{@today.day + 2}、#{@today.day + 3}日のスケジュール"
			mail to: @nurse.phone_mail, bcc: @corporation.email, from: @corporation.email, subject: subject
		end
	end


end
