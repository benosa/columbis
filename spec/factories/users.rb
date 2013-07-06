# -*- encoding : utf-8 -*-
FactoryGirl.define do

  sequence :email do |n|
    "email#{n}@factory.com"
  end

  sequence :login do |n|
    "login#{n}"
  end

  factory :user do
    association :company
    association :office

    email { Faker::Internet.email }
    login { Faker::Name.name }
    last_name { Faker::Name.name }
    first_name { Faker::Name.name }
    middle_name { Faker::Name.name }
    password 'secret'
    password_confirmation 'secret'
    delta false

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
