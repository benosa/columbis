class SubdomainValidator < ActiveModel::Validator
  def validate(record)
    record.errors[:subdomain] << I18n.t('errors.messages.reserved') if record.subdomain != '' && CONFIG[:reserved_subdomains].include?(record.subdomain)
  end
end