# WickedPDF Global Configuration
#
# Use this to set up shared configuration options for your entire application.
# Any of the configuration options shown here can also be applied to single
# models by passing arguments to the `render :pdf` call.
#
# To learn more, check out the README:
#
# https://github.com/mileszs/wicked_pdf/blob/master/README.md

if Rails.env.staging? || Rails.env.production?
  wkhtmltopdf_path =  Gem.bin_path('wkhtmltopdf-heroku', 'wkhtmltopdf-linux-amd64')
else
  wkhtmltopdf_path = 'C:\wkhtmltopdf\bin\wkhtmltopdf.exe'
end

WickedPdf.config = {
  # Path to the wkhtmltopdf executable: This usually isn't needed if using
  # one of the wkhtmltopdf-binary family of gems.
  #   or
  exe_path: wkhtmltopdf_path,
  # Layout file to be used for all PDFs
  # (but can be overridden in `render :pdf` calls)
  # layout: 'pdf.html',
}
