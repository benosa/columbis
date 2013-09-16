# -*- encoding : utf-8 -*-
class Mailer < ActionMailer::Base
  include AbstractController::Callbacks
  include Devise::Mailers::Helpers
  layout 'mailer'
  default from: "testdevmen@gmail.com"
  before_filter :set_attach

  def registrations_info(user)
    @user = user
    attachments.inline['logo.png'] = File.read(Rails.root.join('app/assets/images', 'logo_mail.png'))
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

  def new_password_instructions(record)
    devise_mail(record, :new_password_instructions)
  end

  def confirmation_instructions(record)
    devise_mail(record, :confirmation_instructions)
  end

  def reset_password_instructions(record)
    devise_mail(record, :reset_password_instructions)
  end

  def unlock_instructions(record)
    devise_mail(record, :unlock_instructions)
  end

  def set_attach
    attachments.inline['logo.png'] = File.read(Rails.root.join('app/assets/images', 'logo_mail.png'))
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
