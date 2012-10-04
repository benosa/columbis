# -*- encoding : utf-8 -*-
class AddReversedCourseToPayment < ActiveRecord::Migration
  def change
    add_column :payments, :reversed_course, :boolean, :default => false
  end
end
