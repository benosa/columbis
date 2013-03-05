# -*- encoding : utf-8 -*-
class Mailer < ActionMailer::Base
  default from: "testdevmen@gmail.com"
  def registrations_info(user)
    @user = user
    mail(to: user.email, subject: I18n.t('registration_data'), from: 'testdevmen@gmail.com')
  end

  def task_info(task)
    @task = task
    mail(to: 'v.sheshenya@gmail.com', subject: "#{@task.status == 'new' ? 'Создана задача' : 'Задача завершена' || @task.status == 'work' ? 'Задача в работе' : 'Задача завершена' } № #{@task.id}", from: 'testdevmen@gmail.com')
  end

  def receive(email)
    page = Page.find_by_address(email.to.first)
    page.emails.create(
      :subject => email.subject,
      :body => email.body
    )
 
    if email.has_attachments?
      email.attachments.each do |attachment|
        page.attachments.create({
          :file => attachment,
          :description => email.subject
        })
      end
    end
  end
end
