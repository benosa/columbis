module UserPaymentsHelper
  def user_payments_statuses
    UserPayment::STATUSES.collect { |s| [ I18n.t(".user_payments.statuses.#{s}") , s ] }
  end
end
