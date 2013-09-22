# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :catalog do
    name Faker::Name.name
    association :company
  end
end
