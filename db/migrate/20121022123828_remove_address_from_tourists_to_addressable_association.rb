# -*- encoding : utf-8 -*-
class RemoveAddressFromTouristsToAddressableAssociation < ActiveRecord::Migration
  class Address < ActiveRecord::Base; end

  def up
    # Remove address data to addresses table
    execute("INSERT INTO addresses (addressable_type, addressable_id, region, joint_address) SELECT 'Tourist', id, address, address FROM tourists;")
    remove_column :tourists, :address
  end

  def down
    add_column :tourists, :address, :string
    # Remove address data back to tourists table
    execute("UPDATE tourists SET address = joint_address FROM addresses WHERE addressable_id = tourists.id AND addressable_type = 'Tourist';")
    Address.delete_all("addressable_type = 'Tourist'")
  end
end
