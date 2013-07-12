module SmsHelper
  def sms_balance
    a = Smsaero.new 'sergey@columbis.ru', '121212'
    a.balance['balance'] if a.balance
  end
end