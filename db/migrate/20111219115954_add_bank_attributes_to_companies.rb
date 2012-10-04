# -*- encoding : utf-8 -*-
class AddBankAttributesToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :bank, :string
    add_column :companies, :bik, :string
    add_column :companies, :curr_account, :string
    add_column :companies, :corr_account, :string
    add_column :companies, :ogrn, :string
  end
end
