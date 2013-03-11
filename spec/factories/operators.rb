# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :operator do
    association :claim
    #association :company
    name { Faker::Lorem.sentence }
  end
end
