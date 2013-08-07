class AddSmsSignatureToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :sms_signature, :string
  end
end
