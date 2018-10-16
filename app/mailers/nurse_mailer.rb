class NurseMailer < ApplicationMailer
	add_template_helper(ApplicationHelper)


	def reminder_email(nurse, appointments, days, options={})
		@nurse = nurse
		@corporation = @nurse.corporation
		@appointments = appointments
		@days = days
		@custom_message = options[:custom_email_message] || ''
		day_text = @days.count > 1 ? @days.map{|e| e.day}.join(',') : @days.first.day
		custom_subject = options[:custom_subject] || "#{@corporation.name}：#{day_text}日のスケジュール"

		mail to: @nurse.phone_mail, from: "#{@corporation.name} <info@colibri.jp>", bcc: @corporation.email, reply_to: @corporation.email, subject: custom_subject
	end


end
