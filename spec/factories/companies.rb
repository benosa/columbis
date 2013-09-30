# -*- encoding : utf-8 -*-
FactoryGirl.define do
  sequence(:subdomain) { |n| "subdomain#{n}" }

  factory :company do
    name Faker::Lorem.sentence
    email Faker::Internet.email
    subdomain
  end
end
