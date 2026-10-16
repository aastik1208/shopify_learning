class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.credentials.dig(:app_sender_email)
  layout 'mailer'
end
