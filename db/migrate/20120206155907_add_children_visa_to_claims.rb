class AddChildrenVisaToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :children_visa_price, :float, :default => 0.0, :null => false
    add_column :claims, :children_visa_count, :integer
    add_column :claims, :children_visa_price_currency, :string, :default => "eur", :null => false
  end
end
