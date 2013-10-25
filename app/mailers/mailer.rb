# -*- encoding : utf-8 -*-
class Mailer < ActionMailer::Base
  include AbstractController::Callbacks
  include Devise::Mailers::Helpers
  layout 'mailer'
  default from: CONFIG[:support_email]

  before_filter :set_attach
  after_filter :control_delivery

  def registrations_info(user, password)
    @resource = user
    @password = password
    mail to: user.email, subject: I18n.t('mailer.registration_data_subject')
  end

  def company_was_created(company)
    @resource = company
    # Doesn't set subject properly, now default subject translation is used, may be it's ActionMailer bug
    subject = I18n.t('mailer.company_was_created_subject', company: company.name || company.subdomain, locale: :ru)
    mail to: CONFIG[:support_email], subject: subject
  end

  def user_was_created(user)
    @resource = user
    subject = I18n.t('mailer.user_was_created_subject', user: user.full_name || user.login)
    mail to: CONFIG[:support_email], subject: subject
  end

  def task_was_created(task)
    @resource = task
    subject = I18n.t('mailer.task_was_created_subject', task: task.id)
    from = task.user.try(:email) || CONFIG[:support_email]
    mail(from: from, to: CONFIG[:support_email], subject: subject)
  end

  def task_info(task)
    @resource = task
    subject = ["[##{task.id}]", Task.model_name.human, I18n.t("mailer.task_info.#{task.status}")].join(' ')
    mail(to: CONFIG[:support_email], subject: subject)
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

  private

    def control_delivery
      mail.perform_deliveries = false if mail.to.first == CONFIG[:support_email] && !CONFIG[:support_delivery]
      true
    end

end
