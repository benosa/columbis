# -*- encoding : utf-8 -*-
FactoryGirl.define do

  factory :user do
    company
    office { factory_assoc :office, company: company }

    email #{ Faker::Internet.email }
    last_name { Faker::Name.last_name }
    first_name { Faker::Name.first_name }
    middle_name { Faker::Name.first_name }
    phone
    confirmed_at { Time.zone.now }
    delta false

    factory (:admin)      { role 'admin' }
    factory (:boss)       { role 'boss' }
    factory (:manager)    { role 'manager' }
    factory (:accountant) { role 'accountant' }

    factory :alien_boss do
      company
      office { factory_assoc :office, company: company }

      role 'boss'
    end

    factory :user_with_company_and_office do
      before(:create) do |user|
        user.company = FactoryGirl.create(:company)
        user.office  = FactoryGirl.create(:office, company: user.company)
      end
    end
  end
end
