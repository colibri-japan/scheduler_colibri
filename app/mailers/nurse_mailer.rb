class NurseMailer < ApplicationMailer
	add_template_helper(ApplicationHelper)


	def reminder_email(nurse, appointments, days, options={})
		@nurse = nurse
		@corporation = @nurse.corporation
		@appointments = appointments
		@custom_message = options[:custom_email_message] || ''
		@days = days

		day_text = @days.count > 1 ? @days.map{|e| e.day}.join(',') : @days.first.day

		subject = "#{@corporation.name}：#{day_text}日のスケジュール"
		mail to: @nurse.phone_mail, from: @corporation.email, bcc: @corporation.email, subject: subject
	end


end
