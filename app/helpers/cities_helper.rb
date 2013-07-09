# -*- encoding : utf-8 -*-
module CitiesHelper
  def availability_filter_options
  	City::AVAILABILITIES.map{ |st| [ t("city_availabilities.#{st}"), st ] }
  end
end
