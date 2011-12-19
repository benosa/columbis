class Address < ActiveRecord::Base
  belongs_to :addressable, :polymorphic => true

  def full_address
    "#{region} #{street} #{house_number} #{housing} #{office_number} #{phone_number} #{zip_code}".strip
  end

  def pretty_full_address(with_phone = true)
    str = "#{region}, #{street}, #{house_number}, #{housing}, #{office_number}, #{zip_code}".strip
    str.gsub!(', ,', ',')
    str.chomp(',')
  end
end
