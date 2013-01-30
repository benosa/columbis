# -*- encoding : utf-8 -*-
class SetCommonInCountriesAndCities < ActiveRecord::Migration
  def up
    Country.where("id <= 106").update_all(:common => true) # Countries between Russia (1) and Japan (106) are common
    Country.where("id > 106").update_all(:company_id => 1) # All other countries belong to company
    City.where("id <= 10814").update_all(:common => true) # Cities wich id lower than Kofu(10814) are common
    City.where("id > 10814").update_all(:company_id => 1) # Cities wich id greater than Kofu(10814) belong to company
  end

  def down
    Country.where("id <= 106").update_all(:common => false)
    Country.where("id > 106").update_all(:company_id => nil)
    City.where("id <= 10814").update_all(:common => false)
    City.where("id > 10814").update_all(:company_id => nil)
  end
end
