class CorrectAndMovePhoneNumberToNotesInTourists < ActiveRecord::Migration
  def up
    logger = Logger.new('log/migration_correct_phone_number_in_tourists.log')

    Tourist.where('length(phone_number) > 0').find_each do |tourist|
      notes = tourist.phone_number
      phone_number = normalize_phone(tourist.phone_number.to_s)
      if phone_number.nil?
        logger.info "#{tourist.id}: phone number #{tourist.phone_number} isn't valid"
      elsif phone_number != tourist.phone_number
        logger.info "#{tourist.id}: phone number is changed from #{tourist.phone_number} to #{phone_number}"
      end
      tourist.update_attributes({ note: notes, phone_number: phone_number })
    end
  end

  def down
  end

  def normalize_phone number
    normal_phone = ''
    normal_phone = number.gsub(/\A[8,7]/,'').gsub(/\D/, '') if (number.length > 8)
    normal_phone.length == 10 ? normal_phone : nil
  end
end
