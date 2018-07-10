class ApplicationMailer < ActionMailer::Base
  default from: ENV["MAILER_DEFAULT_ADDRESS"]
  layout 'mailer'
end
