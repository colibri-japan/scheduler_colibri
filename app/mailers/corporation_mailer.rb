class CorporationMailer < ApplicationMailer
	add_template_helper(ApplicationHelper)
	add_template_helper(AppointmentsHelper)
	add_template_helper(SalaryLineItemsHelper)
	add_template_helper(PatientsHelper)

	def all_nurses_payable_email(corporation, data, start_date, options={})
		@data = data 
		@corporation = corporation
		@year = start_date.to_date.year 
		@month = start_date.to_date.month
		
		attachments["給与明細一覧.pdf"] = WickedPdf.new.pdf_from_string(
            render_to_string('corporations/all_nurses_payable.pdf.erb', 
                layout: 'pdf.html'),
            {
                page_size: 'A4',
                orientation: 'portrait',
                encoding: 'UTF-8',
                zoom: 1,
                dpi: 75
            }
        )

		mail to: @corporation.email, from: "Colibri <info@colibri.jp>", reply_to: "Colibri <info@colibri.jp>", subject: "給与明細"
	end

	def monthly_appointments_email(corporation, year, month, appointments, options= {})
		@appointments = appointments 
		@corporation = corporation 
		@year = year 
		@month = month 

		xlsx = render_to_string layout: false, handlers: [:axlsx], formats: [:xlsx], template: "plannings/monthly_appointments_report"
		attachment = Base64.encode64(xlsx)
		attachments["#{@year}年#{@month}月全サービス.xlsx"] = {mime_type: Mime[:xlsx], content: attachment, encoding: 'base64'}

		mail to: @corporation.email, from: "Colibri  <info@colibri.jp>", reply_to: "Colibri <info@colibri.jp>", subject: "#{@year}年#{@month}月の全サービスレポート"
	end


end
