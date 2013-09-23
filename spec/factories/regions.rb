# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :region do
    name { Faker::Name.name }
    association :country
  end
end
