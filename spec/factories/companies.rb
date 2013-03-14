# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :company do
    #association :user, factory: :manager
    name 'company'
    email 'wtf@gmail.com'
    oficial_letter_signature 'bye'
  end

  factory :alien_company, :class => Company do
    name 'alien_company'
    email 'alien_wtf@gmail.com'
    oficial_letter_signature 'bye'
  end
end
