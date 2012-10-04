# -*- encoding : utf-8 -*-
class AddCourseEurToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :course_eur, :float, :default => 0.0
  end
end
