class AddCanceledToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :canceled, :boolean, :default => false
  end
end
