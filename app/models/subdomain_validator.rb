class SubdomainValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if record.subdomain != ''
      reserved = false
      CONFIG[:reserved_subdomains].each do |str|
        if str.first == '/' && str.last == '/'
          reserved = Regexp.new(str[1..-2], Regexp::IGNORECASE) =~ value
        else
          reserved = str == value
        end
        break if reserved
      end
      record.errors[:subdomain] << I18n.t('activerecord.errors.messages.subdomain_taken') if reserved
    end
  end
end