# -*- encoding : utf-8 -*-
class AddCourseToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :course, :float, :default => 1
  end
end
