class RobokassaController < ApplicationController
  include ActiveMerchant::Billing::Integrations

  # skip_before_filter :verify_authenticity_token # skip before filter if you chosen POST request for callbacks

  before_filter :create_notification
  before_filter :find_payment

  def paid # Robokassa call this action after transaction
    if @notification.acknowledge # check if it’s genuine Robokassa request
      # @payment.approve! # project-specific code
      render :text => "Выполнено действие"
    else
      render :text => "Не верный вызов"
    end
  end

  def success # Robokassa redirect user to this action if it’s all ok
    redirect_to edit_dashboard_company_path(current_company), :notice => "Оплата произведена успешно"
  end

  def fail # Robokassa redirect user to this action if it’s not
    redirect_to edit_dashboard_company_path(current_company), :notice => "Оплата не произведена"
  end

  private

    def create_notification
      @notification = Robokassa::Notification.new(request.raw_post, :secret => CONFIG[:robokassa_secret])
    end

    def find_payment
      @payment = { :id => 0, :amount => 10000 }
    end
end