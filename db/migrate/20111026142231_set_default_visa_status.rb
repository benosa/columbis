class SetDefaultVisaStatus < ActiveRecord::Migration
  def change
    change_column :claims, :visa, :string, :null => false, :default => Claim::VISA_STATUSES.first
  end
end
