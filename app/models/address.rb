class Address < ActiveRecord::Base
  attr_protected :company_id
  belongs_to :company
  belongs_to :addressable, :polymorphic => true

  before_save do |address|
    self.joint_address = pretty_full_address
  end

  def full_address
    "#{region} #{street} #{house_number} #{housing} #{office_number} #{phone_number} #{zip_code}".strip
  end

  def pretty_full_address(with_phone = true)
    str = "#{region}, #{street}, #{house_number}, #{housing}, #{office_number}, #{zip_code}".strip
    str.gsub!(/,\W*,/, ',')
    str.chomp(',')
  end

  def self.left_join(model)
    "LEFT JOIN addresses ON addresses.addressable_id = #{model.table_name}.id AND addresses.addressable_type = '#{model.name}'"
  end

  def self.order_text(column, dir = :asc)
    "#{table_name}.#{column} #{dir}"
  end
end
