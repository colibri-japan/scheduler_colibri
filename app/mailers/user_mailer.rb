class UserMailer < ApplicationMailer

    add_template_helper(NursesHelper)

    def master_availabilities(query_day, master_availabilities, user)
        @user = user 
        @corporation = @user.corporation 
        @printing_option = @corporation.printing_option
        @master_availabilities = master_availabilities
        @query_day = query_day

        attachments["空き情報_#{@query_day.try(:j_year_month)}.pdf"] = WickedPdf.new.pdf_from_string(
            render_to_string('nurses/master_availabilities.pdf.erb', 
                layout: 'pdf.html'),
            {
                page_size: 'A4',
                orientation: 'landscape',
                encoding: 'UTF-8',
                zoom: 1,
                dpi: 75
            }
        )

        mail to: user.email,
            from: "#{@corporation.name} <info@colibri.jp>",
            subject: "#{@corporation.name}様空き情報"
    end
end
