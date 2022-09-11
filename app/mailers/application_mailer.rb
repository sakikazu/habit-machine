class ApplicationMailer < ActionMailer::Base
  default from: ENV['MY_EMAIL']
  layout 'mailer'
end
