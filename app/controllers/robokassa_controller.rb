class RobokassaController < ApplicationController
  include ActiveMerchant::Billing::Integrations

  skip_filter :verify_authenticity_token, :check_subdomain
  before_filter :check_ability, :except => :paid

  def paid # Robokassa call this action after transaction
    @notification = Robokassa::Notification.new(request.raw_post, :secret => CONFIG[:robokassa_password2])
    if @notification.acknowledge # check if it’s genuine Robokassa request
      @user_payment = UserPayment.where(:invoice => @notification.item_id).first
      if @user_payment && @user_payment.pay(:paid)
        text = @notification.success_response
      else
        text = t('.user_payments.messages.robokassa_bad_paid')
      end
    else
      text = t('.user_payments.messages.robokassa_bad_key')
    end
    render :text => text
  end

  def success # Robokassa redirect user to this action if it’s all ok
    @notification = Robokassa::Notification.new(request.query_string, :secret => CONFIG[:robokassa_password1])
    if @notification.acknowledge # check if it’s genuine Robokassa request
      @user_payment = UserPayment.where(:invoice => @notification.item_id).first
      if @user_payment
        redirect_to user_payments_path, @user_payment.pay(:success)
      else
        redirect_to user_payments_path,
          :alert => t('.user_payments.messages.robokassa_bad_success')
      end
    else
      redirect_to user_payments_path,
          :alert => t('.user_payments.messages.robokassa_success_bad_key')
    end
  end

  def fail # Robokassa redirect user to this action if it’s not
    if params['InvId']
      @user_payment = UserPayment.where(:invoice => params['InvId']).first
      if @user_payment
        redirect_to user_payments_path, @user_payment.pay(:fail)
      else
        redirect_to user_payments_path,
          :alert => t('.user_payments.messages.robokassa_bad_fail')
      end
    else
      redirect_to user_payments_path,
        :alert => t('.user_payments.messages.robokassa_fail_bad_id')
    end
  end

  private

    def check_ability
      authorize! :read, :robokassa_pay
    end

    def user_payments_path
      user_payments_url domain: CONFIG[:domain], subdomain: current_company.try(:subdomain)
    end
end