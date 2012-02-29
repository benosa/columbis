FactoryGirl.define do
  factory :claim do
    association :user
    association :office
    association :country
    association :resort
    association :city

    check_date Time.now + 20.day
    tour_price_currency 'eur'
    visa_price_currency 'eur'
    insurance_price_currency 'eur'
    additional_insurance_price_currency 'eur'
    fuel_tax_price_currency 'eur'
    operator_price_currency 'eur'
  end
end
