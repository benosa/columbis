# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :company do
    #association :user, factory: :manager
    name Faker::Lorem.sentence 
    email Faker::Internet.email
    oficial_letter_signature 'bye'
  end

  factory :alien_company, :class => Company do
    name Faker::Lorem.sentence 
    email Faker::Internet.email
    oficial_letter_signature 'bye'
  end
end
