class PhoneNumberValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.to_s.length >= 10
      record.errors[:phone_number] << I18n.t('errors.messages.too_short.many', count: 10)
    end
    unless value =~ /\A\+7[0-9]+\z/i
      record.errors[:phone_number] << I18n.t('errors.messages.wrong_format')
    end
  end
end