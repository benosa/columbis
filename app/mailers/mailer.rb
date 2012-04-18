class Mailer < ActionMailer::Base
  def registrations_info(user)
    @user = user
    mail(:to => user.email, :subject => I18n.t('registration_data'), :from => 'mailer.devmen.com')
  end
end
