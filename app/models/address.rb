class Address < ActiveRecord::Base
  belongs_to :addressable, :polymorphic => true

  def full_address
    "#{region} #{street} #{house_number} #{housing} #{office_number} #{phone_number} #{zip_code}".strip
  end
end
