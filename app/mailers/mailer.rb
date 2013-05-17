# -*- encoding : utf-8 -*-
class Mailer < ActionMailer::Base
  default from: "testdevmen@gmail.com"
  def registrations_info(user)
    @user = user
    mail(to: user.email, subject: I18n.t('registration_data'), from: 'testdevmen@gmail.com')
  end

  def task_info(task)
    @task = task

    subject = case
    when task.status == 'new'
      "#[#{@task.id}] Задача создана"
    when task.status == 'work'
      "#[#{@task.id}] Задача в работе"
    else
      "#[#{@task.id}] Задача завершена"
    end
    mail(to: 'testdevmen@gmail.com', subject: subject, from: 'testdevmen@gmail.com')
  end

  # def receive(email)
  #   page = Page.find_by_address(email.to.first)
  #   page.emails.create(
  #     :subject => email.subject,
  #     :body => email.body
  #   )
 
  #   if email.has_attachments?
  #     email.attachments.each do |attachment|
  #       page.attachments.create({
  #         :file => attachment,
  #         :description => email.subject
  #       })
  #     end
  #   end
  # end
  
end
