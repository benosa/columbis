class CorrectAndMovePhoneNumberInTourists < ActiveRecord::Migration
  def up
    ThinkingSphinx.deltas_enabled = false
    logger = Logger.new('log/migration_correct_phone_number_in_tourists.log')

    Tourist.where('length(phone_number) > 0').find_each do |tourist|
      @valid_phone = normalize_phone(tourist.phone_number.to_s)
      if  @valid_phone.nil?
        logger.info "#{tourist.id}: phone number #{tourist.phone_number} isn't valid"
      else
        logger.info "#{tourist.id}: phone number is changed from #{tourist.phone_number} to #{@valid_phone}"
        tourist.update_column(:phone_number_valid, @valid_phone)
      end
    end
  end

  def down
  end

  def normalize_phone phone
    @plus = phone[0] == '+' ? '+' : ''
    number = phone.sub('+', '').split(',')[0]
    number = number.gsub(/\D/, '')

    if number.length > 8
      if number[0] == '7' || number[0] == '8'
        return '+7' + number.gsub(/\A[8,7]/, '')
      else
        return @plus + number
      end
    else
      return nil
    end
  end

end
