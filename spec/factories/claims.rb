# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :claim do
    association :company
    office { factory_assoc :office, company: company }
    user { factory_assoc :manager, company: company, office: office }
    operator { factory_assoc :operator, company: company }
    applicant { factory_assoc :tourist, company: company }

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

    tourist_stat 'Рекомендации'
    # Need to create one dropdown_value, because of tourist_stat is required and must be in select box in claim form
    after(:create) do |claim|
      if DropdownValue.where(company_id: claim.company_id, list: 'tourist_stat', value: 'Рекомендации').count == 0
        FactoryGirl.create(:dropdown_value, company: claim.company, list: 'tourist_stat', value: 'Рекомендации')
      end
    end
  end

  factory :clientbase_claim, parent: :claim do
    after(:create) do |claim|
      date_in = Time.zone.now
      date_in = "#{date_in.year}.#{rand(1..date_in.month)}.#{rand(1..date_in.day)}".to_datetime
      FactoryGirl.create(:clientbase_payment, :claim => claim, :company => claim.company,
        :recipient_id => claim.company.id, :date_in => date_in)
    end
  end
end
