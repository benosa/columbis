class AddOperatorConfirmationFlagAgainToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :operator_confirmation_flag, :boolean, :default => false
  end
end
