# -*- encoding : utf-8 -*-
class Address < ActiveRecord::Base
  attr_protected :company_id
  belongs_to :company
  belongs_to :addressable, :polymorphic => true

  before_save do |address|
    self.joint_address = pretty_full_address if joint_address.blank?
  end

  default_scope :order => :joint_address

  define_index do
    indexes :region, :house_number, :housing, :office_number,
            :street, :phone_number, :joint_address, :sortable => true
    has :zip_code
    has :company_id
    # set_property :delta => true
  end

  sphinx_scope(:by_joint) { { :order => :joint_address } }
  default_sphinx_scope :by_joint

  def full_address
    "#{region} #{street} #{house_number} #{housing} #{office_number} #{phone_number} #{zip_code}".strip
  end

  def pretty_full_address(with_phone = true)
    str = "#{region}, #{street}, #{house_number}, #{housing}, #{office_number}, #{zip_code}".strip
    str.gsub(/,\W*,/, ',').gsub(/(^,\W*)|(,\W*$)/, '').strip
  end

  def self.left_join(model)
    "LEFT JOIN addresses ON addresses.addressable_id = #{model.table_name}.id AND addresses.addressable_type = '#{model.name}'"
  end

  def self.order_text(column, dir = :asc)
    "#{table_name}.#{column} #{dir}"
  end
end
