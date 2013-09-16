# -*- encoding : utf-8 -*-
FactoryGirl.define do

  sequence(:email) { |n| "email#{n}@factory.com" }
  sequence(:phone) { |n| "+7777777#{n}" }

  factory :user do
    association :company
    association :office

    email #{ Faker::Internet.email }
    last_name { Faker::Name.name }
    first_name { Faker::Name.name }
    middle_name { Faker::Name.name }
    phone
    confirmed_at { Time.zone.now }
    delta false

    after(:create) { |user| user.confirm! }

    factory (:admin)      { role 'admin' }
    factory (:boss)       { role 'boss' }
    factory (:manager)    { role 'manager' }
    factory (:accountant) { role 'accountant' }

    factory :alien_boss do
      # association :company
      # association :office

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
