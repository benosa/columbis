class RenameOperatorConfirmationFlagInClaims < ActiveRecord::Migration
  def change
    rename_column :claims, :operator_confirmation_flag, :visa_confirmation_flag
  end
end
