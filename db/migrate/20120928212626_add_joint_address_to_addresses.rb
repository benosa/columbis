# -*- encoding : utf-8 -*-
class AddJointAddressToAddresses < ActiveRecord::Migration
  def up
    add_column :addresses, :joint_address, :text
    add_index :addresses, :joint_address
    Address.all.each{ |a| a.save! }
  end

  def down
    remove_index :addresses, :joint_address
    remove_column :addresses, :joint_address
  end
end
