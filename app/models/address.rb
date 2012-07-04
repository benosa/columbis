class Address < ActiveRecord::Base
  attr_protected :company_id
  belongs_to :company
  belongs_to :addressable, :polymorphic => true

  def full_address
    "#{region} #{street} #{house_number} #{housing} #{office_number} #{phone_number} #{zip_code}".strip
  end

  def pretty_full_address(with_phone = true)
    str = "#{region}, #{street}, #{house_number}, #{housing}, #{office_number}, #{zip_code}".strip
    str.gsub!(/,\W*,/, ',')
    str.chomp(',')
  end
end
