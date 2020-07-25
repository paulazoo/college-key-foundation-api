class AccountMailer < ApplicationMailer
  default from: ENV['GMAIL_USERNAME']
 
  def welcome_email()
    @url  = 'http://collegekeyfoundation.org/login'
    mail(to: 'collegekeyfoundation@gmail.com', subject: 'Welcome to College Key Foundation!')
  end
end
