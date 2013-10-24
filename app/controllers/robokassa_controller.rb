class RobokassaController < ApplicationController
  include ActiveMerchant::Billing::Integrations

  before_filter :check_ability, :except => :paid

  def paid # Robokassa call this action after transaction
    @notification = Robokassa::Notification.new(URI(request.url).query, :secret => CONFIG[:robokassa_password2])
    if @notification.acknowledge # check if it’s genuine Robokassa request
      @user_payment = UserPayment.where(:invoice => @notification.item_id).first
      if @user_payment && @user_payment.update_attributes(:status => 'approved')
        render :text => @notification.success_response
      else
        render :text => t('.user_payments.messages.robokassa_bad_paid')
      end
    else
      render :text => t('.user_payments.messages.robokassa_bad_key')
    end
  end

  def success # Robokassa redirect user to this action if it’s all ok
    @notification = Robokassa::Notification.new(URI(request.url).query, :secret => CONFIG[:robokassa_password1])
    if @notification.acknowledge # check if it’s genuine Robokassa request
      @user_payment = UserPayment.where(:invoice => @notification.item_id).first
      if @user_payment && (@user_payment.status == 'approved' ||
          @user_payment.update_attributes(:status => 'success'))
        redirect_to user_payments_path,
          :notice => t('.user_payments.messages.robokassa_success')
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
      if @user_payment &&
          !['approved', 'success'].include?(@user_payment.status) &&
          @user_payment.update_attributes(:status => 'fail')
        redirect_to user_payments_path,
          :notice => t('.user_payments.messages.robokassa_fail')
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
    unauthorized! if cannot? :read, :robokassa_pay
  end
end