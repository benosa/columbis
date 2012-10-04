# -*- encoding : utf-8 -*-
module TouristsHelper
  def tourist_mustache_data(tourist)
    {
      :full_name => tourist.full_name,
      :passport_series => tourist.passport_series,
      :passport_number => tourist.passport_number,
      :passport_valid_until => tourist.passport_valid_until,
      :phone_number => tourist.phone_number,
      :address => tourist.address,
      :date_of_birth => tourist.date_of_birth,
      :show_link => link_to(t('show'), tourist),
      :edit_link => link_to(t('edit'), edit_tourist_path(tourist)),
      :destroy_link => link_to(t('destroy'), tourist, :method => :delete, :confirm => t('are_you_sure')),
    }
  end
end
