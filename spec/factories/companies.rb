# -*- encoding : utf-8 -*-
FactoryGirl.define do

  factory :company do
    name Faker::Lorem.sentence
    email Faker::Internet.email
    subdomain
  end
end
