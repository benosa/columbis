# -*- encoding : utf-8 -*-
class Mailer < ActionMailer::Base
  def registrations_info(user)
    @user = user
    mail(to: user.email, subject: I18n.t('registration_data'), from: 'mailer.devmen.com')
  end

  def task_info(task)
    @task = task
    mail(to: 'v.sheshenya@gmail.com', subject: "(task.status == 'new' ? 'Создана задача': 'Задача завершена') № #{task.id}", from: 'mailer.devmen.com')
  end
end
