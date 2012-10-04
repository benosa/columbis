# -*- encoding : utf-8 -*-
class CityCompany < ActiveRecord::Base
  belongs_to :city
  belongs_to :company
end
