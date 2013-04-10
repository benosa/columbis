# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :country do
    name { Faker::Name.name }
  end
end
