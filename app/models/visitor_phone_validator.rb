class VisitorPhoneValidator < ActiveModel::Validator
  def validate(record)
    if Visitor.where(phone: record.phone, confirmed: true).first
      record.errors[:phone] << I18n.t('activerecord.errors.messages.taken')
    end
  end
end