class HotelValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    valid = value.to_s.index('*') ? value =~ /\s[1-5]\*\Z/ : true
    record.errors.add attribute, (options[:message] || :invalid) unless valid
  end
end