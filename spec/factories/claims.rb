# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :claim do
    association :user, factory: :manager
    association :office
    association :company
    association :applicant, factory: :tourist
    association :operator

    reservation_date { Date.today }
    check_date { 5.days.since }
    arrival_date { 10.days.since }
    departure_date { 15.days.since }
    hotel "Ekaterina 5*"

    airline 'test'
    tour_price_currency 'rur'
    visa_price_currency 'rur'
    insurance_price_currency 'rur'
    additional_insurance_price_currency 'rur'
    fuel_tax_price_currency 'rur'
    operator_price_currency 'rur'
  end

  factory :clientbase_claim, parent: :claim do
    after(:create) do |claim|
      date_in = Time.zone.now
      date_in = "#{date_in.year}.#{rand(1..date_in.month)}.#{rand(1..date_in.day)}"
      date_in = date_in.to_datetime
      FactoryGirl.create(:clientbase_payment, :claim => claim, :company => claim.company,
        :recipient_id => claim.company.id, :date_in => date_in)
    end
  end
end
