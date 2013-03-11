# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :claim do
    association :user, factory: :admin
    # association :office
    # association :company
    # association :resort
    # #association :city
    association :applicant

    check_date Time.now + 20.day
    tour_price_currency 'eur'
    visa_price_currency 'eur'
    insurance_price_currency 'eur'
    additional_insurance_price_currency 'eur'
    fuel_tax_price_currency 'eur'
    operator_price_currency 'eur'
  end
end
