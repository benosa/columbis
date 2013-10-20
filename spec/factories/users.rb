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
    subdomain
    delta false

    factory (:admin)      { role 'admin' }
    factory (:manager)    { role 'manager' }
    factory (:accountant) { role 'accountant' }
    factory (:supervisor) { role 'supervisor' }

    factory :boss do
      role 'boss'
      after(:create) do |user|
        company = user.company
        if company && company.owner.nil?
          company.owner = user
          company.save(validate: false)
        end
      end
    end

    factory :alien_boss do
      company
      office { factory_assoc :office, company: company }

      role 'boss'
    end

    factory :boss_without_company do
      company nil
      office nil
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
