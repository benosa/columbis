# -*- encoding : utf-8 -*-
class RenameCourseAndCurrencyInClaims < ActiveRecord::Migration
  def change
    rename_column :claims, :course, :course_usd
    rename_column :claims, :currency, :tour_price_currency
  end
end
