# -*- encoding : utf-8 -*-
FactoryGirl.define do

  factory :company do
    name { Faker::Name.name }
    email
    subdomain
    association :tariff, :factory => :tariff_plan
    tariff_end { Time.zone.now + 15.days }
  end
end
