# -*- encoding : utf-8 -*-
FactoryGirl.define do

  factory :company do
    name { Faker::Name.name }
    email
    subdomain
  end
end
