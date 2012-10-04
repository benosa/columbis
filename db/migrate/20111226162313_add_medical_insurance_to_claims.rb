# -*- encoding : utf-8 -*-
class AddMedicalInsuranceToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :medical_insurance, :string
  end
end
