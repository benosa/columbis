# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :country do
    name { Faker::Name.name }
    common false
    association :company

    factory :open_country do
      common true
      company_id nil
    end
  end
end
