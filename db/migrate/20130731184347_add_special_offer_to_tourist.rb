class AddSpecialOfferToTourist < ActiveRecord::Migration
  def change
    add_column :tourists, :special_offer, :boolean, :default => false
  end
end
