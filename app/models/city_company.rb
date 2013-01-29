# -*- encoding : utf-8 -*-
class CityCompany < ActiveRecord::Base
  belongs_to :city
  belongs_to :company
  validates_uniqueness_of :city_id, :scope => :company_id
end
