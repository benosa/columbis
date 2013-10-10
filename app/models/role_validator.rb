class RoleValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add attribute, (options[:message] || :invalid) unless
      record.available_roles.include? value
  end
end